library streamy.trait.base.podo;

import 'dart:mirrors';
import 'package:streamy/streamy.dart' as streamy;

class PodoBase implements streamy.Entity {
  var _instanceMirrorImpl;
  
  InstanceMirror get _mirror {
    if (_instanceMirrorImpl == null) {
      _instanceMirrorImpl = reflect(this);
    }
    return _instanceMirrorImpl;
  }
  Map<Symbol, MethodMirror> get _members => _mirror.type.instanceMembers;
  
  
  containsKey(String key) {
    if (key.startsWith('_')) {
      return false;
    }
    s = new Symbol(key);
    if (_members.containsKey(s) && _members[s].isGetter) {
      return true;
    }
  }

  operator[](String key) => _mirror.getField(new Symbol(key)).reflectee;
  operator[]=(String key, value) {
    _mirror.setField(new Symbol(key), value);
  }
  
  remove(String key) {
    var value = this[key];
    this[key] = null;
    return value;
  }
}
