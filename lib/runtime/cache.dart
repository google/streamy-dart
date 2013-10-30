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