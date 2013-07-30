part of streamy.runtime;

/// Wraps an [Entity] and delegates to it. This is the base class for all
/// generated entities.
abstract class EntityWrapper extends Entity {

  final Entity _delegate;

  /// A function which clones the subclass of this [EntityWrapper].
  final EntityWrapperCloneFn _clone;

  /// Constructor which takes the wrapped [Entity] and an [EntityWrapperCloneFn]
  /// from the subclass. This clone function returns a new instance of the
  /// subclass given a cloned instance of the wrapped [Entity].
  EntityWrapper.wrap(this._delegate, this._clone) : super.base();

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
  Entity clone() => _clone(_delegate.clone());

  bool containsKey(String key) => _delegate.containsKey(key);

  Iterable<String> get fieldNames => _delegate.fieldNames;

  dynamic remove(String key) => _delegate.remove(key);

  dynamic operator[](String key) => _delegate[key];

  void operator[]=(String key, value) {
    _delegate[key] = value;
  }

  // Equality is tricky - we could be comparing different levels of nested
  // wrapping. Thus, we need to unwrap until we get to non-wrappers.
  bool operator==(other) =>
      other is EntityWrapper && other.streamyType == streamyType &&
      other._root == _root;

  int get hashCode => _delegate.hashCode;

  Map toJson() => _delegate.toJson();

  LocalDataMap get local => _delegate.local;

  Type get streamyType;
}

/// A function that clones an [EntityWrapper], given a clone of its wrapped
/// [Entity]. This is part of the private interface between [EntityWrapper]
/// and its subclasses.
typedef EntityWrapper EntityWrapperCloneFn(Entity delegateClone);
