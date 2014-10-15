library streamy.trait.observable;

import 'dart:async';
import 'package:observe/observe.dart' as observe;

/// Adds observability to an entity.
class Observability implements observe.Observable {
  
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
    if (value != null && value is List && value is! observe.ObservableList) {
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
