// Implementations for out-of-browser applications, such as command-line apps
// and servers. For in-browser applications use impl_html.dart.
library streamy.server_impl;

import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:streamy/streamy.dart';
import 'impl.dart';

/**
 * A plain HTTP service that sends HTTP requests via [HttpRequest].
 */
class ServerHttpService implements StreamyHttpService {

  final _httpClient = new HttpClient();

  ServerHttpService();

  // TODO(yjbanov): Not sure how to cancel HTTP requests
  Future<StreamyHttpResponse> send(StreamyHttpRequest request) => _httpClient
    .openUrl(request.method, Uri.parse(request.url))
    .then((HttpClientRequest req) {
      if (request.payload != null) {
        request.headers.forEach((k, v) {
          req.headers.add(k, v);
        });
        req.write(request.payload);
      }
      return req.close();
    })
    .then((HttpClientResponse resp) {
      var responseType = resp.headers[HttpHeaders.CONTENT_TYPE];
      var responseHeaders = {};
      resp.headers.forEach((String name, List<String> values) {
        responseHeaders[name] = values[0];
      });

      return resp.transform(const Utf8Decoder())
        .fold(new StringBuffer(), (buf, e) => buf..write(e))
        .then((StringBuffer responseBody) =>
          new StreamyHttpResponse(resp.statusCode, responseHeaders,
              responseBody.toString()));
    });
}

/// A [SimpleRequestHandler] specialized for use in server-side or command-line
/// applications.
class ServerRequestHandler extends SimpleRequestHandler {
  ServerRequestHandler([String apiServerAddress]) :
    super(new ServerHttpService(), apiServerAddress: apiServerAddress);
}
