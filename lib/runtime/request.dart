part of streamy.runtime;

/// A function that handles Streamy RPC requests.
typedef Stream<Response> RequestHandlingFunction(Request request);
typedef bool RequestPredicate(Request request);

bool _alwaysTrue(Request _) => true;

/// Defines interface for a request handler.
abstract class RequestHandler {
  RequestHandler();

  /// Creates a request handler that delegates handling requests to a
  /// user-scpecified function. Convenient in tests and other situations.
  factory RequestHandler.fromFunction(RequestHandlingFunction func) {
    return new _FunctionRequestHandler(func);
  }

  Stream<Response> handle(Request request, Trace trace);
  RequestHandler transform(transformerOrFactory, {RequestPredicate predicate: _alwaysTrue}) => transformerOrFactory is Function ?
      new TransformingRequestHandler(this, transformerOrFactory, predicate) :
      new TransformingRequestHandler(this, () => transformerOrFactory, predicate);
}

class _FunctionRequestHandler extends RequestHandler {
  final RequestHandlingFunction _func;

  _FunctionRequestHandler(RequestHandlingFunction this._func);

  Stream<Response> handle(Request request, Trace trace) => _func(request);
}

/// The root object representing an entire API, which makes its resources
/// available.
abstract class Root {
  final TypeRegistry typeRegistry;

  /// The API service path.
  final String servicePath;

  Root(this.typeRegistry, this.servicePath);

  // Type name as defined in the API.
  String get apiType => 'Root';

  /// Execute a [Request] and return a [Stream] of the results.
  Stream<Response> send(Request req);
}

/// Implementations of this interface provide concrete implementation of a
/// transactional strategy.
abstract class TransactionStrategy {
  Transaction beginTransaction();
}

/// Companion interface to [TransactionStrategy], represents a single
/// transaction.
abstract class Transaction {
  Stream send(Request request);
  Future commit();
}

/// Substitute for a [Root] object that executes requests as part of the same
/// transaction. The implementation of a transactional strategy is provided by
/// a [TransactionStrategy] object.
class TransactionRoot extends Root {

  final Transaction _tx;

  TransactionRoot(TypeRegistry typeRegistry, String servicePath,
      Transaction this._tx) : super(typeRegistry, servicePath);

  Stream send(Request request) => _tx.send(request);
  Future commit() => _tx.commit();
}

/// Method path regex, capturing parameter names enclosed in {}.
RegExp pathRegex = new RegExp(r'(\{[^\}]+\})');

/// An HTTP request described by the API.
abstract class Request {

  /// Type name as defined in the API.
  String get apiType => 'Request';

  /// The root object from the API which generated this request.
  final Root root;

  /// Request parameters.
  final Map<String, dynamic> parameters = {};

  /// Payload, if any.
  final Entity _payload;

  /// These getters access general information about this type of request.

  /// The HTTP method of this request.
  String get httpMethod;

  /// Whether this is cachable.
  bool get isCachable => httpMethod == 'GET';

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
  final Map<String, dynamic> local = <String, dynamic>{};

  /// Construct a new request.
  Request(this.root, [this._payload = null]) {
    if (_payload == null && hasPayload) {
      throw new StateError('Request of type $runtimeType expects a payload,' +
          ' but none given');
    }

    // Prepopulate request path parameters from the payload Entity, if one is available.
    // This is a convenience that isn't codified in the discovery document spec.
    if (hasPayload) {
      pathParameters.forEach((param) {
        if (payload.contains(param) &&
            (payload[param] is String || payload[param] is int || payload[param] is Int64)) {
          parameters[param] = payload[param];
        }
      });
    }
  }

  /// Returns a function that can deserialize a response JSON string to Dart
  /// object.
  Deserializer get responseDeserializer;

  /// Returns the payload, if any.
  Entity get payload => _payload;

  Map toJson() {
    return new Map()
      ..['parameters'] = parameters
      ..['payload'] = _payload;
  }

  /// Constructs a URI path with path and query parameters
  String get path {
    int pos = 0;
    StringBuffer buf = new StringBuffer();
    for (Match m in pathRegex.allMatches(pathFormat)) {
      buf.write(pathFormat.substring(pos, m.start));
      String pathParamName = pathFormat.substring(m.start + 1, m.end - 1);
      buf.write(Uri.encodeComponent(parameters[pathParamName].toString()));
      pos = m.end;
    }
    buf.write(pathFormat.substring(pos));
    bool firstQueryParam = true;
    // queryParameters is ordered.
    for (String qp in queryParameters) {
      if (parameters.containsKey(qp)) {
        write(v) {
          buf
            ..write(firstQueryParam ? '?' : '&')
            ..write(qp)
            ..write('=')
            ..write(Uri.encodeQueryComponent(v.toString()));
          firstQueryParam = false;
        }
        if (parameters[qp] is List) {
          // Sort the list of parameters to ensure a canonical path.
          (parameters[qp].toList()..sort()).forEach(write);
        } else {
          write(parameters[qp]);
        }
      }
    }
    return buf.toString();
  }

