library streamy.trait.global;

import 'package:streamy/streamy.dart' as streamy;

class Global {

  var _global;
  
  operator[](String key) {
    if (key == "global") {
      return global;
    }
    return super[key];
  }
  
  streamy.GlobalView get global {
    if (_global == null) {
      _global = new streamy.GlobalView(this);
    }
    return _global;
  }
}
