part of streamy.runtime;

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

    // Only cachable requests need to be handled by the multiplexer (right now).
    if (request.isCachable) {

      // Make an RPC if it's not already in flight.
      Future pending;
      if (!_inFlightRequests.containsKey(request)) {
        pending = _delegate.handle(request).single;
        pending
          .catchError((_) {}) // Ignore errors here, they are caught separately below.
          .then((entity) => _handleRpcReply(request, entity));
        _inFlightRequests[request] = pending;
      } else {
        pending = _inFlightRequests[request];
      }

      // Make cache request (always).
      _cache.get(request)
        .catchError(active.sendError)
        .then((cachedEntity) {
          if (cachedEntity != null) {
            active.submit(cachedEntity);
          }
        });

      // RPC replies are handled in one place, but errors for requests are
      // subscribed to individually. This is because only in-flight requests
      // should have error returns, whereas all streams for a request care when
      // a new result is received.
      pending.catchError((error) {
        _inFlightRequests.remove(request);
        active.sendError(error);
      });

      // Remember that this client is interested in this request.
      _activeIndex[request].add(active);
    } else {
      // Non-cachable requests generate one reply only, ever.
      _delegate.handle(request).single
        .catchError((error) {
          active.sendError(error);
          return _INTERNAL_ERROR;
        })
        .then((entity) {
          if (entity is! _INTENRAL_ERROR) {
            _maybeRecordRpcData(entity);
            active.send(entity);
          }
        })
        .whenComplete(active.close);
    }
    return active.stream;
  }

  _handleRpcReply(Request request, Entity entity) {
    _inFlightRequests.remove(request);

    if (entity == _INTERNAL_ERROR) {
      // An error occurred, no need to handle it here other than removing the in-flight request.
      return;
    }

    _maybeRecordRpcData(entity);

    // Publish this new entity on every channel.
    _activeIndex[request].forEach((act) => runAsync(() => act.submit(entity)));

    // Commit to cache with a modified source.
    if (entity != null) {
      _cache.set(request, entity.clone()..streamy.source = 'CACHE');
    }
  }

  _removeActive(_ActiveStream stream) =>
      _activeIndex.removeValue(stream.request, stream);

  _maybeRecordRpcData(entity) {
    entity.streamy
      ..ts = new DateTime.now().millisecondsSinceEpoch
      ..source = 'RPC';
  }
}
