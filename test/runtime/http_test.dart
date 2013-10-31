library streamy.runtime.http.test;

import 'package:streamy/streamy.dart';
import 'package:unittest/unittest.dart';

var SIMPLE_RESPONSE = [
    '200 OK',
    'Host: google.com',
    'Content-Type: text/plain; charset=utf-8',
    'Content-Length: 12',
    '',
    'Hello World!',
    ''
  ].join('\r\n');
var SIMPLE_RESPONSE_2 = [
    '200 OK',
    'Host: api.google.com',
    'Content-Type: text/html; charset=utf-8',
    'Content-Length: 11',
    '',
    'Hello Moon!',
    ''
  ].join('\r\n');
var SIMPLE_RESPONSE_3 = [
    '201 Created',
    'Host: client6.google.com',
    'Content-Type: application/json; charset=utf-8',
    'Content-Length: 10',
    '',
    'Hello Sun!',
    ''
  ].join('\r\n');
var MULTIPART_RESPONSE = [
    '200 OK',
    'Host: google.com',
    'Content-Type: multipart/mixed; boundary=ABCDEFG',
    '',
    '--ABCDEFG',
    SIMPLE_RESPONSE,
    '--ABCDEFG',
    SIMPLE_RESPONSE_2,
    '--ABCDEFG',
    SIMPLE_RESPONSE_3
  ].join('\r\n');

main() {
  group('Http Request', () {
    test('Simple get', () {
      var req = new StreamyHttpRequest('/test/url', 'GET',
          {'Host': 'google.com', 'Accept-Encoding': 'utf-8'}, {}, null);
      expect(req.toString(), equals(
'''GET /test/url HTTP/1.1
host: google.com
accept-encoding: utf-8

'''.replaceAll('\n', '\r\n')));
    });
    test('Multipart request', () {
      var req1 = new StreamyHttpRequest('/test/url', 'GET',
          {'Host': 'google.com', 'Accept-Encoding': 'utf-8'}, {}, null);
      var req2 = new StreamyHttpRequest('/test/another/url', 'POST',
          {
            'Host': 'api.google.com',
            'Content-Type': 'text/plain; charset=utf-8',
          },
          {}, null, payload: 'Hello world!');
      var req3 = new StreamyHttpRequest('/a/third/url', 'POST',
          {'Host': 'google.com', 'Accept-Encoding': 'utf-8'},
          {}, null, payload: 'Goodbye world!');
      var mpReq = new StreamyHttpRequest.multipart('/multipart/url', 'PUT',
          {'Host': 'multipart.google.com'}, null, [req1, req2, req3]);
      var cType = mpReq.headers['content-type'];
      var boundary = cType.split('=')[1];
      expect(cType.startsWith('multipart/mixed; boundary='), isTrue);
      expect(mpReq.headers['content-length'], equals('470'));
      expect(mpReq.headers['host'], equals('multipart.google.com'));
      expect(mpReq.payload, equals(
'''--$boundary
GET /test/url HTTP/1.1
host: google.com
accept-encoding: utf-8

--$boundary
POST /test/another/url HTTP/1.1
host: api.google.com
content-type: text/plain; charset=utf-8
content-length: 12

Hello world!
--$boundary
POST /a/third/url HTTP/1.1
host: google.com
accept-encoding: utf-8
content-length: 14

Goodbye world!
'''.replaceAll('\n', '\r\n')));
    });
  });
  group('Http Response', () {
    test('Simple response', () {
      var hr = StreamyHttpResponse.parse(SIMPLE_RESPONSE);
      expect(hr.statusCode, equals(200));
      expect(hr.headers.length, equals(3));
      expect(hr.headers['host'], equals('google.com'));
      expect(hr.headers['content-type'], equals('text/plain; charset=utf-8'));
      expect(hr.headers['content-length'], equals('12'));
      expect(hr.body, equals('Hello World!'));
    });
    test('Multipart response', () {
      var hr = StreamyHttpResponse.parse(MULTIPART_RESPONSE);
      var parts = hr.splitMultipart();
      expect(parts[0].body, equals('Hello World!'));
      expect(parts[1].body, equals('Hello Moon!'));
      expect(parts[2].body, equals('Hello Sun!'));
    });
  });
}
