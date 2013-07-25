library streamy.generated.method_get.test;

import 'dart:async';
import 'dart:json';
import 'package:unittest/unittest.dart';
import 'package:streamy/streamy.dart';
import 'method_get_client.dart';

main() {
  group('MethodGetTest', () {
    test('RequestHttpMethod', () {
      var subject = new MethodGetTest(null);
      expect(subject.foos.get(1).httpMethod, equals('GET'));
    });
    test('RequestPayload', () {
      var subject = new MethodGetTest(null);
      expect(subject.foos.get(1).hasPayload, equals(false));
    });
    test('RequestResponseCycle', () {
      Foo testResponse = new Foo()
        ..id = 1
        ..bar = 'bar';
      var testRequestHandler = new RequestHandler.fromFunction(
          (req) => new Stream.fromIterable(
              [req.responseDeserializer(stringify(testResponse.toJson()))]));
      var subject = new MethodGetTest(testRequestHandler);
      subject.foos.get(1).send().listen(expectAsync1((Foo v) {
        expect(v.toJson(), equals(testResponse.toJson()));
      }, count: 1));
    });
    test('API root has proper service path', () {
      var subject = new MethodGetTest(null);
      expect(subject.servicePath, equals('getTest/v1/'));
    });
  });
}
