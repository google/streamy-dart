library streamy.trait.local;

import 'package:observe/observe.dart' as observe;

class Local {
  observe.ObservableMap<String, dynamic> _local;
  
  operator[](String key) => key == 'local' ? local : super[key];
  
  observe.ObservableMap<String, dynamic> get local {
    if (_local == null) {
      _local = new observe.ObservableMap<String, dynamic>();
    }
    return _local;
  }
}
