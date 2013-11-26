part of streamy.runtime;

/// Defines interface for an asynchronous cache.
abstract class Cache {

  /// Get an entity from the cache.
  Future<CachedEntity> get(Request key);

  /// Set an entity in the cache.
  Future set(Request key, CachedEntity value);

  /// Invalidate an entity in the cache.
  Future invalidate(Request key);
}

class CachedEntity {
  final Entity entity;
  final int ts;

  CachedEntity(this.entity, this.ts);
}

/// A [Future] based [Cache] that's backed by a [Map].
class AsyncMapCache implements Cache {

  var _cache = new Map<Request, CachedEntity>();

  Future<CachedEntity> get(key) {
    if (_cache.containsKey(key)) {
      return new Future.value(_cache[key]);
    }
    return new Future.value(null);
  }

  Future set(Request key, CachedEntity value) {
    _cache[key] = value;
    return new Future.value(true);
  }

  Future invalidate(Request key) {
    _cache.remove(key);
    return new Future.value(true);
  }
}

/// A [Cache] wrapper that honors a 'caching: false' [Request] local property.
class CachingFlagCacheWrapper implements Cache {

  final Cache delegate;

  CachingFlagCacheWrapper(this.delegate);
  Future<CachedEntity> get(Request key) {
    if (key.local['caching'] == false) {
      return new Future.value(null);
    }
    return delegate.get(key);
  }

  Future set(Request key, CachedEntity entity) {
    if (key.local['caching'] == false) {
      return new Future.value(true);
    }
    return delegate.set(key, entity);
  }

  Future invalidate(Request key) {
    if (key.local['caching'] == false) {
      return new Future.value(true);
    }
    return delegate.invalidate(key);
  }
}

/// Wraps a [Future]<[Cache]> and pretends to be synchronous, delaying cache calls
/// until the delegate cache is asynchronously loaded.
class AsyncCacheWrapper implements Cache {

  final Future<Cache> delegateFuture;
  Cache _delegate = null;

  AsyncCacheWrapper(Future<Cache> this.delegateFuture) {
    delegateFuture.then((delegate) {
      _delegate = delegate;
    });
  }

  /// Get an entity from the cache.
  Future<CachedEntity> get(Request key) {
    if (_delegate == null) {
      return delegateFuture.then((delegate) {
        return delegate.get(key);
      });
    }
    return _delegate.get(key);
  }

  /// Set an entity in the cache.
  Future set(Request key, CachedEntity entity) {
    if (_delegate == null) {
      return delegateFuture.then((delegate) {
        return delegate.set(key, entity);
      });
    }
    return _delegate.set(key, entity);
  }

  /// Invalidate an entity in the cache.
  Future invalidate(Request key) {
    if (_delegate == null) {
      return delegateFuture.then((delegate) {
        return delegate.invalidate(key);
      });
    }
    return _delegate.invalidate(key);
  }
}

class CachingRequestHandler extends RequestHandler {

  final delegate;
  final cache;
  var clock;

  CachingRequestHandler(RequestHandler this.delegate, Cache this.cache,
      {Clock clock: null}) {
    if (clock == null) {
      clock = const Clock();
    }
    this.clock = clock;
  }

  Stream<Response> handle(Request request, Trace trace) {
    // Handle non-cachable requests.
    if (!request.isCachable) {
      // Delegate directly. This doesn't cache the response.
      return delegate.handle(request, trace);
    }

    if (request.local.containsKey('noRpcAge')) {
      // Cache request and delegated request need to happen serially.
      return cache.get(request).then((cachedEntity) {
        if (response == null) {
          request.local['streamy.foundInCache'] = false;
          trace.record(new CacheMissEvent());
          // Delegate via [_delegateRequest] to cache the response.
          return _delegateRequest(request, trace).stream;
        }
        trace.record(new CacheHitEvent());
        request.local['streamy.foundInCache'] = true;

        // Check the age of the entity against the noRpcAge parameter value.
        var now = clock.now().millisecondsSinceEpoch;
        if (now - cachedEntity.ts <= request.local['noRpcAge']) {
          // The entity is young enough to be the primary response.
          return new Stream.fromIterable(
              [_toCachedResponse(cachedEntity, authority: Authority.PRIMARY)]);
        }
        // Make the RPC request.
        var sink = _delegateRequest(request, trace);
        // Add the cached entity first.
        sink.add(_toCachedResponse(cachedEntity));
        return sink.stream;
      });
    } else {
      // Make a normal (parallel) cache request. The cache request is fired
      // first to put it ahead of an instantaneous backend in the event loop.
      var sink;
      cache.get(request).then((cachedEntity) {
        if (cachedEntity != null) {
          sink.add(_toCachedResponse(cachedEntity));
        }
      });
      sink = _delegateRequest(request, trace);
      return sink.stream;
    }
  }

  _toCachedResponse(cached, {authority: Authority.SECONDARY}) => new Response(
      cached.entity, Source.CACHE, cached.ts, authority: authority);

  StreamController<Response> _delegateRequest(Request request, Trace trace) {
    var sub;
    var sink = new StreamController<Response>(onCancel: () => sub.cancel());
    sub = delegate
      .handle(request, trace)
      .listen((response) {
        // Intercept the request and cache it.
        cache.set(request.cacheKey(),
            new CachedEntity(response.entity, response.ts));
        sink.add(response);
      })
      ..onError(sink.addError)
      ..onDone(sink.close);
    return sink;
  }

  StreamSubscription<Response> _bridgeDelegatedRequest(
      Request request, Trace trace, StreamController bridge) =>
    delegate.handle(request, trace).listen(bridge.add)
      ..onError(bridge.addError)
      ..onDone(bridge.close);
}



class CacheHitEvent implements TraceEvent {
  factory CacheHitEvent() => const CacheHitEvent._private();

  const CacheHitEvent._private();

  String toString() => 'streamy.cache.hit';
}

class CacheMissEvent implements TraceEvent {
  factory CacheMissEvent() => const CacheMissEvent._private();

  const CacheMissEvent._private();

  String toString() => 'streamy.cache.miss';
}