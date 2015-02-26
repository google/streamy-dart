library streamy.trait.global;

import 'package:streamy/streamy.dart' as streamy;

class Global implements streamy.HasGlobal {

  var _global;
  
  operator[](Object key) => key == 'global' ? global : super[key];
  
  streamy.GlobalView get global {
    if (_global == null) {
      _global = new streamy.GlobalView(this);
    }
    return _global;
  }
}
