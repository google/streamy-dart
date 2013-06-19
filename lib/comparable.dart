library comparable;

import "dart:collection";

abstract class MapComparability {

  /// Equality comparison with another [Map].
  operator==(other) {
    if (!(other is MapComparability)) {
      return false;
    }

    if (keys.length != other.keys.length) {
      return false;
    }

    for (var key in keys) {
      if (!other.containsKey(key)) {
        return false;
      }
      if (other[key] != this[key]) {
        return false;
      }
    }
    return true;
  }

  /// hashCode that treats the [Map] as a set of key-value pairs (no ordering).
  int get hashCode => keys.fold(0,
      (r, k) => r + 17 * k.hashCode + this[k].hashCode * (k.hashCode % 31));
}

/// A [HashMap] which supports being compared to another [Map].
class ComparableMap<K, V> extends HashMap<K, V> with MapComparability {

  ComparableMap() : super();
  factory ComparableMap.from(Map<K,V> other) {
    return new ComparableMap<K, V>()..addAll(other);
  }
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