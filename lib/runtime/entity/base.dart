part of streamy.runtime;

/// A function which represents a synthetic property on an [Entity]. It computes the value of the
/// property given an [Entity].
typedef dynamic EntityGlobalFn(entity);

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

/// Public interface of Streamy entities.
abstract class Entity {

  Entity.base();

  /// Create a new [RawEntity].
  factory Entity() => new RawEntity();

  /// Create a [RawEntity] from a [Map].
  factory Entity.fromMap(Map data) => new RawEntity.fromMap(data);

  /// Access metadata exposed by Streamy about this entity.
  StreamyEntityMetadata get streamy;
  
  /// Whether this entity is frozen (read only).
  bool get isFrozen;
  
  /// Deep freeze (ha!) this entity to no longer allow changes.
  void _freeze();
  
  GlobalView get global => new EmptyGlobalView();

  /// Create a deep copy of this entity.
  Entity clone();

  /// Access entity data by field name.
  dynamic operator[](String key);

  /// Mutate entity data by field name.
  void operator[]=(String key, dynamic value);

  /// Determine whether this entity has a given field.
  bool containsKey(String key);

  /// Deprecated contains() method. Use [containsKey] instead.
  @deprecated
  bool contains(String key) => containsKey(key);

  /// List of all field names in this [Entity]. Note, that when fields are added
  /// or removed from the [Entity] they are also added or removed from the
  /// returned [Iterable]. If you need to preserve the list of fields, make
  /// your own copy. This is consistent with [Map.keys].
  List<String> get fieldNames;

  /// Remove and return the value of a given field in this entity.
  dynamic remove(String key);

  /// Return a JSON representation of this entity.
  Map toJson();

  /// Local data associated with this entity instance.
  Map<String, dynamic> get local;

  /// Return the Streamy implementation type of this entity.
  Type get streamyType;

  /// Check for deep equality of entities (slow).
  /// TODO(arick): figure out a way to clean this up a bit.
  static bool deepEquals(Entity first, Entity second) {
    if (identical(first, second)) {
      return true;
    }
    if (first == null || second == null) {
      return (first == second);
    }

    if (first.local.length != second.local.length) {
      return false;
    }

    // Loop through each field, checking equality of the values.
    var fieldNames = first.fieldNames.toList(growable: false);
    var len = fieldNames.length;
    for (var i = 0; i < len; i++) {
      if (!second.containsKey(fieldNames[i])) {
        return false;
      }
      var firstValue = first[fieldNames[i]];
      var secondValue = second[fieldNames[i]];
      if (firstValue is Entity && secondValue is Entity) {
        if (!Entity.deepEquals(firstValue, secondValue)) {
          return false;
        }
      } else if (firstValue is List && secondValue is List) {
        if (firstValue.length != secondValue.length) {
          return false;
        }
        for (var j = 0; j < firstValue.length; j++) {
          if (firstValue[j] is Entity && secondValue[j] is Entity) {
            if (!Entity.deepEquals(firstValue[j], secondValue[j])) {
              return false;
            }
          } else if (firstValue[j] != secondValue[j]) {
            return false;
          }
        }
      } else if (firstValue != secondValue) {
        return false;
      }
    }
    return true;
  }

  /// Compute the deep hash code of an entity (slow).
  static int deepHashCode(Entity entity) {
    // Running total, kept under MAX_HASHCODE.
    var running = 0;
    var fieldNames = new List.from(entity.fieldNames)..sort();
    var len = fieldNames.length;
    for (var i = 0; i < len; i++) {
      running = ((17 * running) + fieldNames[i].hashCode) % MAX_HASHCODE;
      var value = entity[fieldNames[i]];
      if (value is Entity) {
        running = ((17 * running) + Entity.deepHashCode(value)) % MAX_HASHCODE;
      } else if (value is List) {
        for (var listValue in value) {
          if (listValue is Entity) {
            running = ((17 * running) + Entity.deepHashCode(listValue)) % MAX_HASHCODE;
          } else {
            running = ((17 * running) + listValue.hashCode) % MAX_HASHCODE;
          }
        }
      } else {
        running = ((17 * running) + value.hashCode) % MAX_HASHCODE;
      }
    }
    return running;
  }
}

class GlobalView extends ChangeNotifierBase {

  Entity _entity;
  Map<String, EntityGlobalFn> _globals;
  Map<String, dynamic> _read = {};

  GlobalView(this._entity, this._globals);

  bool containsKey(String key) => _globals.containsKey(key);
  operator[](String key) {
    if (!_globals.containsKey(key)) {
      return null;
    }
    _read[key] = _globals[key](_entity);
    return _read[key];
  }

  _entityChanged() {
    _read.forEach((key, oldValue) {
      var newValue = _globals[key](_entity);
      if (newValue != oldValue) {
        _read[key] = newValue;
        notifyChange(new MapChangeRecord<String, dynamic>(key, oldValue, newValue));
      }
    });
  }
}

class EmptyGlobalView extends ChangeNotifierBase implements GlobalView {

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
