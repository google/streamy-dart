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

  /// Maybe send an [Entity] across this stream.
  submit(Entity entity, String source) {
    if (current != null && current.streamy.ts > entity.streamy.ts) {
      // Drop this entity, it has an older timestamp than the one we last sent.
      return;
    }

    // Safe to cache a reference here, as the multiplexer takes care not to
    // mutate elements.
    current = entity;
    _sink.add(new Result(entity, source));
  }

  /// Send an error.
  sendError(error) => _sink.addError(error);

  close() => _sink.close();
}

class _InFlightRequest {
  Future future;
  CancelFn cancel;

  _InFlightRequest(this.future, this.cancel);
}

/// The multiplexer is an intermediary that handles the routing of requests
/// between caches and the true Apiary interface.
class Multiplexer extends RequestHandler {

  static const AGE_NO_RPC = -1;
  static const AGE_CACHE_LOOKUP_ONCE = -2;

  /** Cache instance. */
  final Cache _cache;

  /** Delegate handler (usually a real HTTP stack). */
  final RequestHandler _delegate;

  /**
   * Guaranteed to contain only in flight requests.
   */
  var _inFlightRequests = new Map<Request, _InFlightRequest>();

  /**
   * Index of [Request]s to outgoing [_ActiveStream]s for those requests.
   */
  var _activeIndex = new SetMultimap<Request, _ActiveStream>();

  Multiplexer(this._delegate, {Cache cache: null})
      : this._cache = cache == null ? new AsyncMapCache() : cache;

  _newActiveStream(request) {
    // Create a new stream for this request.
    var active = new _ActiveStream(request);
    active.closed.whenComplete(() => _removeActive(active));

    return active;
  }

  _handleAgeQuery(request, age) {
    var active = _newActiveStream(request);

    _cache.get(request)
      .catchError(active.sendError)
      .then((cachedEntity) {
        // If there actually was an entity response, send it to the client.
        if (cachedEntity != null) {
          active.submit(cachedEntity, 'CACHE');
        }
        var ts = new DateTime.now().millisecondsSinceEpoch;  // TODO: not testable
        // If we don't need to issue an rpc
        if (age < 0 || (cachedEntity != null && (ts - cachedEntity.streamy.ts) < age)) {
          if (age == AGE_CACHE_LOOKUP_ONCE) {
            // Not interested in future responses at all.
            active.close();
          } else {
            // Don't want to send the RPC, but still interested in future responses.
            _activeIndex[request].add(active);
          }
          return;
        }

        _sendRpc(request, active);

        // Interested in future responses.
        _activeIndex[request].add(active);
      });

      return active.stream;
  }

  _sendRpc(request, active) {
    // Only cachable requests need to be handled by the multiplexer (right now).
    if (request.isCachable) {

      // Make an RPC if it's not already in flight.
      Future pending;
      if (!_inFlightRequests.containsKey(request)) {
        var completer = new Completer();
        var sub = _delegate.handle(request).listen(completer.complete)
          ..onError(completer.completeError);
        var cancel = () {
          // The pending future will never complete.
          sub.cancel();

          _inFlightRequests.remove(request);
        };
        pending = completer.future;
        pending
          // Report internal error but don't process it, processing is done in
          // a separate catcher below.
          .catchError((_) => _INTERNAL_ERROR)
          .then((entity) => _handleRpcReply(request, entity))
          .whenComplete(() {
            _inFlightRequests.remove(request);
          });
        _inFlightRequests[request] = new _InFlightRequest(pending, cancel);
      } else {
        pending = _inFlightRequests[request].future;
      }

      // RPC replies are handled in one place, but errors for requests are
      // subscribed to individually. This is because only in-flight requests
      // should have error returns, whereas all streams for a request care when
      // a new result is received.
      pending.catchError((error) {
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
          if (entity != _INTERNAL_ERROR) {
            _recordRpcData(entity);
            active.submit(entity, 'RPC');
          }
        })
        .whenComplete(active.close);
    }
  }

  Stream handle(Request originalRequest) {
    // Make a copy of the request for use in the multiplexer, since it's not
    // immutable.
    var request = originalRequest.clone();

    if (originalRequest.local.containsKey('noRpcAge')) {
      if (!request.isCachable) {
        throw new ArgumentError("Cannot specify noRpcAge parameter on a non-cachable request.");
      }
      return _handleAgeQuery(request, originalRequest.local['noRpcAge']);
    }

    var active = _newActiveStream(request);

    // Only cachable requests need to be handled by the multiplexer (right now).
    if (request.isCachable) {
      // Make cache request (always).
      _cache.get(request)
        .catchError(active.sendError)
        .then((cachedEntity) {
          if (cachedEntity != null) {
            active.submit(cachedEntity, 'CACHE');
          }
        });
    }

    _sendRpc(request, active);

    return active.stream;
  }

  _handleRpcReply(Request request, Entity entity) {
    if (entity == _INTERNAL_ERROR) {
      // An error occurred, no need to handle it here.
      return;
    }
    
    _recordRpcData(entity);
    entity._freeze();


    // Publish this new entity on every channel.
    _activeIndex[request].forEach((act) => runAsync(() => act.submit(entity, 'RPC')));

    // Commit to cache. It's expected that the cache will clone, serialize, or otherwise
    // copy the entity to avoid modifications.
    if (entity != null) {
      _cache.set(request, entity);
    }
  }

  _removeActive(_ActiveStream stream) {
    var request = stream.request;
    _activeIndex.removeValue(request, stream);
    if (!_activeIndex.containsKey(request) && _inFlightRequests.containsKey(request)) {
      _inFlightRequests[request].cancel();
    }
  }

  _recordRpcData(entity) {
    entity.streamy
      ..ts = new DateTime.now().millisecondsSinceEpoch;
  }
}

/// A [RequestHandler] which wraps [Multiplexer] and adds a few
/// utility methods to delegate to it.
abstract class BaseMultiplexedRequestHandler extends RequestHandler {

  final Multiplexer delegate;

  BaseMultiplexedRequestHandler(this.delegate);

  /// Retrieve an entity from cache only, if present.
  Future<Entity> getFromCache(Request request) {
    request.local['noRpcAge'] = Multiplexer.AGE_CACHE_LOOKUP_ONCE;
    return delegate.handle(request).pipe(new ZeroOrOneConsumer());
  }
}
