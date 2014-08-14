part of streamy.runtime;

const _CONTENT_TYPE = 'content-type';

/// A [RequestHandler] that proxies through a frontend server.
class ProxyClient extends RequestHandler {

  /// The base url of the proxy.
  final String proxyUrl;
  final StreamyHttpService httpHandler;

  ProxyClient(this.proxyUrl, this.httpHandler);

  Stream<Response> handle(Request originalReq, Trace trace) {
    if (originalReq is! HttpRequest) {
      throw new ProxyClientException('ProxyClient only works with HttpRequests');
    }
    HttpRequest req = originalReq;
    HttpRoot root = req.root;
    var url = '$proxyUrl/${root.servicePath}${req.path}';
    var payload = null;
    var headers = {};
    if (req.hasPayload) {
      payload = JSON.encode(req.marshalPayload());
      headers[_CONTENT_TYPE] = 'application/json; charset=utf-8';
    }
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
      if (resp.statusCode < 200 || resp.statusCode >= 300) {
        Map jsonError = null;
        // If the bodyType is not available, optimistically try parsing it as
        // JSON.
        if (!resp.headers.containsKey(_CONTENT_TYPE) ||
            resp.headers[_CONTENT_TYPE].startsWith('application/json')) {
          try {
            jsonError = JSON.decode(resp.body);
          } catch(_) {
            // Apparently, body wan't JSON. The caller will have to make do.
          }
        }
        throw new StreamyRpcException(resp.statusCode, req, jsonError);
      }
      Freezeable responsePayload = null;
      if (resp.statusCode == 200 || resp.statusCode == 201) {
        var responseJson = jsonParse(resp.body, trace);
        trace.record(new DeserializationStartEvent(resp.body.length));
        responsePayload = req.unmarshalResponse(responseJson);
        responsePayload.freeze();
        trace.record(new DeserializationEndEvent());
      }
      return new Response(responsePayload, Source.RPC,
          new DateTime.now().millisecondsSinceEpoch);
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

class ProxyClientException extends StreamyException {
  final String _msg;
  ProxyClientException(this._msg);
  String toString() => 'ProxyClientException: $_msg';
}
