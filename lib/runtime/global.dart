part of streamy.runtime;

/// A function which represents a synthetic property on an [Entity]. It computes the value of the
/// property given an [Entity].
typedef dynamic EntityGlobalFn(entity);

/// Memoize an [EntityGlobalFn] so it only runs once per entity. This is done using an [Expando]
/// to ensure GC safety.
EntityGlobalFn _memoizeGlobalFn(EntityGlobalFn fn) {
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
  GlobalRegistration._internal(this.fn, this.dependencies);

  factory GlobalRegistration(EntityGlobalFn fn, List dependencies, bool memoize) {
    if (dependencies != null) {
      if (memoize) {
        throw new ArgumentError('Memoized function should not have dependencies.');
      }
      dependencies.forEach(_validateDep);
    }
    if (memoize) fn = _memoizeGlobalFn(fn);
    return new GlobalRegistration._internal(fn, dependencies);
  }

  static void _validateDep(dep) {
    if (dep is String || (dep is Function && smoke.minArgs(dep) < 2) || dep is Stream) {
      return;
    }
    throw new ArgumentError('Invalid dep type: ${dep.runtimeType} ($dep)');
  }
}

abstract class _FakeMap {
  bool get isEmpty => throw "Not implemented";
  bool get isNotEmpty => throw "Not implemented";
  Iterable get keys => throw "Not implemented";
  Iterable get values => throw "Not implemented";
  int get length => throw "Not implemented";
  operator[]=(_a, _b) => throw "Not implemented";
  addAll(_) => throw "Not implemented";
  clear() => throw "Not implemented";
  bool containsValue(Object _) => throw "Not implemented";
  forEach(_) => throw "Not implemented";
  putIfAbsent(_a, _b) => throw "Not implemented";
  remove(_) => throw "Not implemented";
}

/// A view of globals as they relate to a specific [Entity]. Implements
/// observability based on dependencies of the globals involved.
abstract class GlobalView extends Observable with _FakeMap implements Map {
  
  static Map<Type, Map<String, GlobalRegistration>> typeToGlobals = {};
  /// A real global view backed by a map of registered globals.
  factory GlobalView(HasGlobal entity) => new _GlobalViewImpl(entity,
      typeToGlobals.putIfAbsent(entity.streamyType, () => {}));

  /// A global view that doesn't have any globals.
  factory GlobalView.empty() => new _EmptyGlobalView();

  bool containsKey(Object key);
  operator[](Object key);
  
  static void register(Type type, String name, GlobalRegistration global) {
    typeToGlobals.putIfAbsent(type, () => {})[name] = global;
  }

  static void registerAll(Iterable<Type> types, String name,
      GlobalRegistration global) {
    types.forEach((Type type) {
      typeToGlobals.putIfAbsent(type, () => {})[name] = global;
    });
  }
}

class _GlobalViewImpl extends ChangeNotifier with _FakeMap implements GlobalView {

  var _entity;
  Map<String, GlobalRegistration> _globals;
  var _changeController;
  var _changesSub;
  var _depSubs = [];

  _GlobalViewImpl(this._entity, this._globals);

  Stream<List<ChangeRecord>> get changes {
    if (_changeController == null) {
      _changeController = new StreamController<List<ChangeRecord>>.broadcast(
          sync: true, onListen: _onChangeListener, onCancel: _onChangeCancelled);
    }
    return _changeController.stream;
  }

  bool containsKey(Object key) => _globals.containsKey(key);
  operator[](Object key) {
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
            stream = _entity.changes.where(
                (changes) => changes.map((change) => change.key).contains(dep));
          } else if (dep is Function && smoke.canAcceptNArgs(dep, 1)) {
            stream = dep(_entity);
          } else if (dep is Function && smoke.canAcceptNArgs(dep, 0)) {
            stream = dep();
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
class _EmptyGlobalView extends Object with _FakeMap implements GlobalView {

  static final _singleton = new _EmptyGlobalView._useFactoryInstead();

  factory _EmptyGlobalView() => _singleton;

  _EmptyGlobalView._useFactoryInstead();

  bool containsKey(Object key) => false;
  operator[](Object key) => null;
  _entityChanged() {}

  Stream<List<ChangeRecord>> get changes {
    var c = new StreamController();
    c.close();
    return c.stream;
  }

  bool deliverChanges() => false;

  bool get hasObservers => false;

  void notifyChange(ChangeRecord record) {}

  notifyPropertyChange(Symbol field, Object oldValue, Object newValue) {}
}
