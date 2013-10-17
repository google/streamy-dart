part of streamy.runtime;

/// Wraps an [Entity] and delegates to it. This is the base class for all
/// generated entities.
abstract class EntityWrapper extends Entity implements Observable {

  Entity _delegate;

  /// A function which clones the subclass of this [EntityWrapper].
  final EntityWrapperCloneFn _clone;
  
  bool _isCopyOnWrite;
  StreamController<List<ChangeRecord>> _cowChangesController;
  var _cowChangesSubscription;
  

  /// Constructor which takes the wrapped [Entity] and an [EntityWrapperCloneFn]
  /// from the subclass. This clone function returns a new instance of the
  /// subclass given a cloned instance of the wrapped [Entity].
  EntityWrapper.wrap(this._delegate, this._clone, {copyOnWrite: false}) : super.base(), _isCopyOnWrite = copyOnWrite {
    print('creating cow($copyOnWrite) wrapper of ${_delegate.runtimeType}');
  }

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

  StreamyEntityMetadata get streamy => _delegate.streamy;

  /// Subclasses should override [clone] to return an instance of the
  /// appropriate type. Note: failure to override [clone] when extending
  /// a subclass of [EntityWrapper] can result in broken behavior.
  Entity clone({bool mutable: true, bool copyOnWrite: false}) {
    if (copyOnWrite && !mutable) {
      throw new ArgumentError('Cannot make immutable copy-on-write clone.');
    } else if (!copyOnWrite) {
      return _clone(_delegate.clone(mutable: mutable));
    }
    // Cloning copy-on-write.
    return _clone(_delegate, copyOnWrite: true);
  }

  bool get isFrozen => _delegate.isFrozen && !_isCopyOnWrite;

  void _freeze() => _delegate._freeze();

  bool containsKey(String key) => _delegate.containsKey(key);

  Iterable<String> get fieldNames => _delegate.fieldNames;

  dynamic remove(String key) {
    if (_isCopyOnWrite) {
      _fulfillCopyOnWrite();
    }
    return _delegate.remove(key);
  }

  dynamic operator[](String key) => _delegate[key];

  void operator[]=(String key, value) {
    if (_isCopyOnWrite) {
      _fulfillCopyOnWrite();
    }
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

  Stream<List<ChangeRecord>> get changes {
    if (!_isCopyOnWrite) {
      return _delegate.changes;
    }
    if (_cowChangesController == null) {
      _cowChangesController = new StreamController<List<ChangeRecord>>.broadcast(sync: true, onCancel: () {
        _cowChangesSubscription.cancel();
        _cowChangesSubscription = null;
      });
      _subscribeToDelegateChanges();
    }
    return _cowChangesController.stream;
  }
  
  _subscribeToDelegateChanges() {
    _cowChangesSubscription = _delegate.changes.listen(_cowChangesController.add)
      ..onError(_cowChangesController.addError)
      ..onDone(_cowChangesController.close);
  }
  bool deliverChanges() => _observableDelegate.deliverChanges();
  void notifyChange(ChangeRecord record) {
    _observableDelegate.notifyChange(record);
  }
  bool get hasObservers => _observableDelegate.hasObservers;
  
  _fulfillCopyOnWrite() {
    _isCopyOnWrite = false;
    _delegate = _delegate.clone(mutable: true);
    
    if (_cowChangesSubscription != null) {
      _cowChangesSubscription.cancel();
      _subscribeToDelegateChanges();
    }
  }
}

/// A function that clones an [EntityWrapper], given a clone of its wrapped
/// [Entity]. This is part of the private interface between [EntityWrapper]
/// and its subclasses.
typedef EntityWrapper EntityWrapperCloneFn(Entity delegateClone, {bool copyOnWrite});
