part of streamy.runtime;

/// Wraps an [Entity] and delegates to it. This is the base class for all
/// generated entities.
abstract class EntityWrapper extends Entity implements Observable {

  final Entity _delegate;

  /// A function which clones the subclass of this [EntityWrapper].
  final EntityWrapperCloneFn _cloneFn;

  final Map<String, GlobalRegistration> _globals;

  static const _GLOBAL_PREFIX = 'global.';

  /// Constructor which takes the wrapped [Entity] and an [EntityWrapperCloneFn]
  /// from the subclass. This clone function returns a new instance of the
  /// subclass given a cloned (or patched) instance of the wrapped [Entity].
  EntityWrapper.wrap(this._delegate, this._clone,
      {Map<String, GlobalRegistration> globals:
          const <String, GlobalRegistration>{} })
            : super.base(), _globals = globals;

  /// Get the root entity for this wrapper. Wrappers can compose other wrappers,
  /// so this will follow that chain until the root [Entity] is discovered.
  /// (We must go deeper!)
  Entity get _root {
    if (_delegate is EntityWrapper) {
      EntityWrapper wrapper = _delegate;
      return wrapper._root;
    }
    return _delegate;
  }

  GlobalView _globalView;

  GlobalView get global {
    if (_globalView == null) {
      _globalView = new GlobalView(this, _globals);
    }
    return _globalView;
  }

  /// Subclasses should override [clone] to return an instance of the
  /// appropriate type. Note: failure to override [clone] when extending
  /// a subclass of [EntityWrapper] can result in broken behavior.
  Entity clone() => _cloneFn(_delegate.clone());

  /// Subclasses should override [patch] to return an instance of the
  /// appropriate type. Note: failure to override [patch] when extending
  /// a subclass of [EntityWrapper] can result in broken behavior.
  Entity patch() => _cloneFn(_delegate.patch());

  bool get isFrozen => _delegate.isFrozen;

  void _freeze() => _delegate._freeze();

  bool containsKey(String key) => _delegate.containsKey(key);

  Iterable<String> get fieldNames => _delegate.fieldNames;

  dynamic remove(String key) => _delegate.remove(key);

  dynamic operator[](String key) {
    if (key.startsWith(_GLOBAL_PREFIX)) {
      var property = key.substring(_GLOBAL_PREFIX.length);
      return global[property];
    } else if (key == 'global') {
      return global;
    }
    return _delegate[key];
  }

  void operator[]=(String key, value) {
    _delegate[key] = value;
  }

  Map toJson() => _delegate.toJson();

  Map<String, dynamic> get local => _delegate.local;

  Type get streamyType;

  Observable get _observableDelegate {
    if (_delegate is! Observable) {
      throw new StateError('Delegate object of type ${_delegate.runtimeType} '
                           'is not observable.');
    }
    return _delegate as Observable;
  }

  Stream<List<ChangeRecord>> get changes => _observableDelegate.changes;
  bool deliverChanges() => _observableDelegate.deliverChanges();
  void notifyChange(ChangeRecord record) {
    _observableDelegate.notifyChange(record);
  }
  notifyPropertyChange(Symbol field, Object oldValue, Object newValue) =>
      _observableDelegate.notifyPropertyChange(field, oldValue, newValue);
  bool get hasObservers => _observableDelegate.hasObservers;
}

/// A function that clones an [EntityWrapper], given a clone of its wrapped
/// [Entity]. This is part of the private interface between [EntityWrapper]
/// and its subclasses.
typedef EntityWrapper EntityWrapperCloneFn(Entity delegateClone);
