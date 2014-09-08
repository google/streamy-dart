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
  
  remove(String key) {
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
 * Nested value can be primitive, in which case there's nothing to freeze,
 * other [streamy.Freezable], in which case we need to call its freeze method
 * to let it customize behavior (e.g. patch could take a snapshot to compare
 * with later), or it could be something else that hopefully can be handled by
 * [_freezeHelper].
 */
dynamic _freezeValue(dynamic object) {
  if (object is num || object is String || object is fixnum.Int64 ||
      object == null) {
    // Value objects don't need to be frozen.
    return object;
  }

  if (object is streamy.Freezeable) {
    object.freeze();
    return object;
  } else {
    return _freezeHelper(object);
  }
}
