library streamy.generated.schema_unknown_fields.test;

import 'dart:json';
import 'dart:mirrors';
import 'package:streamy/streamy.dart';
import 'package:unittest/unittest.dart';
import 'schema_unknown_fields_client.dart';

main() {
  group('Entity', () {
    test('retains a basic unknown field', () {
      var foo = new Foo.fromJsonString(
          '''
          {
            "baz": "buzz",
            "hello": "world"
          }
          ''');
      // Known field
      expect(reflectClass(Foo).getters.containsKey(new Symbol('baz')), isTrue);
      expect(foo.baz, equals('buzz'));
      // Unknown field
      expect(reflectClass(Foo).members.containsKey(new Symbol('hello')),
          isFalse);
      expect(foo['hello'], equals('world'));
    });
    test('deserializes an unknown field of known type', () {
      var reg = new TypeRegistry({
        "type#foo": Foo.entityFactory,
      });
      var bar = new Bar.fromJsonString(
          '''
          {
            "foo": {
              "kind": "type#foo",
              "baz": "buzz"
            }
          }
          ''', typeRegistry: reg);
      var foo = bar['foo'];
      expect(foo, new isInstanceOf<Foo>());
      expect(foo.baz, equals('buzz'));
    });
    test('deserializes an unknown list of elements of known type', () {
      var reg = new TypeRegistry({
        "type#foo": Foo.entityFactory,
      });
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
          ''', typeRegistry: reg);
      var foos = bar['foos'];
      expect(foos, new isInstanceOf<List>());
      expect(foos.length, equals(2));
      expect(foos[0].baz, equals('buzz1'));
      expect(foos[1].baz, equals('buzz2'));
    });
    test('deserializes an unknown field of unknown type as Entity but '
        'serializes a nested object of known type', () {
      var reg = new TypeRegistry({
        "type#foo": Foo.entityFactory,
      });
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
          ''', typeRegistry: reg);
      var unknown = bar['unknown'];
      expect(unknown, new isInstanceOf<Entity>());
      expect(unknown['car'], equals('tesla'));
      var foo = unknown['foo'];
      expect(foo, new isInstanceOf<Foo>());
      expect(foo.baz, equals('buzz'));
    });
  });
}
