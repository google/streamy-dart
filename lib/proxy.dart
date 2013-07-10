library streamy.proxy;

import 'dart:async';
import 'dart:html';
import 'dart:json' as json;
import 'base.dart';

/// A [RequestHandler] that proxies through a frontend server.
class ProxyClient extends RequestHandler {

  /// The base url of the proxy.
  final String proxyUrl;
  final StreamyHttpService httpHandler;

  ProxyClient(this.proxyUrl, {this.httpHandler: const DartHtmlHttpService()});

  Stream handle(Request req) {
    var url = '$proxyUrl/${req.root.servicePath}${req.path}';
    var payload = req.hasPayload ? json.stringify(req.payload) : null;
    return httpHandler.request(url, req.httpMethod, payload: payload).then((resp) {
      if (resp.statusCode != 200) {
        Map jsonError = null;
        if (resp.bodyType == 'application/json') {
          jsonError = json.parse(resp.body);
        }
        throw new ProxyException(resp.statusCode,
            'API call returned status: ${resp.statusText}', jsonError);
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

  Future<StreamyHttpResponse> request(String url, String method, {String payload: null, String contentType: 'application/json'});
}

class DartHtmlHttpService implements StreamyHttpService {

  const DartHtmlHttpService();

  Future<StreamyHttpResponse> request(String url, String method, {String payload: null, String contentType: 'application/json'}) {
    var c = new Completer<StreamyHttpResponse>();

    var req = new HttpRequest();
    req.open(method, url, async: true);
    if (payload != null) {
      req.setRequestHeader('Content-Type', contentType);
      req.send(payload);
    } else {
      req.send();
    }

    req.onLoad.first.then((_) {
      var bodyType = null;
      var responseType = req.getResponseHeader('Content-Type');
      if (responseType != null) {
        bodyType = responseType.split(';')[0];
      }
      c.complete(new StreamyHttpResponse(req.status, req.statusText, req.responseText, bodyType));
    });
    req.onError.first.then(c.completeError);

    return c.future;
  }
}

