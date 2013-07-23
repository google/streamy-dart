part of streamy.runtime;

/// Public interface of Streamy entities.
abstract class Entity {

  Entity.base();

  /// Create a new [DynamicEntity].
  factory Entity() => new DynamicEntity();

  /// Create a [DynamicEntity] from a [Map].
  factory Entity.fromMap(Map data) => new DynamicEntity.fromMap(data);

  /// Access metadata exposed by Streamy about this entity.
  StreamyEntityMetadata get streamy;

  /// Create a deep copy of this entity.
  Entity clone();

  /// Access entity data by field name.
  dynamic operator[](String key);

  /// Mutate entity data by field name.
  void operator[]=(String key, dynamic value);

  /// Determine whether this entity has a given field.
  bool containsKey(String key);
  
  /// Deprecated contains() method.
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
  LocalDataMap get local;

  /// Return the Streamy implementation type of this entity.
  Type get streamyType;

  /// Compare two Entities.
  bool operator==(other);

  /// Get the hashCode of this entity.
  int get hashCode;
}
