import 'package:streamy/http.dart' as http;
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
      var req = new http.HttpRequest('/test/url',
          headers: {'Host': 'google.com', 'Accept-Encoding': 'utf-8'});
      expect(req.toString(), equals(
          'GET /test/url HTTP/1.1\r\nhost: google.com\r\naccept-encoding: utf-8\r\n\r\n'));
    });
    test('Multipart request', () {
      var req1 = new http.HttpRequest('/test/url',
          headers: {'Host': 'google.com', 'Accept-Encoding': 'utf-8'});
      var req2 = new http.HttpRequest('/test/another/url', method: 'POST', body: 'Hello world!',
          headers: {'Host': 'api.google.com', 'Content-Type': 'text/plain; charset=utf-8'});
      var req3 = new http.HttpRequest('/a/third/url', body: 'Goodbye world!',
          headers: {'Host': 'google.com', 'Accept-Encoding': 'utf-8'});
      var mpReq = new http.HttpRequest.multipart('/multipart/url', [req1, req2, req3],
          method: 'PUT', headers: {'Host': 'multipart.google.com'});
      var cType = mpReq.headers['content-type'];
      var boundary = cType.split('=')[1];
      expect(cType.startsWith('multipart/mixed; boundary='), isTrue);
      expect(mpReq.headers['content-length'], equals('469'));
      expect(mpReq.headers['host'], equals('multipart.google.com'));
      expect(mpReq.body, equals('--$boundary\r\nGET /test/url HTTP/1.1\r\nhost: google.com\r\n' +
          'accept-encoding: utf-8\r\n\r\n--$boundary\r\nPOST /test/another/url HTTP/1.1\r\n' +
          'host: api.google.com\r\ncontent-type: text/plain; charset=utf-8\r\ncontent-length: 12' +
          '\r\n\r\nHello world!\r\n--$boundary\r\nGET /a/third/url HTTP/1.1\r\nhost: google.com' +
          '\r\naccept-encoding: utf-8\r\ncontent-length: 14\r\n\r\nGoodbye world!\r\n'));
    });
  });
  group('Http Response', () {
    test('Simple response', () {
      var hr = http.HttpResponse.parse(SIMPLE_RESPONSE);
      expect(hr.statusCode, equals(200));
      expect(hr.headers.length, equals(3));
      expect(hr.headers['host'], equals('google.com'));
      expect(hr.headers['content-type'], equals('text/plain; charset=utf-8'));
      expect(hr.headers['content-length'], equals('12'));
      expect(hr.body, equals('Hello World!'));
    });
    test('Multipart response', () {
      var hr = http.HttpResponse.parse(MULTIPART_RESPONSE);
      var parts = hr.splitMultipart();
      expect(parts[0].body, equals('Hello World!'));
      expect(parts[1].body, equals('Hello Moon!'));
      expect(parts[2].body, equals('Hello Sun!'));
    });
  });
}