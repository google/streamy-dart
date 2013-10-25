part of streamy.runtime;

var _DEFAULT_RANDOM = new Random();
var _UTF8 = new Utf8Codec();

/// Sends raw HTTP requests to the server.
abstract class StreamyHttpService {
  /// Sends a raw HTTP [request] to the server.
  Future<StreamyHttpResponse> send(StreamyHttpRequest request);
}

/// Translation of a [Request] into HTTP parts.
class StreamyHttpRequest {
  /// Complete request URL.
  final String url;

  /// HTTP method
  final String method;

  /// HTTP headers
  final Map<String, String> headers;

  /// Local customizations of request. These could be anything and their
  /// interpretation is up to the implementation of the [StreamyHttpService].
  final Map local;

  /// Tells the [StreamyHttpService] that this request was cancelled by the
  /// client so that [StreamyHttpService] could clean-up.
  final Future onCancel;

  /// Optional request payload.
  final String payload;

  StreamyHttpRequest._private(this.url, this.method, this.headers, this.local,
      this.onCancel, this.payload);

  factory StreamyHttpRequest(String url, String method,
      Map<String, String> headers, Map local, Future onCancel,
      {String payload}) {
    var cleanHeaders = <String, String>{};
    if (headers != null) {
      headers.forEach((name, value) {
        cleanHeaders[name.toLowerCase()] = value;
      });
    }
    if (payload != null && !cleanHeaders.containsKey('content-length')) {
      // Determine content length based on Utf8 encoded body.
      cleanHeaders['content-length'] =
          _UTF8.encoder.convert(payload).length.toString();
    }

    return new StreamyHttpRequest._private(url, method, cleanHeaders, local,
        onCancel, payload);
  }

  factory StreamyHttpRequest.multipart(String url, String method,
      Map<String, String> headers, Future onCancel,
      List<StreamyHttpRequest> requests, {Random random}) {
    if (random == null) random = _DEFAULT_RANDOM;
    var boundary = _generateBoundary(random);
    var body = '--$boundary\r\n' +
        requests.map((r) => r.toString()).join('--$boundary\r\n');
    return new StreamyHttpRequest(url, method, headers, null, onCancel,
        payload: body)
      ..headers['content-type'] = 'multipart/mixed; boundary=$boundary';
  }

  String toString() {
    var buffer = new StringBuffer();
    buffer.write('$method $url HTTP/1.1\r\n');
    headers.forEach((name, value) => buffer.write("$name: $value\r\n"));
    if (payload != null) {
      buffer.write('\r\n');
      buffer.write(payload);
    }
    buffer.write('\r\n');
    return buffer.toString();
  }
}

/// Contains raw data of a HTTP response.
class StreamyHttpResponse {
  /// HTTP status code, e.g. 200, 404.
  final int statusCode;

  /// HTTP headers
  final Map<String, String> headers;

  /// Response body
  final String body;

  StreamyHttpResponse._private(this.statusCode, this.headers, this.body);

  factory StreamyHttpResponse(int statusCode, Map<String, String> headers,
      String body) {
    var cleanHeaders = <String, String>{};
    headers.forEach((k, v) {
      cleanHeaders[k.toLowerCase()] = v;
    });
    return new StreamyHttpResponse._private(statusCode, cleanHeaders, body);
  }

  static StreamyHttpResponse parse(String response) {
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
    return new StreamyHttpResponse._private(code, headerData, body);
  }

  List<StreamyHttpResponse> splitMultipart() {
    var cType = headers['content-type'];
    if (!cType.startsWith('multipart/mixed;')) {
      throw new StateError('Not a mulipart content type: $cType');
    }
    var boundary = cType.substring(cType.indexOf('=') + 1);
    return body.split('--$boundary\r\n').skip(1).map(parse).toList();
  }
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

String _generateBoundary(Random random) =>
    new String.fromCharCodes(new List<int>.generate(50,
        (_) => 65 + random.nextInt(26)));
