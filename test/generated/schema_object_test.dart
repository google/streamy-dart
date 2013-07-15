library schema_object_test;

import 'dart:json';
import 'package:streamy/collections.dart';
import 'package:streamy/streamy.dart' as streamy;
import 'package:unittest/unittest.dart';
import 'schema_object_client.dart';

main() {
  group('SchemaObjectTest', () {
    Foo foo;
    setUp(() {
      foo = new Foo()
      ..id = 1
      ..bar = 'bar'
      ..baz = 2;
    });
    test('DataCorrectlyPopulated', () {
      expect(foo.id, equals(1));
      expect(foo.bar, equals('bar'));
      expect(foo.baz, equals(2));
    });
    test('DataMapCorrectlyPopulated', () {
      expect(foo['id'], equals(1));
      expect(foo['bar'], equals('bar'));
      expect(foo['baz'], equals(2));
    });
    test('JsonCorrectlyPopulated', () {
      expect(foo.toJson(), equals({
        'id': 1,
        'bar': 'bar',
        'baz': 2,
      }));
    });
    test('RemovedKeyNotPresentInJson', () {
      expect(foo.removeBaz(), equals(2));
      expect(foo.toJson(), equals({
        'id': 1,
        'bar': 'bar',
      }));
    });
    test('RemovedKeyGetsNull', () {
      foo.removeBaz();
      expect(foo.baz, isNull);
    });
    test('SerializeListToJson', () {
      var bar = new Bar()..foos = [new Foo()..id = 321];
      bar = new Bar.fromJsonString(stringify(bar.toJson()));
      expect(bar.foos.length, equals(1));
      expect(bar.foos[0].id, equals(321));
    });
    test('DeserializeMissingListToNull', () {
      var bar = new Bar.fromJsonString('{}');
      expect(bar.foos, isNull);
    });
    test('List of doubles works properly', () {
      foo.quux = [1.5, 2.5, 3.5, 4.5];
      expect(foo.quux, equals([1.5, 2.5, 3.5, 4.5]));
      expect(foo['quux'], equals([1.5, 2.5, 3.5, 4.5]));
      expect(foo.toJson()['quux'], equals(['1.5', '2.5', '3.5', '4.5']));
    });
    test('type=number format=double works correctly', () {
      var foo2 = new Foo.fromJson({
        'corge': 1.2
      });
      expect(foo2.corge, equals(1.2));
      expect(foo2.corge, new isInstanceOf<double>());
    });
    test('Deserialize formatted strings and lists', () {
      var foo2 = new Foo.fromJson({
        'qux': '123456789123456789123456789',
        'quux': ['2.5', '3.5', '4.5', '5.5']
      });
      expect(foo2.qux, equals(streamy.int64.parseInt('123456789123456789123456789')));
      expect(foo2.quux, equals([2.5, 3.5, 4.5, 5.5]));
    });
    test('Lists get turned into ComparableLists', () {
      var bar = new Bar()
        ..foos = [foo];
      expect(bar.foos, new isInstanceOf<ComparableList>());
      bar['direct'] = [foo];
      expect(bar['direct'], new isInstanceOf<ComparableList>());
    });
    test("clone()'d entities are equal", () {
      expect(foo.clone(), equals(foo));
      var bar = new Bar()
        ..foos = [foo];
      expect(bar.clone(), equals(bar));
    });
    test('clone() is deep', () {
      var bar = new Bar()
        ..foos = [foo];
      var bar2 = bar.clone();

      // bar2 should be a Bar too.
      expect(bar2, new isInstanceOf<Bar>());
      // They shouldn't be identical.
      expect(bar2, isNot(same(bar)));
      // And the Foos inside them should not be identical (deep clone).
      expect(bar2.foos[0], isNot(same(bar.foos[0])));

      // This tests that the [EntityWrapper] subclasses aren't identical, but
      // not the [RawEntity] entities inside them.
      bar.foos[0].baz = 42;
      expect(bar, isNot(equals(bar2)));
    });
  });
}
