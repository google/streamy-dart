library streamy_multiplexer;

import "dart:async";
import "base.dart";
import "cache.dart";
import "set_multimap.dart";

class _ActiveStream {

  /// The request that this stream transmits.
  final Request request;

  /// [Completer] for the [closed] [Future], which indicates when this stream
  /// no longer has subscribers.
  final _closeCompleter = new Completer();

  /// Sink for this stream.
  var _sink;

  /// The actual [Stream] returned to the client.
  Stream get stream => _sink.stream;

  /// The last entity seen across this stream.
  Entity current = null;

  /// A [Future] that completes when this stream loses its subscriber(s).
  Future get closed => _closeCompleter.future;

  _ActiveStream(this.request) {
    _sink = new StreamController(onCancel: _closeCompleter.complete);
  }

  /// Maybe send an [Entity] across t)his stream.
  submit(Entity entity) {
    if (current != null && current.streamy.ts > entity.streamy.ts) {
      // Drop this entity, it has an older timestamp than the one we last sent.
      return;
    }

    // Safe to cache a reference here, as the multiplexer takes care not to
    // mutate elements.
    current = entity;
    _sink.add(entity.clone());
  }

  /// Send an error.
  sendError(error) => _sink.addError(error);

  close() => _sink.close();
}

/// The multiplexer is an intermediary that handles the routing of requests
/// between caches and the true Apiary interface.
class Multiplexer extends RequestHandler {

  /** Cache instance (or null for no cache). */
  final Cache _cache;

  /** Delegate handler (usually a real Apiary stack). */
  final RequestHandler _delegate;

  /**
   * Guaranteed to contain only in flight requests.
   */
  var _inFlightRequests = new Map<Request, Future>();

  /**
   * Index of [Request]s to outgoing [_ActiveStream]s for those requests.
   */
  var _activeIndex = new SetMultimap<Request, _ActiveStream>();

  Multiplexer(this._delegate, this._cache);

  Stream handle(Request request) {
    // Make a copy of the request for use in the multiplexer, since it's not
    // immutable.
    request = request.clone();

    // Create a new stream for this request.
    var active = new _ActiveStream(request);
    active.closed.whenComplete(() => _removeActive(active));

    // Make an RPC if it's not already in flight.
    Future pending;
    if (!_inFlightRequests.containsKey(request)) {
      pending = _delegate.handle(request).single
        ..then((entity) => _handleRpcReply(request, entity));
      if (request.isCachable) {
        _inFlightRequests[request] = pending;
      }
    } else {
      pending = _inFlightRequests[request];
    }

    if (request.isCachable) {
      _cache.get(request).then((cachedEntity) {
        if (cachedEntity != null) {
          active.submit(cachedEntity);
        }
      }, onError: active.sendError);
    }

    // RPC replies are handled in one place, but errors for requests are
    // subscribed to individually. This is because only in-flight requests
    // should have error returns, whereas all streams for a request care when
    // a new result is received.
    pending.then((_) {},
      onError: (error) {
        _inFlightRequests.remove(request);
        active.sendError(error);
      }
    );

    // Remember that this client is interested in this request.
    _activeIndex[request].add(active);

    return active.stream;
  }

  _handleRpcReply(Request request, Entity entity) {
    _inFlightRequests.remove(request);

    // Timestamp when we first saw this entity.
    entity.streamy.ts = new DateTime.now().millisecondsSinceEpoch;
    entity.streamy.source = "RPC";

    // Publish this new entity on every channel.
    _activeIndex[request].forEach((act) => runAsync(() => act.submit(entity)));

    if (!request.isCachable) {
      // Request isn't cachable, so close down any stream(s) waiting for it -
      // there will be no future values. This is done asynchronously to avoid
      // modifying the iterable from the forEach().
      _activeIndex[request].forEach((act) =>
          runAsync(() => _removeActive(act..close())));
      _activeIndex.remove(request);
    } else {
      // Commit to cache with a modified source.
      _cache.set(request, entity.clone()..streamy.source = "CACHE");
    }
  }

  _removeActive(_ActiveStream stream) =>
      _activeIndex.removeValue(stream.request, stream);
}
