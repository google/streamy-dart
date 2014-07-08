part of streamy.runtime;

abstract class DynamicAccess {
  Iterable<String> get keys;
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
