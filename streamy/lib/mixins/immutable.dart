library streamy.trait.immutable;

import 'package:streamy/streamy.dart' as streamy;

class Immutability implements streamy.Freezeable {
  
  bool _isFrozen = false;
  
  operator[]=(String key, value) {
    if (_isFrozen) {
      throw new Exception("Frozen.");
    }
    super[key] = value;
  }
  
  remove(String key) {
    if (_isFrozen) {
      throw new Exception("Frozen.");
    }
    return super.remove(key);
  }
  
  void freeze() {
    _isFrozen = true;
    keys.forEach((key) {
      var value = this[key];
      if (value != null && value is streamy.Freezeable) {
        value.freeze();
      }
    });
  }
  
  bool get isFrozen => _isFrozen;
}
