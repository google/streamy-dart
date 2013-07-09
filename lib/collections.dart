library streamy.collections;

import 'dart:collection';

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

/// A [Map] which supports being compared to another [Map].
class ComparableMap<K, V> implements Map<K, V> {

  final Map<K, V> _delegate = new Map<K, V>();

  ComparableMap();
  factory ComparableMap.from(Map<K,V> other) {
    return new ComparableMap<K, V>()..addAll(other);
  }

  V operator[](K key) => _delegate[key];
  void operator[]=(K key, V value) {
    _delegate[key] = value;
  }

  bool get isEmpty => _delegate.isEmpty;
  bool get isNotEmpty => _delegate.isNotEmpty;
  Iterable<K> get keys => _delegate.keys;
  int get length => _delegate.length;
  Iterable<V> get values => _delegate.values;

  void addAll(Map<K, V> other) {
    _delegate.addAll(other);
  }

  void clear() {
    _delegate.clear();
  }


  bool containsKey(K key) => _delegate.containsKey(key);
  bool containsValue(V value) => _delegate.containsValue(value);
  void forEach(void action(K key, V value)) {
    _delegate.forEach(action);
  }

  V putIfAbsent(K key, V ifAbsent()) => _delegate.putIfAbsent(key, ifAbsent);
  V remove(K key) => _delegate.remove(key);
  String toString() => _delegate.toString();

  bool operator==(other) => compareMapObjects(this, other);

  int get hashCode => hashCodeForMap(this);
}

class ComparableList<V> extends ListBase<V> {

  final List<V> _delegate = new List<V>();

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

/// A [Map] of keys to [Set]s (that does not implement the [Map] interface).
class SetMultimap<K, V> {

  /// Backing map.
  Map<K, Set<V>> _data = new Map();

  /// Get the [Set] for the given key.
  Set<V> operator[] (K key) {
    if (!_data.containsKey(key)) {
      _data[key] = new Set();
    }
    return _data[key];
  }

  /// Remove the [Set] for the given key.
  Set<V> remove(K key) => _data.remove(key);

  /// Check if a given key is contained.
  bool containsKey(K key) => _data.containsKey(key);

  /// Remove a value from the [Set] for the given key (and delete the [Set]
  /// from the backing map if it's empty).
  bool removeValue(K key, V value) {
    if (!_data.containsKey(key)) {
      return false;
    }
    _data[key].remove(value);
    if (_data[key].isEmpty) {
      _data.remove(key);
    }
    return true;
  }

  /// Remove all of the given values from the [Set] for the given key (and
  /// delete the [Set] from the backing map if it's empty).
  bool removeValues(K key, Iterable<V> values) {
    if (!_data.containsKey(key)) {
      return false;
    }
    _data[key].removeAll(values);
    if (_data[key].isEmpty) {
      _data.remove(key);
    }
    return true;
  }

  String toString() => '{SetMultimap ${_data.toString()}}';
}
