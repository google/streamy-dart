part of streamy.runtime;

class CachedEntity<T> {
  final T entity;
  final int ts;

  CachedEntity(this.entity, this.ts);
}

/// A [Future] based [Cache] that's backed by a [Map].
class AsyncMapCache<T> implements Cache<HttpRequest, CachedEntity<T>> {

  var _cache = new Map<HttpRequest, CachedEntity<T>>();

  Future<CachedEntity<T>> get(key) {
    if (_cache.containsKey(key)) {
      return new Future.value(_cache[key]);
    }
    return new Future.value(null);
  }

  Future set(HttpRequest key, CachedEntity<T> value) {
    _cache[key] = value;
    return new Future.value(true);
  }

  Future invalidate(HttpRequest key) {
    _cache.remove(key);
    return new Future.value(true);
  }
}

/// A [Cache] wrapper that honors a 'caching: false' [HttpRequest] local property.
class CachingFlagCacheWrapper<T> implements Cache<HttpRequest, CachedEntity<T>> {

  final Cache<HttpRequest, CachedEntity<T>> delegate;

  CachingFlagCacheWrapper(this.delegate);

  Future<CachedEntity<T>> get(HttpRequest key) {
    if (key.local['caching'] == false) {
      return new Future.value(null);
    }
    return delegate.get(key);
  }

  Future set(HttpRequest key, CachedEntity<T> entity) {
    if (key.local['caching'] == false) {
      return new Future.value(true);
    }
    return delegate.set(key, entity);
  }

  Future invalidate(HttpRequest key) {
    if (key.local['caching'] == false) {
      return new Future.value(true);
    }
    return delegate.invalidate(key);
  }
}

/// Wraps a [Future]<[Cache]> and pretends to be synchronous, delaying cache calls
/// until the delegate cache is asynchronously loaded.
class AsyncCacheWrapper<T> implements Cache<HttpRequest, CachedEntity<T>> {

  final Future<Cache<HttpRequest, CachedEntity<T>>> delegateFuture;
  Cache<HttpRequest, CachedEntity<T>> _delegate = null;

  AsyncCacheWrapper(Future<Cache<HttpRequest, CachedEntity<T>>> this.delegateFuture) {
    delegateFuture.then((delegate) {
      _delegate = delegate;
    });
  }

  /// Get an entity from the cache.
  Future<CachedEntity<T>> get(HttpRequest key) {
    if (_delegate == null) {
      return delegateFuture.then((delegate) {
        return delegate.get(key);
      });
    }
    return _delegate.get(key);
  }

  /// Set an entity in the cache.
  Future set(HttpRequest key, CachedEntity<T> entity) {
    if (_delegate == null) {
      return delegateFuture.then((delegate) {
        return delegate.set(key, entity);
      });
    }
    return _delegate.set(key, entity);
  }

  /// Invalidate an entity in the cache.
  Future invalidate(HttpRequest key) {
    if (_delegate == null) {
      return delegateFuture.then((delegate) {
        return delegate.invalidate(key);
      });
    }
    return _delegate.invalidate(key);
  }
}

class CachingRequestHandler<T> extends RequestHandler {

  final delegate;
  final cache;
  var clock;

  CachingRequestHandler(RequestHandler this.delegate,
      Cache<HttpRequest, CachedEntity<T>> this.cache, {Clock clock: null}) {
    if (clock == null) {
      clock = const Clock();
    }
    this.clock = clock;
  }

  @override
  Stream<Response> handle(HttpRequest request, Trace trace) {
    // Handle non-cachable requests.
    if (!request.isCachable) {
      // Delegate directly. This doesn't cache the response.
      return delegate.handle(request, trace);
    }

    StreamController<Response> sink;
    if (request.local.containsKey('noRpcAge')) {
      sink = new StreamController<Response>();
      // Cache request and delegated request need to happen serially.
      cache.get(request).then((cachedEntity) {
        if (cachedEntity == null) {
          request.local['streamy.foundInCache'] = false;
          trace.record(new CacheMissEvent());
          // Delegate via [_delegateRequest] to cache the response.
          _delegateRequest(request, trace).stream.pipe(sink);
          return null;
        }
        trace.record(new CacheHitEvent());
        request.local['streamy.foundInCache'] = true;

        // Check the age of the entity against the noRpcAge parameter value.
        var now = clock.now().millisecondsSinceEpoch;
        if (now - cachedEntity.ts <= request.local['noRpcAge']) {
          // The entity is young enough to be the primary response.
          sink.add(_toCachedResponse(cachedEntity,
              authority: Authority.PRIMARY));
          sink.close();
        } else {
          // Add the cached entity first.
          sink.add(_toCachedResponse(cachedEntity));
          // Make the RPC request.
          _delegateRequest(request, trace).stream.pipe(sink);
        }
      });
    } else {
      // Make a normal (parallel) cache request. The cache request is fired
      // first to put it ahead of an instantaneous backend in the event loop.
      cache.get(request).then((cachedEntity) {
        if (cachedEntity != null) {
          trace.record(new CacheHitEvent());
          sink.add(_toCachedResponse(cachedEntity));
        } else {
          trace.record(new CacheMissEvent());
        }
      });
      sink = _delegateRequest(request, trace);
    }
    return sink.stream;
  }

  _toCachedResponse(cached, {authority: Authority.SECONDARY}) => new Response(
      cached.entity, Source.CACHE, cached.ts, authority: authority);

  StreamController<Response> _delegateRequest(HttpRequest request, Trace trace) {
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
