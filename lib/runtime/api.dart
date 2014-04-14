part of streamy.runtime;

abstract class Request {
  Root get root;
}

abstract class CacheableRequest {
  int get hashCode;
  bool equals(other);
}

abstract class DynamicAccess {
  Iterable<String> keys;
  bool containsKey(String key);
  operator[](String key);
  void operator[]=(String key, value);
  remove(String key);
}

abstract class Cloneable {
  dynamic clone();
}

abstract class Patchable {
  dynamic patch();
}

abstract class Freezeable {
  bool get isFrozen;
  void freeze();
}
