/// Base library used by all generated APIs.
library streamy_base;

import "dart:async";
import "dart:json";
import "package:third_party/dart/streamy/lib/comparable.dart";

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

/// The root object representing an entire API, which makes its resources
/// available.
abstract class Root {
  Stream send(Request req);
}

/// Metadata that Streamy tracks about a given entity.
class StreamyEntityMetadata {

  /// Internal map of metadata.
  final _metadata = new ComparableMap<String, dynamic>();

  /// Internal constructor.
  StreamyEntityMetadata._private();

  /// Utility to help copy metadata from one entity to another.
  _mergeFrom(StreamyEntityMetadata other) => _metadata.addAll(other._metadata);

  /// Get the timestamp at which this entity was returned from the server.
  int get ts => _metadata['ts'];

  /// Set the timestamp at which this entity was returned from the server.
  void set ts(int v) {
    _metadata['ts'] = v;
  }

  /// Get the source of this entity (cache, rpc, etc).
  String get source => _metadata['source'];

  /// Set the source of this entity.
  void set source(String v) {
    _metadata['source'] = v;
  }

  bool operator ==(other) =>
    other is StreamyEntityMetadata && other._metadata == _metadata;

  int get hashCode => _metadata.hashCode;
}

/// Produces an entity from a given JSON map
typedef Entity EntityFactory(Map json);

/// Information about a type generated from a discovery document
class TypeInfo {
  final EntityFactory _ef;
  TypeInfo(this._ef);
  Entity fromJson(Map json) => this._ef(json);
}

/// Public interface of Streamy entities.
abstract class Entity {
  /// Access metadata exposed by Streamy about this entity.
  StreamyEntityMetadata get streamy;

  /// Create a deep copy of this entity.
  Entity clone();

  /// Access entity data by field name.
  dynamic operator[](String key);

  /// Mutate entity data by field name.
  void operator[]=(String key, dynamic value);

  /// Determine whether this entity has a given field.
  bool contains(String key);

  /// List of all field names in this [Entity]. Note, that when fields are added
  /// or removed from the [Entity] they are also added or removed from the
  /// returned [Iterable]. If you need to preserve the list of fields, make
  /// your own copy. This is consistent with [Map.keys].
  List<String> get fieldNames;

  /// Remove and return the value of a given field in this entity.
  dynamic remove(String key);

  /// Return a JSON representation of this entity.
  Map toJson();

  /// Return the Streamy implementation type of this entity.
  Type get streamyType;

  /// Compare two Entities.
  bool operator==(other);

  /// Get the hashCode of this entity.
  int get hashCode;
}

/// Parent of all data transfer objects. Provides map-like methods for
/// accessing field values.
class RawEntity implements Entity {

  /// Actual fields of the Apiary entity.
  var _data = new ComparableMap<String, dynamic>();

  /// Metadata about this entity.
  final StreamyEntityMetadata streamy = new StreamyEntityMetadata._private();

  /// Copy this entity.
  RawEntity clone() => new RawEntity().._cloneFrom(this);

  /// Merge fields from an input map.
  _cloneFrom(RawEntity input) {
    _data = _clone(input._data);
    streamy._mergeFrom(input.streamy);
  }

  /// Data field getter that handles dot navigation access.
  operator[](String key) {
    if (key.contains('.')) {
      return key.split('.').fold(_data, (cur, keyPart) =>
          (cur != null) ? cur[keyPart] : null);
    }
    return _data[key];
  }

  /// Data field setter.
  operator[]=(String key, dynamic value) {
    if (value is List && value is! ComparableList) {
      value = new ComparableList.from(value);
    }
    if (key.contains('.')) {
      throw new ArgumentError(
          "Dot-navigation is not allowed when setting values: $key");
    }
    _data[key] = value;
  }

  /// Returns true if entity contains a field with a given [fieldName].
  bool contains(String fieldName) {
    return _data.containsKey(fieldName);
  }

  /// List of all field names in this Entity.
  Iterable<String> get fieldNames => _data.keys;

  // Remove a field by name.
  remove(String key) => _data.remove(key);

  /// Turn this entity into a Map for JSON serialization.
  Map toJson() => removeNulls(new Map.from(_data));

  bool operator ==(other) => other is RawEntity && other._data == _data;

  int get hashCode => _data.hashCode;

  Type get streamyType => RawEntity;
}

