library streamy.mixins.immutable;

import 'dart:collection' as col;
import 'package:fixnum/fixnum.dart' as fixnum;
import 'package:observe/observe.dart' as observe;
import 'package:streamy/streamy.dart' as streamy;

class Immutability implements streamy.Freezeable {
  
  bool _isFrozen = false;
  
  operator[]=(String key, value) {
    if (_isFrozen) {
      throw new UnsupportedError("Frozen.");
    }
    super[key] = value;
  }
  
  remove(Object key) {
    if (_isFrozen) {
      throw new UnsupportedError("Frozen.");
    }
    return super.remove(key);
  }
  
  void freeze() {
    _freezeHelper(this);
  }
  
  bool get isFrozen => _isFrozen;
}

dynamic _freezeHelper(dynamic object) {
  if (object is streamy.Freezeable && object._isFrozen) {
    // Already frozen, noop
    return object;
  }

  if (object is streamy.DynamicAccess || object is Map) {
    for (String key in object.keys) {
      object[key] = _freezeValue(object[key]);
    }
  } else if (object is List) {
    final frozenElements = object is observe.ObservableList
        ? new observe.ObservableList(object.length)
        : new List(object.length);
    for (int i = 0; i < object.length; i++) {
      frozenElements[i] = _freezeValue(object[i]);
    }
    if (object is observe.ObservableList) {
      object = new streamy.ObservableImmutableListView(frozenElements);
    } else {
      object = new col.UnmodifiableListView(frozenElements);
    }
  }

  if (object is streamy.Freezeable) {
    object._isFrozen = true;
  }

  return object;
}

/**
 * Chooses between [_freezeHelper] and [freeze] to freeze a value.
 *
 * Freezeables need to use [freeze] because it can be overridden.
 */
dynamic _freezeValue(dynamic object) {
  if (object is streamy.Freezeable) {
    object.freeze();
    return object;
  } else {
    return _freezeHelper(object);
  }
}
