library streamy.collections;

import 'dart:collection';

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
