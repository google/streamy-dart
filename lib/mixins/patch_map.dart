library streamy.traits.patch;

import 'package:streamy/streamy.dart' as streamy;

class Patch implements streamy.Patchable {
  
  Map _original = null;

  dynamic patch();
  
  void patchInto(streamy.DynamicAccess other) {
    if (_original == null) {
      _original = {};
    }
    keys.forEach((key) {
      if (_original.containsKey(key)) {
        var vOld = _original[key];
        var vNew = this[key];
        if (streamy.patchEqualsCheck(vOld, vNew)) {
          other[key] = vOld;
        }
      }
    });
  }
  
  void setOriginal() {
    _original = getMap(this);
    if (this is! streamy.Freezeable || !isFrozen) {
      // Need to clone original if not frozen. Hope it's cloneable.
      _original = _original.clone();
    }
  }
  
  void freeze() {
    if (this is streamy.Freezeable) {
      super.freeze();
    }
    setOriginal();
  }
}
