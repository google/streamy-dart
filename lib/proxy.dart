library streamy_proxy;

import "dart:async";
import "dart:html";
import "dart:json" as json;
import "base.dart";

/// A [RequestHandler] that proxies through a frontend server.
class ProxyClient implements RequestHandler {

  /// The base url of the proxy.
  final String baseUrl;

  ProxyClient(this.baseUrl);

  Stream handle(Request req) {
    var res;
    if (req.hasPayload) {
      res = HttpRequest.request("$baseUrl/${req.path}",
          method: req.httpMethod, sendData: req.hasPayload ? json.stringify(req.payload) : null);
    } else {
      res = HttpRequest.request("$baseUrl/${req.path}",
          method: req.httpMethod);
    }
    return res.then((httpReq) =>
        req.responseDeserializer(httpReq.responseText)).asStream();
  }
}