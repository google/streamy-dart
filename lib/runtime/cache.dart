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