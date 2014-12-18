library streamy.generated.illegal_names.test;

import 'dart:async';
import 'package:unittest/unittest.dart';
import 'package:streamy/streamy.dart';
import 'illegal_names_client.dart';
import 'illegal_names_client_requests.dart';
import 'illegal_names_client_resources.dart';
import 'illegal_names_client_objects.dart';
import 'illegal_names_client_dispatch.dart';

main() {
  group('IllegalNamesTest', () {
    test('RequestResponseCycle as response', () {
      $Type testResponse = new $Type()..id = 1;
      var marshaller = new Marshaller();
      var testResponsePayload = new Response(
          marshaller.unmarshalType(jsonMarshal(testResponse)), Source.RPC, 0);
      var testRequestHandler = new RequestHandler.fromFunction(
          (req) => new Stream.fromIterable([testResponsePayload]));
      var subject = new IllegalNamesTest(testRequestHandler);
      subject.types.get(1).send().listen(expectAsync(($Type v) {
        expect(jsonMarshal(v), equals(jsonMarshal(testResponse)));
      }, count: 1));
    });
    test('RequestResponseCycle as field', () {
      var type = new $Type()..id = 2;
      Foo testResponse = new Foo()
          ..id = 1
          ..fooType = type;
      var marshaller = new Marshaller();
      var testRequestHandler = new RequestHandler.fromFunction(
          (req) => new Stream.fromIterable(
              [new Response(marshaller.unmarshalFoo(jsonMarshal(testResponse)), Source.RPC, 0)]));
      var subject = new IllegalNamesTest(testRequestHandler);
      subject.foos.get(1).send().listen(expectAsync((Foo v) {
        expect(jsonMarshal(v), equals(jsonMarshal(testResponse)));
      }, count: 1));
    });
  });
  group('Illegally named property apiType', () {
    test('of Type', () {
      expect($Type.API_TYPE, '\$Type');
      expect(new $Type().apiType, '\$Type');
    });
    test('of TypesResource', () {
      expect(TypesResource.API_TYPE, 'TypesResource');
      expect(new IllegalNamesTest(null).types.apiType, 'TypesResource');
    });
    test('of TypesGetRequest', () {
      expect(TypesGetRequest.API_TYPE, 'TypesGetRequest');
      expect(new IllegalNamesTest(null).types.get(1).apiType, 'TypesGetRequest');
    });
  });
  group('Illegally named property serialization', () {
    test('to/from json as object', () {
      var f = new $Type()..id = 1;
      var m = new Marshaller();
      var f2 = m.unmarshalType(jsonMarshal(f));
      expect(f2.id, equals(1));
    });
    test('to/from json as field', () {
      var type = new $Type()..id = 2;
      var foo = new Foo()
          ..id = 1
          ..fooType = type;
      var m = new Marshaller();
      var foo2 = m.unmarshalFoo(jsonMarshal(foo));
      expect(foo2.id, equals(1));
      expect(foo2.fooType.id, equals(2));
    });
  });
}
