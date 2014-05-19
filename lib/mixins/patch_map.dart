library streamy.traits.patch;

import 'package:observe/observe.dart' as observe;
import 'package:streamy/streamy.dart' as streamy;

class Patch implements streamy.Patchable {
  
  Map _original = null;

  dynamic patch();
  
  patchInto(streamy.DynamicAccess other) {
    if (_original == null) {
      _original = {};
    }
    keys.forEach((key) {
      var vOld = _original[key];
      var vNew = this[key];
      if (!_patchCheckEqual(vOld, vNew)) {
        other[key] = vOld == null ? vNew : _patchHelper(vNew);
      }
    });
    return other;
  }
  
  void setOriginal() {
    _original = getMap(this);
    if (this is! streamy.Freezeable || !isFrozen) {
      // Need to clone original if not frozen. Hope it's cloneable.
      _original = _original.clone();
    }
  }
  
  copyInto(streamy.DynamicAccess other) =>
    super.copyInto(other)
      .._original = _original;
  
  void freeze() {
    if (this is streamy.Freezeable) {
      super.freeze();
    }
    setOriginal();
  }
  

  _patchHelper(v) {
    if (v == null) {
      return null;
    } else if (v is streamy.Patchable) {
      return v.patch();
    } else if (v is Map) {
      var c = new observe.ObservableMap();
      v.forEach((k, v) {
        c[k] = _patchHelper(v);
      });
      return c;
    } else if (v is List) {
      // PATCH semantics dictate that arrays are replaced and not merged. Hence,
      // the array contents need to be clones, not patches.
      return new observe.ObservableList.from(v.map((value) => _cloneHelper(value)));
    } else {
      return v;
    }
  }

  bool _patchCheckEqual(a, b) {
    if (identical(a, b)) {
      return true;
    }
    if (a == null) {
      return b == null;
    } else if (a is List) {
      if (b is! List || b.length != a.length) {
        return false;
      }
      for (var i = 0; i < a.length; i++) {
        if (!_patchCheckEqual(a[i], b[i])) {
          return false;
        }
      }
      return true;
    } else if (a is streamy.DynamicAccess) {
      return (b is streamy.DynamicAccess) && streamy.EntityUtils.deepEquals(a, b);
    }
    return a == b;
  }
}
