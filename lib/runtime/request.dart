part of streamy.runtime;

/// A function that handles Streamy RPC requests.
typedef Stream<Response> RequestHandlingFunction<R extends Request>(R request);
typedef bool RequestPredicate(Request request);

bool _alwaysTrue(Request _) => true;

/// Defines interface for a request handler.
abstract class RequestHandler<R extends Request> {
  RequestHandler();

  /// Creates a request handler that delegates handling requests to a
  /// user-scpecified function. Convenient in tests and other situations.
  factory RequestHandler.fromFunction(RequestHandlingFunction<R> func) {
    return new _FunctionRequestHandler<R>(func);
  }

  Stream<Response> handle(R request, Trace trace);
  RequestHandler transform(transformerOrFactory, {RequestPredicate predicate: _alwaysTrue}) => transformerOrFactory is Function ?
      new TransformingRequestHandler(this, transformerOrFactory, predicate) :
      new TransformingRequestHandler(this, () => transformerOrFactory, predicate);
}

class _FunctionRequestHandler<R extends Request> extends RequestHandler<R> {
  final RequestHandlingFunction _func;

  _FunctionRequestHandler(RequestHandlingFunction<R> this._func);

  Stream<Response> handle(R request, Trace trace) => _func(request);
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

class HttpTransactionRoot extends TransactionRoot implements HttpRoot {
  final String servicePath;

  HttpTransactionRoot(Transaction tx, this.servicePath) : super(tx);
}

/// Method path regex, capturing parameter names enclosed in {}.
RegExp pathRegex = new RegExp(r'(\{[^\}]+\})');

abstract class Request {
  Root get root;

  bool get isCachable;
}

/// An HTTP request described by the API.
abstract class HttpRequest implements Request {

  /// Type name as defined in the API.
  String get apiType => 'Request';

  /// The root object from the API which generated this request.
  final HttpRoot root;

  /// Request parameters.
  final Map<String, dynamic> parameters = {};

  /// Other parameters.
  final Map<String, dynamic> localParameters = {};

  /// Payload, if any.
  final DynamicAccess _payload;

  /// These getters access general information about this type of request.

  /// The HTTP method of this request.
  String get httpMethod;

  /// User overridable value of isCachable. If null, the default value is used.
  bool _isCachable = null;

  /// Whether this is cachable.
  bool get isCachable => _isCachable != null
      ? _isCachable
      : httpMethod == 'GET';

  /// Sets whether or not this is cachable.
  set isCachable(bool isCachable) => _isCachable = isCachable;

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
  HttpRequest(this.root, [this._payload = null]) {
    if (_payload == null && hasPayload) {
      throw new StateError('Request of type $runtimeType expects a payload,' +
          ' but none given');
    }

    // Prepopulate request path parameters from the payload Entity, if one is available.
    // This is a convenience that isn't codified in the discovery document spec.
    if (hasPayload) {
      pathParameters.forEach((param) {
        if (payload.containsKey(param) &&
            (payload[param] is String || payload[param] is int || payload[param] is Int64)) {
          parameters[param] = payload[param];
        }
      });
    }
  }

  dynamic marshalPayload() => jsonMarshal(payload);

  dynamic unmarshalResponse(Map data) => null;

  /// Returns the payload, if any.
  get payload => _payload;

  Map toJson() {
    return new Map()
      ..['parameters'] = parameters
      ..['payload'] = _payload;
  }

  /// Constructs a URI path with path and query parameters
  String get path {
    int pos = 0;
    StringBuffer buf = new StringBuffer();
    bool seenReservedExpansionParameter = false;
    
    for (Match m in pathRegex.allMatches(pathFormat)) {
      if (seenReservedExpansionParameter) {
        throw new StateError(
            'Path contained Reserved Expansion parameter in non-final position');
      }
      buf.write(pathFormat.substring(pos, m.start));
      String pathParamName = pathFormat.substring(m.start + 1, m.end - 1);
      if (pathParamName.startsWith('\+')) {
        // A path parameter whose name starts with a + symbol (known as a
        // Reserved Expansion) is permitted to contain the '/' character, so
        // add it back after the URI encoding has removed it
        // (http://tools.ietf.org/html/rfc6570#section-3.2.3).
        // Note that Reserved Expansions can only exist as the last parameter
        // in the path to avoid ambiguity in path matching.
        var encoded = Uri.encodeComponent(
            parameters[pathParamName.substring(1)].toString());
        buf.write(encoded.replaceAll('%2F', '/'));
        seenReservedExpansionParameter = true;
      } else {
        buf.write(Uri.encodeComponent(parameters[pathParamName].toString()));
      }
      pos = m.end;
    }
    buf.write(pathFormat.substring(pos));
    bool firstQueryParam = true;
    write(qp, v) {
      buf
        ..write(firstQueryParam ? '?' : '&')
        ..write(qp)
        ..write('=')
        ..write(Uri.encodeQueryComponent(v.toString()));
      firstQueryParam = false;
    }
    // queryParameters is ordered.
    for (String qp in queryParameters) {
      if (parameters.containsKey(qp)) {
        if (parameters[qp] is List) {
          // Sort the list of parameters to ensure a canonical path.
          (parameters[qp].toList()..sort()).forEach((v) => write(qp, v));
        } else {
          write(qp, parameters[qp]);
        }
      }
    }
    localParameters.forEach((qp, v) {
      if (v is List) {
        // Sort the list of parameters to ensure a canonical path.
        (v.toList()..sort()).forEach((e) => write(qp, e));
      } else {
        write(qp, v);
      }
    });
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
    if (hasPayload && !EntityUtils.deepEquals(_payload, other._payload)) {
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
      running = ((17 * running) + EntityUtils.deepHashCode(_payload)) % MAX_HASHCODE;
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

class HttpRequestBase<P extends DynamicAccess> extends HttpRequest {
  final String httpMethod;
  final String pathFormat;
  final String apiType;
  final List<String> pathParameters;
  final List<String> queryParameters;
  final bool hasPayload;

  HttpRequestBase.noPayload(HttpRoot root, this.httpMethod, this.pathFormat,
      this.apiType, this.pathParameters, this.queryParameters)
          : hasPayload = false,
            super(root);

  HttpRequestBase.withPayload(HttpRoot root, this.httpMethod, this.pathFormat,
      this.apiType, this.pathParameters, this.queryParameters, P payload)
         : hasPayload = true,
           super(root, payload);
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

  Stream<Response> handle(Request request, Trace trace) {
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
