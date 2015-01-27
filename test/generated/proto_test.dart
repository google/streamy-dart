library streamy.generated.proto.test;

import 'dart:async';
import 'package:unittest/unittest.dart';
import 'package:streamy/streamy.dart';
import 'proto_client.dart';
import 'import_client.dart' hide Marshaller;

main() {
  group('ProtoTest', () {
    var f = new Foo()
      ..name = 'Foo Test Object'
      ..other = [
        new Bar()..name = 'Bar #1',
        new Bar()..name = 'Bar #2'
      ];
    var m = new Marshaller();

    test('Serializes with tag numbers', () {
      var fm = m.marshalFoo(f);
      expect(fm, containsPair('2', 'Foo Test Object'));
      expect(fm, contains('3'));
      var others = fm['3'];
      expect(others, isList);
      expect(others, hasLength(2));
      expect(others[0], containsPair('2', 'Bar #1'));
      expect(others[1], containsPair('2', 'Bar #2'));
    });

    test('Serializer pass-through works as intended', () {
      var m = new Marshaller();
      var f2 = m.unmarshalFoo(m.marshalFoo(f));
      expect(f2.name, 'Foo Test Object');
      expect(f2.other, isList);
      expect(f2.other, hasLength(2));
      expect(f2.other[0].name, 'Bar #1');
      expect(f2.other[1].name, 'Bar #2');
    });

    test('Can make a Foo request.', () {
      var bar = new Bar()
        ..name = 'ResponseBar';
      var api = new TestProto(new RequestHandler.fromFunction(
          (_) => new Stream.fromIterable([new Response(bar, Source.RPC, 0)])));
      var res = api.Test.Get(new Foo()..name = 'TestRequest')
          .send().single.then((v) {
        expect(v.name, 'ResponseBar');      
      });
    });

    test('Url for test get is correct.', () {
      var api = new TestProto(null);
      var req = api.Test.Get(new Foo()..name = 'TestRequest');
      expect(api.servicePath, 'test/service/');
      expect(req.path, 'Test/Get');
    });

    test('Enum field accepts a value.', () {
      var bar = new Bar();
      bar.ev = TestEnum.BETA;
    });

    test('Enum field serializes.', () {
      var bar = new Bar()
        ..ev = TestEnum.GAMMA;
      var m = const Marshaller();
      expect(m.marshalBar(bar)['4'], 3);
    });

    test('Enum field deserializes', () {
      var map = {'4': 1};
      var bar = const Marshaller().unmarshalBar(map);
      expect(bar.ev, TestEnum.ALPHA);
    });

    test('Nested enum serializes', () {
      var bar = new Bar()
        ..nestedEnum1 = BarNestedEnum1.A
        ..nestedEnum2 = BarNestedMessage1NestedMessage2NestedEnum2.Y;
      var m = const Marshaller();
      expect(m.marshalBar(bar)['5'], 1);
      expect(m.marshalBar(bar)['6'], 2);
    });

    test('Nested enum deserializes', () {
      var map = {'5': 1, '6': 3};
      var bar = const Marshaller().unmarshalBar(map);
      expect(bar.nestedEnum1, BarNestedEnum1.A);
      expect(bar.nestedEnum2, BarNestedMessage1NestedMessage2NestedEnum2.Z);
    });

    test('Nested message serializes', () {
      var message1 = new BarNestedMessage1()..nameFoo = 'test1';
      var message2 = new BarNestedMessage1NestedMessage2()..name = 'test2';
      var bar = new Bar()
        ..nestedMessage1 = message1
        ..nestedMessage2 = message2;
      var m = const Marshaller();
      expect(m.marshalBar(bar)['7']['1'], 'test1');
      expect(m.marshalBar(bar)['8']['1'], 'test2');
    });

    test('Nested message deserializes', () {
      var map = {'7': {'1': 'test3'}, '8': {'1': 'test4'}};
      var bar = const Marshaller().unmarshalBar(map);
      expect(bar.nestedMessage1.nameFoo, 'test3');
      expect(bar.nestedMessage2.name, 'test4');
    });

    test('Nested enum from import serializes', () {
      var bar = new Bar()
        ..importedEnum = BazNestedEnum.E;
      var m = const Marshaller();
      expect(m.marshalBar(bar)['9'], 2);
    });

    test('Nested enum from import deserializes', () {
      var map = {'9': 3};
      var bar = const Marshaller().unmarshalBar(map);
      expect(bar.importedEnum, BazNestedEnum.Z);
    });

    test('Nested message from import serializes', () {
      var message = new BazNestedMessage()..name = 'test name 1';
      var bar = new Bar()
        ..importedMessage = message;
      var m = const Marshaller();
      expect(m.marshalBar(bar)['10']['1'], 'test name 1');
    });

    test('Nested message from import deserializes', () {
      var map = {'10': {'1': 'test name 3'}};
      var bar = const Marshaller().unmarshalBar(map);
      expect(bar.importedMessage.name, 'test name 3');
    });
  });
}
