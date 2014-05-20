library streamy.trait.local;

import 'package:observe/observe.dart' as observe;

class Local {
  observe.ObservableMap<String, dynamic> _local;
  
  operator[](String key) => key == 'local' ? local : super[key];
  operator[]=(String key, value) {
    if (key == 'local') {
      throw new ArgumentError('"local" field is reserved');
    }
    super[key] = value;
  }
  
  observe.ObservableMap<String, dynamic> get local {
    if (_local == null) {
      _local = new observe.ObservableMap<String, dynamic>();
    }
    return _local;
  }
}
