library comparable;

import "dart:collection";

/// Helper method to compare two (ostensible) [Map]s
bool compareMapObjects(first, second) {
  if (first is! Map || second is! Map) {
    return false;
  }

  if (first.keys.length != second.keys.length) {
    return false;
  }

  for (var key in first.keys) {
    if (!second.containsKey(key)) {
      return false;
    }
    if (second[key] != first[key]) {
      return false;
    }
  }
  return true;
}

/// Helper method to compute the hash code for [Map]s.
int hashCodeForMap(Map map) => map.keys.fold(0,
      (r, k) => r + 17 * k.hashCode + map[k].hashCode * (k.hashCode % 31));

/// A [HashMap] which supports being compared to another [Map].
class ComparableMap<K, V> extends HashMap<K, V> {

  ComparableMap() : super();
  factory ComparableMap.from(Map<K,V> other) {
    return new ComparableMap<K, V>()..addAll(other);
  }

  bool operator==(other) => compareMapObjects(this, other);

  int get hashCode => hashCodeForMap(this);
}

class ComparableList<V> extends ListBase<V> {

  List<V> _delegate = new List<V>();

  ComparableList();

  ComparableList.from(Iterable<V> other) {
    _delegate.addAll(other);
  }

  int get length => _delegate.length;
  void set length(int l) {
    _delegate.length = l;
  }

  V operator[](int i) => _delegate[i];
  void operator[]=(int i, V v) {
    _delegate[i] = v;
  }

  bool operator==(other) {
    if (!(other is ComparableList)) {
      return false;
    }
    if (other.length != length) {
      return false;
    }
    for (var i = 0; i < length; i++) {
      if (this[i] != other[i]) {
        return false;
      }
    }
    return true;
  }

  int get hashCode => _delegate.fold(0, (h, v) => h * 17 + v.hashCode);
}