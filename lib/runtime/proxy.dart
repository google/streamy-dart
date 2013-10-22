part of streamy.runtime;

/// A [RequestHandler] that proxies through a frontend server.
class ProxyClient extends RequestHandler {

  /// The base url of the proxy.
  final String proxyUrl;
  final StreamyHttpService httpHandler;

  ProxyClient(this.proxyUrl, this.httpHandler);

  Stream handle(Request req) {
    var url = '$proxyUrl/${req.root.servicePath}${req.path}';
    var payload = req.hasPayload ? stringify(req.payload) : null;
    var headers = {
      'Content-Type': 'application/json; charset=utf-8',
    };
    var cancelCompleter = new Completer();
    var httpReq = new StreamyHttpRequest(url, req.httpMethod, headers,
        req.local, cancelCompleter.future, payload: payload);
    var httpResponseWaiter = httpHandler.send(httpReq);

    var c;
    c = new StreamController(onCancel: () {
      // Only cancel requests if they haven't already completed.
      if (!c.isClosed) {
        cancelCompleter.complete(null);
      }
    });

    httpResponseWaiter.then((resp) {
      if (resp.statusCode != 200) {
        Map jsonError = null;
        List errors = null;
        // If the bodyType is not available, optimistically try parsing it as
        // JSON.
        if (resp.bodyType == null ||
            resp.bodyType.startsWith('application/json')) {
          try {
            jsonError = parse(resp.body);
            if (jsonError.containsKey('error') &&
                jsonError['error'].containsKey('errors')) {
              errors = jsonError['error']['errors'];
            }
          } catch(_) {
            // Apparently, body wan't JSON. The caller will have to make do.
          }
        }
        throw new StreamyRpcException(resp.statusCode, req, jsonError);
      }
      return req.responseDeserializer(resp.body);
    }).then((value) {
      c.add(value);
      c.close();
    }).catchError((error) {
      c.addError(error);
      c.close();
    });
    return c.stream;
  }
}

/// Translation of a [Request] into HTTP parts.
class StreamyHttpRequest {
  /// Complete request URL.
  final String url;

  /// HTTP method
  final String method;

  /// HTTP headers
  final Map<String, String> headers;

  /// Local customizations of request. These could be anything and their
  /// interpretation is up to the implementation of the [StreamyHttpService].
  final Map local;

  /// Tells the [StreamyHttpService] that this request was cancelled by the
  /// client so that [StreamyHttpService] could clean-up.
  final Future onCancel;

  /// Optional request payload.
  final String payload;

  StreamyHttpRequest(this.url, this.method, this.headers, this.local,
      this.onCancel, {this.payload});
}

/// Contains raw data of a HTTP response.
class StreamyHttpResponse {
  /// HTTP status code, e.g. 200, 404.
  final int statusCode;

  /// Status line, e.g. "200 OK".
  final String statusText;

  /// Response body
  final String body;

  /// Response content type
  final String bodyType;

  StreamyHttpResponse(this.statusCode, this.statusText, this.body,
      this.bodyType);
}

/// Sends raw HTTP requests to the server.
abstract class StreamyHttpService {
  /// Sends a raw HTTP [request] to the server.
  Future<StreamyHttpResponse> send(StreamyHttpRequest request);
}
