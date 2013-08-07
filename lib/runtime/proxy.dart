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
    return httpHandler.request(url, req.httpMethod, payload: payload).then((resp) {
      if (resp.statusCode != 200) {
        Map jsonError = null;
        // TODO(gadams): There isn't currently a way to get the reponse headers.
        // When that facility becomes available, use it to check that the
        // content type is actually "application/json" before trying to parse.
        try {
          jsonError = parse(resp.body);
        } catch(_) {
          // Apparently, the body wan't JSON. The caller will have to make do.
        }
        throw new ProxyException(
            'API call returned status: ${resp.statusText}', resp.statusCode,
            jsonError);
      }
      return req.responseDeserializer(resp.body);
    }).asStream();
  }
}

class ProxyException implements Exception {

  final String message;
  final int code;
  final Map apiError;

  ProxyException(this.message, this.code, this.apiError);

  String toString() => '$code: $message';
}

class StreamyHttpResponse {
  final int statusCode;
  final String statusText;
  final String body;
  final String bodyType;

  StreamyHttpResponse(this.statusCode, this.statusText, this.body, this.bodyType);
}

abstract class StreamyHttpService {
  Future<StreamyHttpResponse> request(String url, String method,
      {String payload: null, String contentType: 'application/json'});
}
