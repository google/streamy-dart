library streamy.generated.schema_unknown_fields.test;

import 'dart:mirrors';
import 'package:streamy/streamy.dart';
import 'package:unittest/unittest.dart';
import 'schema_unknown_fields_client_objects.dart';
import '../utils.dart';

main() {
  var reg = new TypeRegistry({
    Foo.KIND: Foo.entityFactory,
  });

  group('Entity', () {
    test('retains a basic unknown field', () {
      var foo = new Foo.fromJsonString(
          '''
          {
            "baz": "buzz",
            "hello": "world"
          }
          ''', const NoopTrace());
      // Known field
      MethodMirror method(Type t, String symName) =>
          reflectClass(t).declarations[new Symbol(symName)] as MethodMirror;
      expect(method(Foo, 'baz').isGetter, isTrue);
      expect(foo.baz, equals('buzz'));
      // Unknown field
      expect(method(Foo, 'hello'), isNull);
      expect(foo['hello'], equals('world'));
    });
    test('deserializes an unknown field of known type', () {
      var bar = new Bar.fromJsonString(
          '''
          {
            "foo": {
              "kind": "type#foo",
              "baz": "buzz"
            }
          }
          ''', const NoopTrace(), typeRegistry: reg);
      var foo = bar['foo'];
      expect(foo.runtimeType, Foo);
      expect(foo.baz, equals('buzz'));
    });
    test('deserializes an unknown list of elements of known type', () {
      var bar = new Bar.fromJsonString(
          '''
          {
            "foos": [
              {
                "kind": "type#foo",
                "baz": "buzz1"
              },
              {
                "kind": "type#foo",
                "baz": "buzz2"
              }
            ]
          }
          ''', const NoopTrace(), typeRegistry: reg);
      var foos = bar['foos'];
      expect(foos, new isAssignableTo<List>());
      expect(foos.length, equals(2));
      expect(foos[0].baz, equals('buzz1'));
      expect(foos[1].baz, equals('buzz2'));
    });
    test('deserializes an unknown field of unknown type as Entity but '
        'serializes a nested object of known type', () {
      var bar = new Bar.fromJsonString(
          '''
          {
            "unknown": {
              "kind": "type#unknown",
              "car": "tesla",
              "foo": {
                "kind": "type#foo",
                "baz": "buzz"
              }
            }
          }
          ''', const NoopTrace(), typeRegistry: reg);
      var unknown = bar['unknown'];
      expect(unknown.runtimeType, RawEntity);
      expect(unknown['car'], equals('tesla'));
      var foo = unknown['foo'];
      expect(foo.runtimeType, Foo);
      expect(foo.baz, equals('buzz'));
    });
  });
}
