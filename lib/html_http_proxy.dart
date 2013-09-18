// Implementation of [ProxyClient] based on in-browser [HttpRequest]
library streamy.html_http_proxy;

import 'dart:html';
import 'dart:async';

import "package:streamy/streamy.dart";

class DartHtmlHttpService implements StreamyHttpService {

  const DartHtmlHttpService();

  StreamyHttpRequest request(String url, String method,
      {String payload: null, String contentType: 'application/json; charset=utf-8'}) {
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
      c.complete(new StreamyHttpResponse(req.status, req.statusText,
          req.responseText, bodyType));
    });
    req.onError.first.then(c.completeError);

    return new StreamyHttpRequest(
        c.future,
        () {
          req.abort();
        });
  }
}