  Request clone();

  Request cacheKey() => local.putIfAbsent('streamy.cacheKey', clone);

  _cloneFrom(Request other) => other.parameters.forEach((k, v) {
    if (v is List) {
      parameters[k] = new List.from(v);
    } else {
      parameters[k] = v;
    }
  });

  bool operator==(other) {
    if (other.runtimeType != runtimeType) {
      return false;
    }
    var keys = new List.from(parameters.keys);
    var len = keys.length;
    if (other.parameters.keys.length != len) {
      return false;
    }
    for (var i = 0; i < len; i++) {
      var key = keys[i];
      var value = parameters[key];
      if (!other.parameters.containsKey(key)) {
        return false;
      }
      if (value is List) {
        var otherList = other.parameters[key];
        if (otherList is! List) {
          return false;
        }
        var listLen = value.length;
        if (value.length != otherList.length) {
          return false;
        }

        // These are Lists and not Sets. However, the comparison needs to consider
        // duplicates, so they are compared as sorted Lists, not Sets.
        value = new List.from(value)..sort();
        otherList = new List.from(otherList)..sort();
        for (var j = 0; j < listLen; j++) {
          if (value[j] != otherList[j]) {
            return false;
          }
        }
      } else if (value != other.parameters[key]) {
        return false;
      }
    }
    if (hasPayload && !Entity.deepEquals(_payload, other._payload)) {
      return false;
    }
    return true;
  }

  int get hashCode {
    // Running total, kept under MAX_HASHCODE.
    var running = runtimeType.hashCode % MAX_HASHCODE;

    var keys = parameters.keys.toList()..sort();
    var len = keys.length;
    for (int i = 0; i < len; i++) {
      var value = parameters[keys[i]];
      if (value is List) {
        var valueList = new List.from(value)..sort();
        var valueLen = valueList.length;
        for (var j = 0; j < valueLen; j++) {
          running = ((17 * running) + valueList[j].hashCode) % MAX_HASHCODE;
        }
      } else {
        running = ((17 * running) + value.hashCode) % MAX_HASHCODE;
      }
    }
    if (hasPayload) {
      running = ((17 * running) + Entity.deepHashCode(_payload)) % MAX_HASHCODE;
    }
    return running;
  }

  /// A serialized version of this request which is suitable for use as a cache key in a
  /// system such as IndexedDB which requires String keys.
  String get signature {
    // TODO: should the cast be necessary? Maybe _payload should be RawEntity.
    var payloadSig =
        _payload != null ? (_payload as RawEntity).signature : "null";
    return "$runtimeType|$path|$payloadSig";
  }
}

class BranchingRequestHandlerBuilder {
  final _typeMap = new Map<Type, List<_Branch>>();

  void addBranch(Type requestType, RequestHandler handler, {predicate: null}) {
    if (!_typeMap.containsKey(requestType)) {
      _typeMap[requestType] = [];
    }
    _typeMap[requestType].add(new _Branch(predicate, handler));
  }

  void addBranchForAll(List<Type> requestTypes, RequestHandler handler, {predicate: null}) {
    requestTypes.forEach((requestType) {
      addBranch(requestType, handler, predicate: predicate);
    });
  }

  RequestHandler build(RequestHandler defaultHandler) =>
      new _BranchingRequestHandler(defaultHandler, _typeMap);
}

class _Branch {
  final predicate;
  final RequestHandler handler;

  _Branch(this.predicate, this.handler);
}

class _BranchingRequestHandler extends RequestHandler {

  RequestHandler _delegate;
  Map<Type, List<_Branch>> _typeMap;

  _BranchingRequestHandler(this._delegate, this._typeMap);

  Stream handle(Request request, Trace trace) {
    if (!_typeMap.containsKey(request.runtimeType)) {
      return _delegate.handle(request, trace);
    }
    for (var branch in _typeMap[request.runtimeType]) {
      if (branch.predicate == null || branch.predicate(request)) {
        return branch.handler.handle(request, trace);
      }
    }
    return _delegate.handle(request, trace);
  }
}
