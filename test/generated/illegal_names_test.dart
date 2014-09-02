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
      var testRequestHandler = new RequestHandler.fromFunction(
          (req) => new Stream.fromIterable(
              [new Response(req.unmarshalResponse(marshaller.marshal$Type(testResponse)), Source.RPC, 0)]));
      var subject = new IllegalNamesTest(testRequestHandler);
      subject.types.get(1).send().listen(expectAsync(($Type v) {
        expect(marshaller.marshal$Type(v), equals(marshaller.marshal$Type(testResponse)));
      }, count: 1));
    });
    test('RequestResponseCycle as field', () {
      Foo testResponse = new Foo()
          ..id = 1
          ..type = new $Type()..id = 2;
      var marshaller = new Marshaller();
      var testRequestHandler = new RequestHandler.fromFunction(
          (req) => new Stream.fromIterable(
              [new Response(req.unmarshalResponse(marshaller.marshalFoo(testResponse)), Source.RPC, 0)]));
      var subject = new IllegalNamesTest(testRequestHandler);
      subject.foos.get(1).send().listen(expectAsync((Foo v) {
        expect(marshaller.marshalFoo(v), equals(marshaller.marshalFoo(testResponse)));
      }, count: 1));
    });
  });
  group('apiType', () {
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
  group('Serialization', () {
    test('to/from json as object', () {
      var f = new $Type()..id = 1;
      var m = new Marshaller();
      var f2 = m.unmarshal$Type(m.marshal$Type(f));
      expect(f2.id, equals(1));
    });
    test('to/from json as field', () {
      var f = new Foo()
          ..id = 1
          ..type = new $Type()..id = 2;
      var m = new Marshaller();
      var f2 = m.unmarshalFoo(m.marshalFoo(f));
      expect(f2.id, equals(1));
      expect(f2.type.id, equals(2));
    });
  });
}
