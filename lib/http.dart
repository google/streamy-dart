library streamy.http;

import 'dart:convert';
import 'dart:math';

var _RANDOM = new Random();
var _UTF8 = new Utf8Codec();

class HttpRequest {
  final String body;
  final String url;
  final String method;
  final Map<String, String> headers = <String, String>{};
  
  HttpRequest(this.url, {this.method: 'GET', this.body: null, headers: null}) {
    if (headers != null) {
      headers.forEach((name, value) {
        this.headers[name.toLowerCase()] = value;
      });
    }
    if (body != null && !this.headers.containsKey('content-length')) {
      // Determine content length based on Utf8 encoded body.
      this.headers['content-length'] = _UTF8.encoder.convert(body).length.toString();
    }
  }
  
  factory HttpRequest.multipart(String url, List<HttpRequest> requests, {String method: 'POST', Map<String, String> headers: null}) {
    var boundary = _generateBoundary();
    var body = '--$boundary\r\n' + requests.map((r) => r.toString()).join('--$boundary\r\n');
    return new HttpRequest(url, method: method, headers: headers, body: body)
      ..headers['content-type'] = 'multipart/mixed; boundary=$boundary';
  }
  
  String toString() {
    var buffer = new StringBuffer();
    buffer.write('$method $url HTTP/1.1\r\n');
    headers.forEach((name, value) => buffer.write("$name: $value\r\n"));
    if (body != null) {
      buffer.write('\r\n');
      buffer.write(body);
    }
    buffer.write('\r\n');
    return buffer.toString();
  }
}

class HttpResponse {
  
  static HttpResponse parse(String response) {
    var body = '';
    var i = response.indexOf('\r\n\r\n');
    if (i != -1) {
      body = response.substring(i + 4);
      response = response.substring(0, i);
    }
    var lines = response.split('\r\n');
    var first = lines.first;
    var headers = lines.skip(1);
    var headerData = <String, String>{};
    var code = int.parse(first.split(' ')[0]);
    headers.forEach((line) {
      var i = line.indexOf(':');
      if (i == -1) {
        return;
      }
      var name = line.substring(0, i).toLowerCase();
      var value = line.substring(i + 1).trim();
      headerData[name] = value;
    });
    if (headerData.containsKey('content-length')) {
      body = _trimBody(body, int.parse(headerData['content-length']));
    }
    return new HttpResponse(code, headerData, body);
  }
  
  List<HttpResponse> splitMultipart() {
    var cType = headers['content-type'];
    if (!cType.startsWith('multipart/mixed;')) {
      throw new StateError('Not a mulipart content type: $cType');
    }
    var boundary = cType.substring(cType.indexOf('=') + 1);
    return body.split('--$boundary\r\n').skip(1).map(parse).toList();
  }

  final int statusCode;
  final String body;
  final Map<String, String> headers;
  
  HttpResponse(this.statusCode, this.headers, this.body);
}

String _trimBody(String body, int byteLength) {
  var strLength = body.length;
  List<int> bytes = _UTF8.encoder.convert(body);
  if (bytes.length <= byteLength) {
    return body;
  }
  bytes.length = byteLength;
  return _UTF8.decoder.convert(bytes);
}

String _generateBoundary() =>
    new String.fromCharCodes(new List<int>.generate(50, (_) => 65 + _RANDOM.nextInt(26)));
    