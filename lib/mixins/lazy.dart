library streamy.trait.lazy;

import 'package:streamy/streamy.dart' as streamy;

class Lazy {
  
  operator[](String key) {
    var value = super[key];
    if (value is streamy.Lazy) {
      value = value.resolve();
      super[key] = value;
    }
    return value;
  }
  
  remove(String key) {
    var value = super.remove(key);
    if (value is streamy.Lazy) {
      value = value.resolve();
    }
    return value;
  }
}
