part of streamy.runtime;

/// A [RequestHandler] that proxies through a frontend server.
class ProxyClient extends RequestHandler {

  /// The base url of the proxy.
  final String proxyUrl;
  final StreamyHttpService httpHandler;
  final Clock clock;

  ProxyClient(this.proxyUrl, this.httpHandler, {this.clock: const Clock()});

  Stream<Response> handle(Request req, Trace trace) {
    var url = '$proxyUrl/${req.root.servicePath}${req.path}';
    var payload = req.hasPayload ? stringify(req.payload) : null;
    var httpRequest = httpHandler.request(url, req.httpMethod, payload: payload);

    var c;
    c = new StreamController<Response>(onCancel: () {
      // Only cancel requests if they haven't already completed.
      if (!c.isClosed) {
        httpRequest.cancel();
      }
    });

    httpRequest.future.then((resp) {
      if (resp.statusCode != 200) {
        Map jsonError = null;
        List errors = null;
        // If the bodyType is not available, optimistically try parsing it as JSON.
        if (resp.bodyType == null || resp.bodyType.startsWith('application/json')) {
          try {
            jsonError = parse(resp.body);
            if (jsonError.containsKey('error') && jsonError['error'].containsKey('errors')) {
              errors = jsonError['error']['errors'];
            }
          } catch(_) {
            // Apparently, the body wan't JSON. The caller will have to make do.
          }
        }
        throw new StreamyRpcException(resp.statusCode, req, jsonError);
      }
      return new Response(req.responseDeserializer(resp.body), Source.RPC,
          clock.now().millisecondsSinceEpoch);
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

class ProxyRequestSent implements TraceEvent {
  factory ProxyRequestSent() => const ProxyRequestSent._private();

  const ProxyRequestSent._private();

  String toString() => 'streamy.proxy.sent';
}

class StreamyHttpRequest {
  final Future<StreamyHttpResponse> future;
  final CancelFn cancel;

  StreamyHttpRequest(this.future, this.cancel);
}

class StreamyHttpResponse {
  final int statusCode;
  final String statusText;
  final String body;
  final String bodyType;

  StreamyHttpResponse(this.statusCode, this.statusText, this.body, this.bodyType);
}

abstract class StreamyHttpService {
  StreamyHttpRequest request(String url, String method,
      {String payload: null, String contentType: 'application/json; charset=utf-8'});
}
