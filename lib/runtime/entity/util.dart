part of streamy.runtime;

/// Produces an entity from a given JSON map
typedef Entity EntityFactory(Map json, TypeRegistry reg);

/// Doesn't contain any types.
const TypeRegistry EMPTY_REGISTRY = const _EmptyTypeRegistry();

void _freezeHelper(object) {
  if (object is Entity) {
    object._freeze();
  } else if (object is Map) {
    object.values.forEach(_freezeHelper);
  } else if (object is List) {
    object.forEach(_freezeHelper);
  }
}

/// Information about types generated from a discovery document.
abstract class TypeRegistry {

  /// Constructs a registry from a map that maps schema/entity kind to
  /// factories that can deserialize the JSON representation to a concrete
  /// entity object.
  factory TypeRegistry(Map<String, EntityFactory> factoryMap) =>
      new _TypeRegistryImpl(factoryMap);

  /// Checks if a given kind is registered.
  bool isRegistered(String kind);

  /// Deserializes JSON into a concrete entity object. Throws if given [kind]
  /// is not registered, so check with [isRegistered] method prior to calling
  /// this method.
  Entity deserialize(String kind, Map json);
}

/// A real type registry implementation.
class _TypeRegistryImpl implements TypeRegistry {
  final Map<String, EntityFactory> _factoryMap;

  _TypeRegistryImpl(Map<String, EntityFactory> this._factoryMap);

  bool isRegistered(String kind) => this._factoryMap.containsKey(kind);

  Entity deserialize(String kind, Map json) {
    if (!isRegistered(kind)) {
      throw new StateError("'$kind' is not a registered type.");
    }
    return this._factoryMap[kind](json, this);
  }
}

/// A dummy registry that doesn't have any types.
class _EmptyTypeRegistry implements TypeRegistry {
  const _EmptyTypeRegistry();

  Entity deserialize(String kind, Map json) {
    throw new StateError("Not supported by empty registry.");
  }
  bool isRegistered(String kind) => false;
}

_clone(v) {
  if (v is Entity) {
    return v.clone();
  } else if (v is Map) {
    Map c = new Map();
    v.forEach((k, v) {
      c[k] = _clone(v);
    });
    return c;
  } else if (v is List) {
    return new List.from(v.map((value) => _clone(value)));
  } else {
    return v;
  }
}

/**
 * Adds unknown properties from the ramaining map entries after all known
 * properties have been deserialized. [remainderJson] contains the remaining
 * map entries. [typeRegistry] contains information about all types generated
 * from the discovery document.
 *
 * WARNING: This function will overwrite any entries whose field names coincide
 * with keys in the [remainderJson].
 */
addUnknownProperties(Entity destination, Map remainderJson, TypeRegistry reg) {
  remainderJson.forEach((String key, dynamic value) {
    destination[key] = _deserialize(value, reg);
  });
}

/**
 *  Deserializes a JSON [value] into a proper Dart object, unless it is
 *  already deserialized. The [typeRegistry] is used to lookup known types by
 *  'kind' attribute specified in the discovery document.
 */
_deserialize(dynamic value, TypeRegistry reg) {
  if (value is Map) {
    // Might be an object of a known kind
    String kind = value['kind'];
    if (kind == null || !reg.isRegistered(kind)) {
      // Not an object of known kind. Deserialize recursively.
      var result = new RawEntity();
      value.forEach((String key, dynamic value) {
        result[key] = _deserialize(value, reg);
      });
      return result;
    } else {
      // Known kind is specified, deserialize using factory.
      return reg.deserialize(kind, value);
    }
  } if (value is List) {
    // Might contain elements of known kinds
    return value.map((elem) => _deserialize(elem, reg)).toList();
  } else {
    // Already deserialized.
    return value;
  }
}

deserialize(value, TypeRegistry reg) => _deserialize(value, reg);

/// A sentinel value which indicates that an RPC returned an error.
class _ErrorEntity implements Entity {

  const _ErrorEntity();

  operator[](key) => throw "Not implemented";
  operator[]=(key, value) {
    throw "Not implemented";
  }
  toJson() => throw "Not implemented";
  clone() => throw "Not implemented";
  @deprecated  // defined here solely to conform to the interface
  contains(key) => throw "Not implemented";
  containsKey(key) => throw "Not implemented";
  remove(key) => throw "Not implemented";
  get local => throw "Not implemented";
  get fieldNames => throw "Not implemented";
  get streamyType => throw "Not implemented";
  get streamy => throw "Not implemented";

  bool equals(Object other) => other is _ErrorEntity;
  int get hashCode => "error".hashCode;
  toString() => "Internal Streamy sentinel value - should not be exposed.";
}

const _INTERNAL_ERROR = const _ErrorEntity();

/// Walk a map-like structure through a list of keys, beginning with an initial value.
_walk(initial, pieces) => pieces.fold(initial,
      (current, keyPiece) => current != null ? current[keyPiece] : null);