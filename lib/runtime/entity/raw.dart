part of streamy.runtime;

/// Parent of all data transfer objects. Provides map-like methods for
/// accessing field values.
class RawEntity extends Entity {

  RawEntity() : super.base();

  /// Actual fields of the Apiary entity.
  var _data = {};

  /// Metadata about this entity.
  final StreamyEntityMetadata streamy = new StreamyEntityMetadata._private();

  /// Local data.
  final LocalDataMap local = new LocalDataMap();

  /// Copy this entity (but not local data).
  RawEntity clone() => new RawEntity().._cloneFrom(this);

  /// Merge fields from an input map.
  _cloneFrom(RawEntity input) {
    _data = _clone(input._data);
    streamy._mergeFrom(input.streamy);
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
  remove(String key) => _data.remove(key);

  /// Turn this entity into a Map for JSON serialization.
  Map toJson() {
    var jsonMap = new Map();
    // Sort keys before adding to the output map, to ensure equivalent entities
    // produce equivalent json.
    var keys = (_data.keys.toList()..sort()).where((k) => _data[k] != null).forEach((k) {
      jsonMap[k] = _data[k];
    });
    return jsonMap;
  }
  
  String get signature => stringify(this);

  Type get streamyType => RawEntity;
}