library streamy.trait.lazy;

import 'package:streamy/streamy.dart' as streamy;

class Lazy {
  
  operator[](String key) {
    var value = super[key];
    if (value is streamy.LazyValue) {
      value = value.unwrap();
      super[key] = value;
    }
    return value;
  }
  
  remove(String key) {
    var value = super.remove(key);
    if (value is streamy.LazyValue) {
      value = value.unwrap();
    }
    return value;
  }
}
