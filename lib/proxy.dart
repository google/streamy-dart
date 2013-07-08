library streamy_proxy;

import "dart:async";
import "dart:html";
import "dart:json" as json;
import "base.dart";

/// A [RequestHandler] that proxies through a frontend server.
class ProxyClient extends RequestHandler {

  /// The base url of the proxy.
  final String proxyUrl;
  final StreamyHttpService httpHandler;

  ProxyClient(this.proxyUrl, {this.httpHandler: const DartHtmlHttpService()});

  Stream handle(Request req) {
    var url = "$proxyUrl/${req.root.servicePath}${req.path}";
    var payload = req.hasPayload ? json.stringify(req.payload) : null;
    return httpHandler.request(url, req.httpMethod, payload).then((resp) {
      if (resp.statusCode != 200) {
        throw new ProxyException(httpReq.statusCode,
            "API call returned status: ${resp.statusText}");
      }
      return req.responseDeserializer(resp.body);
    }).asStream();
  }
}

class ProxyException implements Exception {

  final String message;
  final int code;

  ProxyException(this.message, this.code);

  String toString() => "$code: $message";
}

class StreamyHttpResponse {
  final int statusCode;
  final String statusText;
  final String body;

  StreamyHttpResponse(this.statusCode, this.statusText, this.body);
}

abstract class StreamyHttpService {

  Future<StreamyHttpResponse> request(String url, String method, {String payload: null, String contentType: "application/json"});
}

class DartHtmlHttpService implements StreamyHttpService {

  const DartHtmlHttpService();

  Future<StreamyHttpResponse> request(String url, String method, {String payload: null, String contentType: "application/json"}) {
    var res;
    if (payload != null) {
      res = HttpRequest.request(url, method: method, sendData: payload, requestHeaders: {"Content-Type": contentType});
    } else {
      res = HttpRequest.request(url, method: method);
    }
    return res.then((resp) {
      return new StreamyHttpResponse(resp.status, resp.statusText, resp.responseText);
    });
  }
}