/// A function that clones an [EntityWrapper], given a clone of its wrapped
/// [Entity]. This is part of the private interface between [EntityWrapper]
/// and its subclasses.
typedef EntityWrapper EntityWrapperCloneFn(Entity delegateClone);

/// Wraps an [Entity] and delegates to it. This is the base class for all
/// generated entities.
abstract class EntityWrapper implements Entity {

  final Entity _delegate;

  /// A function which clones the subclass of this [EntityWrapper].
  final EntityWrapperCloneFn _clone;

  /// Constructor which takes the wrapped [Entity] and an [EntityWrapperCloneFn]
  /// from the subclass. This clone function returns a new instance of the
  /// subclass given a cloned instance of the wrapped [Entity].
  EntityWrapper.wrap(this._delegate, this._clone);

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

  dynamic operator[](String key) => _delegate[key];

  void operator[]=(String key, dynamic value) {
    _delegate[key] = value;
  }

  bool contains(String key) => _delegate.contains(key);

  List<String> get fieldNames => _delegate.fieldNames;

  dynamic remove(String key) => _delegate.remove(key);

  // Equality is tricky - we could be comparing different levels of nested
  // wrapping. Thus, we need to unwrap until we get to non-wrappers.
  bool operator==(other) =>
      other is EntityWrapper && other.streamyType == streamyType &&
      other._root == _root;

  int get hashCode => _delegate.hashCode;

  Map toJson() => _delegate.toJson();

  Type get streamyType;
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

/// Method path regex, capturing parameter names enclosed in {}.
RegExp pathRegex = new RegExp(r"(\{[^\}]+\})");

/// An HTTP request described by the API.
abstract class Request {

  /// The root object from the API which generated this request.
  final Root root;

  /// Request parameters.
  final ComparableMap<String, dynamic> parameters = new ComparableMap();

  /// Payload, if any.
  final Entity _payload;

  /// These getters access general information about this type of request.

  /// The HTTP method of this request.
  String get httpMethod;

  /// Whether this is cachable.
  bool get isCachable => httpMethod == "GET";

  /// Format of the request path.
  String get pathFormat;

  /// Whether there is a request body.
  bool get hasPayload;

  /// Parameters that will be passed in the HTTP URL path.
  List<String> get pathParameters;

  /// Parameters that will be passed on the query string.
  List<String> get queryParameters;

  /// Construct a new request.
  Request(this.root, [this._payload = null]) {
    if (_payload == null && hasPayload) {
      throw new StateError("Request of type $runtimeType expects a payload," +
          " but none given");
    }
  }

  /// Returns a function that can deserialize a response JSON string to Dart
  /// object.
  Deserializer get responseDeserializer;

  /// Returns the payload, if any.
  Entity get payload => _payload;

  /// Constructs a URI path with path and query parameters
  String get path {
    int pos = 0;
    StringBuffer buf = new StringBuffer();
    for (Match m in pathRegex.allMatches(pathFormat)) {
      buf.write(pathFormat.substring(pos, m.start));
      buf.write(parameters[pathFormat.substring(m.start + 1, m.end - 1)]);
      pos = m.end;
    }
    buf.write(pathFormat.substring(pos));
    bool firstQueryParam = true;
    for (String qp in queryParameters) {
      if (parameters.containsKey(qp)) {
        write(v) {
          buf
            ..write(firstQueryParam ? "?" : "&")
            ..write(qp)
            ..write("=")
            ..write(v);
          firstQueryParam = false;
        }
        if (parameters[qp] is List) {
          parameters[qp].forEach(write);
        } else {
          write(parameters[qp]);
        }
      }
    }
    return buf.toString();
  }

  Request clone();

  _cloneFrom(Request other) => other.parameters.forEach((k, v) {
    if (v is ComparableList) {
      parameters[k] = new ComparableList.from(v);
    } else {
      parameters[k] = v;
    }
  });

  bool operator==(other) {
    if (other.runtimeType != runtimeType) {
      return false;
    }
    if (hasPayload && other._payload != _payload) {
      return false;
    }
    return other.parameters == parameters;
  }

  int get hashCode => 17 * (17 * runtimeType.hashCode + parameters.hashCode)
      + _payload.hashCode;
}

/// Defines interface for a request handler.
abstract class RequestHandler {
  Stream handle(Request request);
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
