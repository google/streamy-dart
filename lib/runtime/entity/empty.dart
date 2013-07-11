part of streamy.runtime;

/// Represents an [Entity] that has no return body.
class EmptyEntity extends Entity {

  EmptyEntity() : super.base();

  /// Access metadata exposed by Streamy about this entity.
  final StreamyEntityMetadata streamy = new StreamyEntityMetadata._private();

  /// Local data associated with this entity instance.
  LocalDataMap get local => null;

  /// Create a deep copy of this entity.
  EmptyEntity clone() => new EmptyEntity()..streamy._mergeFrom(streamy);

  /// Data field getter.
  dynamic operator[](String key) => null;

  /// Data field setter.
  void operator[]=(String key, dynamic value) {
      throw new StateError("Can't set values on EmptyEntity");
  }

  /// Determine whether this entity has a given field.
  bool contains(String key) => false;

  /// List of all field names in this [Entity]. Note, that when fields are added
  /// or removed from the [Entity] they are also added or removed from the
  /// returned [Iterable]. If you need to preserve the list of fields, make
  /// your own copy. This is consistent with [Map.keys].
  List<String> get fieldNames => const [];

  /// Remove and return the value of a given field in this entity.
  dynamic remove(String key) => null;

  /// Return a JSON representation of this entity.
  Map toJson() => {};

  /// Return the Streamy implementation type of this entity.
  Type get streamyType => EmptyEntity;

  /// Compare two Entities.
  bool operator=(other) => other is EmptyEntity;

  /// Get the hashCode of this entity.
  int get hashCode => "empty".hashCode();
}