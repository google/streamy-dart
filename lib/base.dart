library streamy.base;

import 'package:streamy/streamy.dart' as streamy;
import 'dart:async';
import 'package:observe/observe.dart' as observe;

abstract class EB_MapBase extends Object implements streamy.Entity {
  var _map;
  
  Iterable<String> get keys => _map.keys;
  bool containsKey(String key) => _map.containsKey(key);
  operator[](String key) => _map[key];
  operator[]=(String key, value) {
    _map[key] = value;
  }
  remove(String key) => _map.remove(key);
}

abstract class EB_CopyClone extends EB_MapBase implements streamy.Cloneable {

  dynamic clone();
  
  copyInto(other) {
    for (var key in keys) {
      other[key] = _cloneHelper(super[key]);
    }
    return other;
  }
  
  void _cloneHelper(value) {
    if (value is streamy.Cloneable) {
      return value.clone();
    } else if (value is List) {
      return value.map(_cloneHelper).toList();
    } else {
      return value;
    }
  }
}

abstract class EB_Observability extends EB_CopyClone implements observe.Observable {
  
  var _pendingChanges;
  var _changesImpl;

  StreamController<List<observe.ChangeRecord>> get _changes {
    if (_changesImpl == null) {
      _changesImpl = new StreamController<List<observe.ChangeRecord>>.broadcast(sync: true);
    }
    return _changesImpl;
  }
  
  bool deliverChanges() {
    if (_pendingChanges == null || _changesImpl == null || _pendingChanges.isEmpty) {
      return false;
    }
    var copy = _pendingChanges.toList(growable: false);
    _pendingChanges.clear();
    _changes.add(copy);
  }

  notifyChange(observe.ChangeRecord record) {
    if (_pendingChanges == null) {
      _pendingChanges = <observe.ChangeRecord>[];
    }
    if (_pendingChanges.isEmpty) {
      scheduleMicrotask(deliverChanges);
    }
    _pendingChanges.add(record);
  }

  notifyPropertyChange(Symbol field, Object oldValue, Object newValue) => newValue;
  
  Stream<List<observe.ChangeRecord>> get changes => _changes.stream;

  bool get hasObservers => _changesImpl != null && _changes.hasListener;
  
  operator[]=(String key, value) {
    if (hasObservers) {
      if (containsKey(key)) {
        notifyChange(new observe.MapChangeRecord<String, dynamic>(key, super[key], value));
      } else {
        notifyChange(new observe.MapChangeRecord<String, dynamic>.insert(key, value));
      }
    }
    if (value is List && value is! observe.ObservableList && value != null) {
      value = new observe.ObservableList.from(value);
    }
    super[key] = value;
  }

  remove(String key) {
    if (hasObservers) {
      notifyChange(new observe.MapChangeRecord<String, dynamic>.remove(key, super[key]));
    }
    return super.remove(key);
  }
}

abstract class EB_Global extends EB_Observability {

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

abstract class EB_DotAccess extends EB_Global {
  
  _resolve(List<String> pieces, start) {
    var cur = start;
    for (var i = 0; i < pieces.length; i++) {
      cur = cur[pieces[i]];
      if (cur == null) {
        return null;
      }
    }
    return cur;
  }
  
  bool containsKey(String key) {
    if (!key.contains('.')) {
      return super.containsKey(key);
    }
    var pieces = key.split('.');
    var last = pieces.removeLast();
    var target = _resolve(pieces, this);
    if (target == null) {
      return false;
    }
    return target.containsKey(last);
  }

  operator[](String key) {
    if (!key.contains('.')) {
      return super[key];
    }
    var pieces = key.split('.');
    var last = pieces.removeLast();
    var target = _resolve(pieces, this);
    if (target == null) {
      return null;
    }
    return target[last];
  }

  operator[]=(String key, value) {
    if (!key.contains('.')) {
      super[key] = value;
      return;
    }
    var pieces = key.split('.');
    var last = pieces.removeLast();
    var target = _resolve(pieces, this);
    target[last] = value;
  }
  
  remove(String key) {
    if (!key.contains('.')) {
      return super.remove(key);
    }
    var pieces = key.split('.');
    var last = pieces.removeLast();
    var target = _resolve(pieces, this);
    return target.remove(last);
  }
}

abstract class EB_Local extends EB_DotAccess {
  observe.ObservableMap<String, dynamic> _local;
  
  operator[](String key) {
    if (key == "local") {
      return local;
    }
    return super[key];
  }
  
  observe.ObservableMap<String, dynamic> get local {
    if (_local == null) {
      _local = new observe.ObservableMap<String, dynamic>();
    }
    return _local;
  }
}

abstract class EB_Immutability extends EB_Local {
  
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
  }
  
  bool get isFrozen => _isFrozen;
}

class EntityBase extends EB_Immutability {}

void setMap(entity, map) {
  entity._map = map;
}

Map getMap(entity) => entity._map;
