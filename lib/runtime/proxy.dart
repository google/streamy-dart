part of streamy.runtime;

const _CONTENT_TYPE = 'content-type';

/// A [RequestHandler] that proxies through a frontend server.
class ProxyClient extends RequestHandler {

  /// The base url of the proxy.
  final String proxyUrl;
  final StreamyHttpService httpHandler;

  ProxyClient(this.proxyUrl, this.httpHandler);

  Stream<Response> handle(Request req, Trace trace) {
    var url = '$proxyUrl/${req.root.servicePath}${req.path}';
    var payload = req.hasPayload ? stringify(req.payload) : null;
    var headers = const {
      _CONTENT_TYPE: 'application/json; charset=utf-8',
    };
    var cancelCompleter = new Completer();
    var httpReq = new StreamyHttpRequest(url, req.httpMethod, headers,
        req.local, cancelCompleter.future, payload: payload);
    var waitForHttpResponse = httpHandler.send(httpReq);

    var c;
    c = new StreamController<Response>(onCancel: () {
      // Only cancel requests if they haven't already completed.
      if (!c.isClosed) {
        cancelCompleter.complete(null);
      }
    });

    waitForHttpResponse.then((StreamyHttpResponse resp) {
      if (resp.statusCode != 200) {
        Map jsonError = null;
        List errors = null;
        // If the bodyType is not available, optimistically try parsing it as
        // JSON.
        if (resp.headers.containsKey(_CONTENT_TYPE) == null ||
            resp.headers[_CONTENT_TYPE].startsWith('application/json')) {
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
      return new Response(req.responseDeserializer(resp.body, trace),
          Source.RPC, new DateTime.now().millisecondsSinceEpoch);
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
