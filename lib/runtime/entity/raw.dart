part of streamy.runtime;

/// Parent of all data transfer objects. Provides map-like methods for
/// accessing field values.
class RawEntity extends Entity implements Map, Observable {

  RawEntity() : super.base() {
    _data = new ObservableMap();
  }

  RawEntity.fromMap(Map map) : super.base() {
    _data = toObservable(map);
  }
  
  RawEntity.wrapMap(ObservableMap map) : super.base() {
    _data = map;
  }

  bool _frozen = false;

  // Has this entity been frozen yet?
  bool get isFrozen => _frozen;

  /// Actual fields of the Apiary entity.
  ObservableMap _data;

  StreamyEntityMetadata _streamy;

  int get length => _data.length;

  void _freeze() {
    _frozen = true;
    _local = null;
    _freezeHelper(_data);
  }

  /// Metadata about this entity.
  StreamyEntityMetadata get streamy {
    if (_streamy == null) {
      _streamy = new StreamyEntityMetadata._private();
    }
    return _streamy;
  }

  ObservableMap<String, dynamic> _local;

  /// Local data.
  Map<String, dynamic> get local {
    if (_frozen) {
      return const {};
    }
    if (_local == null) {
      _local = new ObservableMap<String, dynamic>();
    }
    return _local;
  }

  /// Copy this entity (but not local data).
  RawEntity clone() => new RawEntity().._cloneFrom(this);

  /// Merge fields from an input map.
  _cloneFrom(RawEntity input) {
    _data = _clone(input._data);
    if (input.streamy != null) {
      _streamy = new StreamyEntityMetadata._private()
        .._mergeFrom(input.streamy);
    }
  }

  /// Data field getter.
  dynamic operator[](String key) {
    if (key == 'local') {
      return local;
    }
    return key.contains('.') ? _walk(this, key.split('.')) : _data[key];
  }

  /// Data field setter.
  void operator[]=(String key, dynamic value) {
    if (_frozen) {
      throw new StateError('Entity is frozen, cannot mutate: $key.');
    }
    if (value is Function && !key.startsWith('local.')) {
      throw new ClosureInEntityException(key, value.toString());
    }
    if (key.contains('.')) {
      var keyPieces = key.split('.').toList();
      // The last key is the one we're assigning to, not reading, so remove it.
      var assignmentKey = keyPieces.removeLast();
      var target = _walk(this, keyPieces);
      if (target == null) {
        // Retrace the path and build the partial path which evaluated to null.
        // This isn't done during the initial navigation as an optimization.
        var current = this;
        var nullPath = keyPieces
            .takeWhile((keyPiece) => (current = this[keyPiece]) != null)
            .join('.');
        throw new ArgumentError("Setting '$key' but part of the path " +
            "evaluated to null: '$nullPath'.");
      }
      target[assignmentKey] = value;
    } else  if (key == 'local') {
      throw new ArgumentError("Can't set the value of 'local'.");
    } else {
      _data[key] = value;
    }
  }

  /// Returns true if entity contains a field with a given [fieldName].
  bool containsKey(String fieldName) {
    return _data.containsKey(fieldName);
  }

  /// List of all field names in this Entity.
  Iterable<String> get fieldNames => _data.keys;

  // Remove a field by name.
  remove(String key) {
    if (_frozen) {
      throw new StateError('Entity is frozen, cannot mutate: $key.');
    }
    return _data.remove(key);
  }

  /// Turn this entity into a Map for JSON serialization.
  Map toJson() {
    var jsonMap = new Map();
    // Sort keys before adding to the output map, to ensure equivalent entities
    // produce equivalent json.
    var keys = (_data.keys.toList()..sort())
        .where((k) => _data[k] != null)
        .forEach((k) {
          jsonMap[k] = _data[k];
        });
    return jsonMap;
  }

  String get signature => stringify(this);

  Type get streamyType => RawEntity;

  // Delegation of the remaining [Map] interface.
  bool get isEmpty => _data.isEmpty;
  bool get isNotEmpty => _data.isNotEmpty;
  Iterable<String> get keys => _data.keys;
  Iterable get values => _data.values;
  void addAll(Map<String, dynamic> other) {
    if (_frozen) {
      throw new StateError('Entity is frozen, cannot addAll().');
    }
    _data.addAll(other);
  }
  void clear() {
    if (_frozen) {
      throw new StateError('Entity is frozen, cannot clear().');
    }
    _data.clear();
  }
  bool containsValue(value) => _data.containsValue(value);
  void forEach(void fn(String key, value)) => _data.forEach(fn);
  putIfAbsent(String key, ifAbsent()) {
    if (_frozen) {
      throw new StateError('Entity is frozen, cannot mutate: $key');
    }
    return _data.putIfAbsent(key, ifAbsent);
  }

  Stream<List<ChangeRecord>> get changes => _data.changes;
  bool deliverChanges() => _data.deliverChanges();
  void notifyChange(ChangeRecord record) {
    _data.notifyChange(record);
  }
  bool get hasObservers => _data.hasObservers;
}
