part of streamy.runtime;

/// A function which represents a synthetic property on an [Entity]. It computes the value of the
/// property given an [Entity].
typedef dynamic EntityGlobalFn(entity);

typedef Stream GlobalStreamDepFn();
typedef Stream GlobalStreamEntityDepFn(entity);

/// Memoize an [EntityGlobalFn] so it only runs once per entity. This is done using an [Expando]
// to ensure GC safety.
EntityGlobalFn memoizeGlobalFn(EntityGlobalFn fn) {
  var expando = new Expando(fn.toString());
  return (entity) {
    var value = expando[entity];
    if (value == null) {
      value = fn(entity);
      expando[entity] = value;
    }
    return value;
  };
}

class GlobalRegistration {
  final EntityGlobalFn fn;
  final List dependencies;

  GlobalRegistration(this.fn, [this.dependencies = null]) {
    if (dependencies != null) {
      dependencies.forEach(_validateDep);
    }
  }

  _validateDep(dep) {
    if (dep is String || dep is GlobalStreamDepFn || dep is GlobalStreamEntityDepFn || dep is Stream) {
      return;
    }
    throw new ArgumentError('Invalid dep type: ${dep.runtimeType} ($dep)');
  }
}

/// A view of globals as they relate to a specific [Entity]. Implements observability based on
/// dependencies of the globals involved.
class GlobalView extends ChangeNotifier {

  Entity _entity;
  Map<String, GlobalRegistration> _globals;
  var _changeController;
  var _changesSub;
  var _depSubs = [];

  GlobalView(this._entity, this._globals);

  Stream<List<ChangeRecord>> get changes {
    if (_changeController == null) {
      _changeController = new StreamController<List<ChangeRecord>>.broadcast(
          sync: true, onListen: _onChangeListener, onCancel: _onChangeCancelled);
    }
    return _changeController.stream;
  }

  bool containsKey(String key) => _globals.containsKey(key);
  operator[](String key) {
    if (!_globals.containsKey(key)) {
      return null;
    }
    return _globals[key].fn(_entity);
  }

  _onChangeListener() {
    // Subscribe to change notifications.
    _changesSub = super.changes.listen(_changeController.add)
      ..onError(_changeController.addError)
      ..onDone(_changeController.close);

    // Subscribe to global dependencies.
    _globals.forEach((key, reg) {
      if (reg.dependencies != null && reg.dependencies.isNotEmpty) {
        reg.dependencies.forEach((dep) {
          var stream;
          if (dep is String) {
            stream =_entity.changes.where((changes) => changes.map((change) => change.key).contains(dep));
          } else if (dep is GlobalStreamDepFn) {
              stream = dep();
          } else if (dep is GlobalStreamEntityDepFn) {
            stream = dep(_entity);
          } else if (dep is Stream) {
            stream = dep;
          } else {
            throw new StateError('Unknown dependency type: $dep');
          }
          _depSubs.add(stream.listen((_) {
            notifyChange(new MapChangeRecord(key, null, null));
          }));
        });
      }
    });
  }

  _onChangeCancelled() {
    _changesSub.cancel();
    _depSubs.forEach((sub) => sub.cancel());
  }
}

/// A [GlobalView] for an [Entity] that does not have globals.
class EmptyGlobalView extends ChangeNotifier implements GlobalView {

  static EmptyGlobalView _singleton;

  factory EmptyGlobalView() {
    if (_singleton == null) {
      _singleton = new EmptyGlobalView._private();
    }
    return _singleton;
  }

  EmptyGlobalView._private();

  bool containsKey(String key) => false;
  operator[](String key) => null;
  _entityChanged() {}
}