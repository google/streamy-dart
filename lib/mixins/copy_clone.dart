library streamy.traits.clone.copy;

import 'package:streamy/streamy.dart' as streamy;

class CopyClone implements streamy.Cloneable {

  dynamic clone();
  
  copyInto(streamy.DynamicAccess other) {
    for (var key in keys) {
      other[key] = _cloneHelper(super[key]);
    }
    return other;
  }
  
  _cloneHelper(value) {
    if (value is streamy.Cloneable) {
      return value.clone();
    } else if (value is List) {
      return value.map(_cloneHelper).toList();
    } else {
      return value;
    }
  }
}
