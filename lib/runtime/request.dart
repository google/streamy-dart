part of streamy.runtime;

/// A function that handles Streamy RPC requests.
typedef Stream RequestHandlingFunction(Request);

/// Defines interface for a request handler.
abstract class RequestHandler {
  RequestHandler();

  /// Creates a request handler that delegates handling requests to a
  /// user-scpecified function. Convenient in tests and other situations.
  factory RequestHandler.fromFunction(RequestHandlingFunction func) {
    return new _FunctionRequestHandler(func);
  }

  Stream handle(Request request);
  RequestHandler transformResponses(RequestStreamTransformer transformer)
      => new TransformingRequestHandler(this, transformer);
}

class _FunctionRequestHandler extends RequestHandler {
  final RequestHandlingFunction _func;

  _FunctionRequestHandler(RequestHandlingFunction this._func);

  Stream handle(Request request) => _func(request);
}

/// The root object representing an entire API, which makes its resources
/// available.
abstract class Root {
  final TypeRegistry typeRegistry;

  /// The API service path.
  String get servicePath;

  /// Execute a [Request] and return a [Stream] of the results.
  Stream send(Request req);

  Root(this.typeRegistry);
}

/// Method path regex, capturing parameter names enclosed in {}.
RegExp pathRegex = new RegExp(r'(\{[^\}]+\})');

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
  final LocalDataMap local = new LocalDataMap();

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
            (payload[param] is String || payload[param] is int || payload[param] is int64)) {
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
