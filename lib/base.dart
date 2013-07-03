/// Base library used by all generated APIs.
library streamy_base;

import "dart:async";
import "dart:json";
import "dart:mirrors";
import "package:streamy/comparable.dart";

internalCloneFrom(dest, source) => dest.._cloneFrom(source);
internalGetPayload(Request r) => r._payload;

/// A [StreamTransformer] that de-duplicates entities. This will cause
/// metadata about the entity (Entity.streamy) to be inaccurate, but will
/// prevent multiple values from being published on [Stream]s when core [Entity]
/// data has not changed.
class EntityDedupTransformer extends StreamEventTransformer<Entity, Entity> {
  var _last = null;

  handleData(Entity data, EventSink<Entity> sink) {
    if (data != _last) {
      sink.add(data);
    }
    _last = data;
  }
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

/// A [Map] that has dot-property access and equality, which backs the .local
/// property.
class LocalDataMap implements Map {

  final Map _delegate = {};

  LocalDataMap();

  factory LocalDataMap.of(Map other) {
    var ldm = new LocalDataMap();
    other.forEach((k, v) => ldm[k] = v);
    return ldm;
  }

  // Straight delegations from [Map]:

  bool get isEmpty => _delegate.isEmpty;
  bool get isNotEmpty => _delegate.isNotEmpty;
  Iterable get keys => _delegate.keys;
  int get length => _delegate.length;
  Iterable get values => _delegate.values;
  void clear() {
    _delegate.clear();
  }
  bool containsKey(key) => _delegate.containsKey(key);
  bool containsValue(value) => _delegate.containsValue(value);
  void forEach(void fn(k, v)) {
    _delegate.forEach(fn);
  }
  dynamic remove(key) => _delegate.remove(key);
  dynamic operator[](key) => _delegate[key];

  // Overrides of [Map] behavior:

  /// Override of the [Map] setter interface, which wraps [Map] values in
  /// [LocalDataMap]s.
  operator[]=(key, value) {
    if (value is Map) {
      value = new LocalDataMap.of(value);
    }
    return (_delegate[key] = value);
  }

  /// Overrides the [Map] putIfAbsent interface, which wraps [Map] values in
  /// [LocalDataMap]s.
  dynamic putIfAbsent(key, dynamic isAbsent()) {
    if (!containsKey(key)) {
      // Use the setter interface to handle the [LocalDataMap] conversion.
      this[key] = isAbsent();
    }
    return this[key];
  }

  bool operator==(other) => compareMapObjects(this, other);
  int get hashCode => hashCodeForMap(this);

  /// [noSuchMethod] provides dot-property access to fields.
  noSuchMethod(Invocation invocation) {
    var memberName = MirrorSystem.getName(invocation.memberName);
    if (invocation.isGetter) {
      return this[memberName];
    } else if (invocation.isSetter) {
      // Setter member names have a '=' at the end, strip it.
      var key = memberName.substring(0, memberName.length - 1);
      this[key] = invocation.positionalArguments[0];
    } else {
      // This is a closure invocation for a property.
      return Function.apply(this[memberName], invocation.positionalArguments,
          invocation.namedArguments);
    }
  }
}

/// The root object representing an entire API, which makes its resources
/// available.
abstract class Root {

  /// The API service path.
  String get servicePath;

  /// Execute a [Request] and return a [Stream] of the results.
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

  /// Local data associated with this entity instance.
  LocalDataMap get local;

  /// Return the Streamy implementation type of this entity.
  Type get streamyType;

  /// Compare two Entities.
  bool operator==(other);

  /// Get the hashCode of this entity.
  int get hashCode;
}

/// Parent of all data transfer objects. Provides map-like methods for
/// accessing field values.
class RawEntity extends Entity {

  RawEntity() : super.base();

  /// Actual fields of the Apiary entity.
  var _data = new ComparableMap<String, dynamic>();

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

    /// Walk a map-like structure through a list of keys, beginning with [this].
  _walk(pieces) => pieces.fold(this,
          (current, keyPiece) => current != null ? current[keyPiece] : null);

  /// Data field getter.
  dynamic operator[](String key) {
    if (key == "local") {
      return local;
    }
    return key.contains('.') ? _walk(key.split('.')) : _data[key];
  }

  /// Data field setter.
  void operator[]=(String key, dynamic value) {
    if (value is List && value is! ComparableList) {
      value = new ComparableList.from(value);
    }
    if (value is Function && !key.startsWith("local.")) {
      throw new ClosureInEntityException(key, value);
    }
    if (key.contains('.')) {
      var keyPieces = key.split('.').toList();
      // The last key is the one we're assigning to, not reading, so remove it.
      var assignmentKey = keyPieces.removeLast();
      var target = _walk(keyPieces);
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

class DynamicEntity extends RawEntity {

  DynamicEntity() : super();

  DynamicEntity.fromMap(Map data) {
    data.forEach((key, value) {
      this[key] = value;
    });
  }

  noSuchMethod(Invocation invocation) {
    var memberName = MirrorSystem.getName(invocation.memberName);
    if (invocation.isGetter) {
      return this[memberName];
    } else if (invocation.isSetter) {
      // Setter member names have an '=' at the end, strip it.
      var key = memberName.substring(0, memberName.length - 1);
      this[key] = invocation.positionalArguments[0];
    } else {
      throw new ClosureInvocationException(memberName);
    }
  }

  Type get streamyType => DynamicEntity;
}

/// A function that clones an [EntityWrapper], given a clone of its wrapped
/// [Entity]. This is part of the private interface between [EntityWrapper]
/// and its subclasses.
typedef EntityWrapper EntityWrapperCloneFn(Entity delegateClone);

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

  bool contains(String key) => _delegate.contains(key);

  List<String> get fieldNames => _delegate.fieldNames;

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

  /// Local data map, used to pass arbitrary information about this request to
  /// the [RequestHandler].
  final LocalDataMap local = new LocalDataMap();

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
  RequestHandler transformResponses(RequestStreamTransformer transformer)
      => new TransformingRequestHandler(this, transformer);
}

abstract class RequestStreamTransformer {
  Stream bind(Request request, Stream stream);
}

class TransformingRequestHandler extends RequestHandler {
  final RequestHandler delegate;
  final RequestStreamTransformer transformer;

  TransformingRequestHandler(this.delegate, this.transformer);

  Stream handle(Request request) =>
      transformer.bind(request, delegate.handle(request));
}

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
