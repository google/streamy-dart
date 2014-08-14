// Implementations based on in-browser [HttpRequest]. Classes defined here can
// only be used in applications that run inside a web-browser. They don't work
// outside the web-browser. For out-of-browser implementations, check out
// impl_server.dart.
library streamy.html_impl;

import 'dart:html';
import 'dart:async';

import 'package:streamy/streamy.dart' hide HttpRequest;
import 'impl.dart';

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
    req.onError.first.then((_) => c.completeError(new StreamyHttpError(
        // The passed ProgressEvent doesn't contain any useful information.
        'An error occured communicating with the server')));
    return c.future;
  }
}

/// A [SimpleRequestHandler] specialized for use in applications that run
/// inside a web-browser.
class HtmlRequestHandler extends SimpleRequestHandler {
  HtmlRequestHandler([String apiServerAddress]) :
    super(const HtmlHttpService(), apiServerAddress: apiServerAddress);
}
