part of streamy.runtime;

/// Defines interface for an asynchronous cache.
abstract class Cache {

  /// Get an entity from the cache.
  Future<Entity> get(Request key);

  /// Set an entity in the cache.
  Future set(Request key, Entity entity);

  /// Invalidate an entity in the cache.
  Future invalidate(Request key);
}

/// A [Future] based [Cache] that's backed by a [Map].
class AsyncMapCache implements Cache {

  Map _cache = new Map();

  Future get(key) {
    if (_cache.containsKey(key)) {
      return new Future.value(_cache[key]);
    }
    return new Future.value(null);
  }

  Future set(key, value) {
    _cache[key] = value;
    return new Future.value(true);
  }

  Future invalidate(key) {
    _cache.remove(key);
    return new Future.value(true);
  }
}

class AsyncCacheWrapper implements Cache {
  
  final Future<Cache> delegateFuture;
  Cache _delegate = null;
 
  AsyncCacheWrapper(Future<Cache> this.delegateFuture) {
    delegateFuture.then((delegate) {
      _delegate = delegate;
    });
  }
  
  /// Get an entity from the cache.
  Future<Entity> get(Request key) {
    if (_degelate == null) {
      return delegateFuture.then((delegate) {
        return delegate.get(key);
      });
    }
    return _delegate.get(key);
  }

  /// Set an entity in the cache.
  Future set(Request key, Entity entity) {
    if (_degelate == null) {
      return delegateFuture.then((delegate) {
        return delegate.set(key, entity);
      });
    }
    return _delegate.set(key, entity);
  }

  /// Invalidate an entity in the cache.
  Future invalidate(Request key) {
    if (_degelate == null) {
      return delegateFuture.then((delegate) {
        return delegate.invalidate(key);
      });
    }
    return _delegate.invalidate(key);
  }
  
}