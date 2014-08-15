library streamy.trait.base.map;

import 'package:streamy/streamy.dart' as streamy;

class IsMap implements Map {

  // Methods provided by DynamicAccess

  Iterable<String> get keys => super.keys;
  bool containsKey(String key) => super.containsKey(key);
  operator[](String key) => super[key];
  operator[]=(String key, value) {
    super[key] = value;
  }
  remove(String key) => super.remove(key);

  // Map methods implemented via DynamicAccess

  bool containsValue(Object value) {
    for (String key in keys) {
      if (this[key] == value) {
        return true;
      }
    }
    return false;
  }

  putIfAbsent(String key, ifAbsent()) {
    if (!containsKey(key)) {
      var newVal = ifAbsent();
      this[key] = newVal;
      return newVal;
    }
    return this[key];
  }

  void addAll(Map<String, dynamic> other) {
    other.forEach((k, v) {
      this[k] = v;
    });
  }

  void clear() {
    for (String key in new List.from(keys)) {
      this.remove(key);
    }
  }

  void forEach(void f(String key, dynamic value)) {
    for (String key in keys) {
      f(key, this[key]);
    }
  }

  Iterable get values => keys.map((String key) => this[key]);

  int get length => keys.length;

  bool get isEmpty => keys.isEmpty;

  bool get isNotEmpty => keys.isNotEmpty;
}
