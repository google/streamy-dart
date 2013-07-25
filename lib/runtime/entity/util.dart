part of streamy.runtime;

/// Produces an entity from a given JSON map
typedef Entity EntityFactory(Map json);

/// Information about a type generated from a discovery document
class TypeInfo {
  final EntityFactory _ef;
  TypeInfo(this._ef);
  Entity fromJson(Map json) => this._ef(json);
}

_clone(v) {
  if (v is Entity) {
    return v.clone();
  } else if (v is Map) {
    var c = new ComparableMap();
    v.forEach((key, value) {
      c[key] = _clone(value);
    });
    return c;
  } else if (v is List) {
    return new ComparableList.from(v.map((value) => _clone(value)));
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
addUnknownProperties(Entity destination, Map remainderJson,
                     Map<String, TypeInfo> typeRegistry) {
  remainderJson.forEach((String key, dynamic value) {
    destination[key] = _deserialize(value, typeRegistry);
  });
}

/**
 *  Deserializes a JSON [value] into a proper Dart object, unless it is
 *  already deserialized. The [typeRegistry] is used to lookup known types by
 *  'kind' attribute specified in the discovery document.
 */
_deserialize(dynamic value, Map<String, TypeInfo> typeRegistry) {
  if (value is Map) {
    // Might be an object of a known kind
    String kind = value['kind'];
    if (kind == null || !typeRegistry.containsKey(kind)) {
      // Not an object of known kind. Deserialize recursively.
      var result = new RawEntity();
      value.forEach((String key, dynamic value) {
        result[key] = _deserialize(value, typeRegistry);
      });
      return result;
    } else {
      // Known kind is specified, deserialize using factory.
      return typeRegistry[kind].fromJson(value);
    }
  } if (value is List) {
    // Might contain elements of known kinds
    return value.map((elem) => _deserialize(elem, typeRegistry)).toList();
  } else {
    // Already deserialized.
    return value;
  }
}

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