library streamy.generated.method_get.test;

import 'dart:async';
import 'package:json/json.dart';
import 'package:unittest/unittest.dart';
import 'package:streamy/streamy.dart';
import 'method_get_client.dart';
import 'method_get_client_requests.dart';
import 'method_get_client_resources.dart';
import 'method_get_client_objects.dart';
import 'method_get_client_dispatch.dart';

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
      var marshaller = new Marshaller();
      var testRequestHandler = new RequestHandler.fromFunction(
          (req) => new Stream.fromIterable(
              [new Response(req.unmarshalResponse(marshaller, marshaller.marshalFoo(testResponse)), Source.RPC, 0)]));
      var subject = new MethodGetTest(testRequestHandler);
      subject.foos.get(1).send().listen(expectAsync((Foo v) {
        expect(marshaller.marshalFoo(v), equals(marshaller.marshalFoo(testResponse)));
      }, count: 1));
    });
    test('API root has proper service path', () {
      var subject = new MethodGetTest(null);
      expect(subject.servicePath, equals('getTest/v1/'));
    });
  });
  group('apiType', () {
    test('of MethodGetTest', () {
      expect(MethodGetTest.API_TYPE, 'MethodGetTest');
      expect(new MethodGetTest(null).apiType, 'MethodGetTest');
    });
    /* TODO: fix test
    test('of MethodGetTestTransaction', () {
      expect(MethodGetTestTransaction.API_TYPE, 'MethodGetTestTransaction');
      expect(new MethodGetTestTransaction(null, null).apiType,
          'MethodGetTestTransaction');
    });
    */
    test('of Foo', () {
      expect(Foo.API_TYPE, 'Foo');
      expect(new Foo().apiType, 'Foo');
    });
    test('of FoosResource', () {
      expect(FoosResource.API_TYPE, 'FoosResource');
      expect(new MethodGetTest(null).foos.apiType, 'FoosResource');
    });
    test('of FoosGetRequest', () {
      expect(FoosGetRequest.API_TYPE, 'FoosGetRequest');
      expect(new MethodGetTest(null).foos.get(1).apiType, 'FoosGetRequest');
    });
  });
  group('Serialization', () {
    test('to/from json', () {
      var f = new Foo()
        ..id = 1;
      var m = new Marshaller();
      var f2 = m.unmarshalFoo(m.marshalFoo(f));
      expect(f2.containsKey('bar'), isFalse);
      expect(f2.containsKey('baz'), isFalse);
    });
  });
}
