// Implementations based on in-browser [HttpRequest]
library streamy.html_impl;

import 'dart:html';
import 'dart:async';

import "package:streamy/streamy.dart";
import "impl.dart";

/**
 * A plain HTTP service that sends HTTP requests via [HttpRequest].
 */
class HtmlHttpService implements StreamyHttpService {

  const HtmlHttpService();

  Future<StreamyHttpResponse> send(StreamyHttpRequest request) {
    var req = new HttpRequest();

    req.open(request.method, request.url, async: true);
    if (request.payload != null) {
      request.headers.forEach((k, v) {
        req.setRequestHeader(k, v);
      });
      req.send(request.payload);
    } else {
      req.send();
    }

    request.onCancel.then((_) {
      req.abort();
    });

    var c = new Completer<StreamyHttpResponse>();
    req.onLoad.first.then((_) {
      var bodyType = null;
      var responseType = req.getResponseHeader('Content-Type');
      if (responseType != null) {
        bodyType = responseType.split(';')[0];
      }
      c.complete(new StreamyHttpResponse(req.status, req.responseHeaders,
          req.responseText));
    });
    req.onError.first.then(c.completeError);
    return c.future;
  }
}

class HtmlRequestHandler extends SimpleRequestHandler {
  HtmlRequestHandler() : super(const HtmlHttpService());
}
