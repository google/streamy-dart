part of streamy.runtime;

internalCloneFrom(dest, source) => dest.._cloneFrom(source);
internalGetPayload(Request r) => r._payload;

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
 *  "kind" attribute specified in the discovery document.
 */
_deserialize(dynamic value, Map<String, TypeInfo> typeRegistry) {
  if (value is Map) {
    // Might be an object of a known kind
    String kind = value["kind"];
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

dynamic nullSafeOperation(x, f(elem)) => x != null ? f(x) : null;

/// map() implementation for an Iterable that respects nulls.
List nullSafeMapToList(Iterable i, f(elem)) =>
    nullSafeOperation(i, (i2) => i2.map(f).toList());

/// Removes all key/value pairs whose values are null.
Map removeNulls(Map m) => m..keys
    .where((k) => m[k] == null)
    .toList(growable: false)  // Materialize to avoid concurrent modification.
    .forEach(m.remove);

/// A function that can deserialize a JSON string into a Dart object.
typedef dynamic Deserializer(String str);

/// Returns the object that was passed as the parameter.
identityFn(Object o) => o;


abstract class StreamyException implements Exception { }

class ClosureInEntityException extends StreamyException {
  final String key;
  final String closureToString;

  ClosureInEntityException(this.key, this.closureToString);

  String toString() => "Attempted to set a closure as an entity property. " +
      "Use .local for that instead. Key: $key, Closure: $closureToString";
}

class ClosureInvocationException extends StreamyException {

  final String memberName;

  ClosureInvocationException(this.memberName);

  String toString() => "Fields of DynamicEntity objects can't be invoked, as " +
      "they cannot contain closures. Field: $memberName";
}
