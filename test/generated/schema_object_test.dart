library streamy.generated.schema_object.test;

import 'dart:json';
import 'package:fixnum/fixnum.dart' as fixnum;
import 'package:streamy/streamy.dart' as streamy;
import 'package:unittest/unittest.dart';
import 'package:observe/observe.dart';
import 'schema_object_client.dart';

main() {
  group('SchemaObjectTest', () {
    Foo foo;
    setUp(() {
      foo = new Foo()
      ..id = 1
      ..bar = 'bar'
      ..baz = 2
      ..qux = new fixnum.Int64(1234);
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
        'qux': '1234',
      }));
    });
    test('RemovedKeyNotPresentInJson', () {
      expect(foo.removeBaz(), equals(2));
      expect(foo.toJson(), equals({
        'id': 1,
        'bar': 'bar',
        'qux': '1234',
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
      var foo2 = new Foo.fromJson(new ObservableMap.from({
        'corge': 1.2
      }));
      expect(foo2.corge, equals(1.2));
      expect(foo2.corge, new isInstanceOf<double>());
    });
    test('Deserialize formatted strings and lists', () {
      var foo2 = new Foo.fromJson(new ObservableMap.from({
        'qux': '123456789123456789123456789',
        'quux': ['2.5', '3.5', '4.5', '5.5']
      }));
      expect(foo2.qux, equals(fixnum.Int64.parseInt('123456789123456789123456789')));
      expect(foo2.quux, equals([2.5, 3.5, 4.5, 5.5]));
    });
    test("clone()'d entities are equal", () {
      expect(streamy.Entity.deepEquals(foo.clone(), foo), equals(true));
      var bar = new Bar()
        ..foos = [foo];
      expect(streamy.Entity.deepEquals(bar.clone(), bar), equals(true));
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
      expect(streamy.Entity.deepEquals(bar, bar2), equals(false));
    });
    test('objects are observable', () {
      var foo = new Foo();
      foo.changes.listen(expectAsync1((List<ChangeRecord> changes) {
        expect(changes, hasLength(7));

        var r0 = changes[0] as PropertyChangeRecord;
        expect(r0.field, const Symbol('length'));

        var r1 = changes[1] as MapChangeRecord;
        expect(r1.key, 'id');
        expect(r1.isInsert, isTrue);
        expect(r1.isRemove, isFalse);

        var r2 = changes[2] as MapChangeRecord;
        expect(r2.key, 'id');
        expect(r2.isInsert, isFalse);
        expect(r2.isRemove, isFalse);

        var r3 = changes[3] as PropertyChangeRecord;
        expect(r3.field, const Symbol('length'));

        var r4 = changes[4] as MapChangeRecord;
        expect(r4.key, 'bar');
        expect(r4.isInsert, isTrue);
        expect(r4.isRemove, isFalse);

        var r5 = changes[5] as MapChangeRecord;
        expect(r5.key, 'id');
        expect(r5.isInsert, isFalse);
        expect(r5.isRemove, isTrue);

        var r6 = changes[6] as PropertyChangeRecord;
        expect(r6.field, const Symbol('length'));
      }, count: 1));
      foo.id = 1;
      foo.id = 2;
      foo.bar = 'hello';
      foo.removeId();
    });
    test('objects are not deeply observable', () {
      var foo = new Foo();  // nested object
      var bar = new Bar()  // top-level object
        ..foos = [foo];

      // Expect foo to receive notifications
      foo.changes.listen(expectAsync1((List<ChangeRecord> changes) {
        expect(changes, hasLength(2));

        var r0 = changes[0] as PropertyChangeRecord;
        expect(r0.field, const Symbol('length'));

        var r1 = changes[1] as MapChangeRecord;
        expect(r1.key, 'id');
        expect(r1.isInsert, isTrue);
        expect(r1.isRemove, isFalse);
      }, count: 1));

      // Bar should not receive notifications
      bar.changes.listen(expectAsync1((List<ChangeRecord> changes) {
        fail('Should not receive notifications');
      }, count: 0));

      // Fire changes
      foo.id = 1;
    });
    test('local is observable', () {
      var foo = new Foo();
      foo.local.changes.listen(expectAsync1((List<ChangeRecord> changes) {
        expect(changes, hasLength(5));

        var r0 = changes[0] as PropertyChangeRecord;
        expect(r0.field, const Symbol('length'));

        var r1 = changes[1] as MapChangeRecord;
        expect(r1.key, 'hello');
        expect(r1.isInsert, isTrue);
        expect(r1.isRemove, isFalse);

        var r2 = changes[2] as MapChangeRecord;
        expect(r2.key, 'hello');
        expect(r2.isInsert, isFalse);
        expect(r2.isRemove, isFalse);

        var r3 = changes[3] as MapChangeRecord;
        expect(r3.key, 'hello');
        expect(r3.isInsert, isFalse);
        expect(r3.isRemove, isTrue);

        var r4 = changes[4] as PropertyChangeRecord;
        expect(r4.field, const Symbol('length'));
      }, count: 1));

      // Fire changes
      foo.local['hello'] = 1;
      foo.local['hello'] = 2;
      foo.local.remove('hello');
    });
    test('lists are observable', () {
      var bar = new Bar.fromJsonString('{"foos": [{}]}');
      expect(bar.foos, new isInstanceOf<ObservableList>());
    });
    test('lists become observable via setter', () {
      var bar = new Bar();
      bar.foos = [new Foo()..bar = 'hello'];
      expect(bar.foos, new isInstanceOf<ObservableList>(),
          reason: 'Expected plain list to be converted to observable list');
      expect(bar.foos, hasLength(1),
          reason: 'Expected list to have the same size as the original');
      expect(bar.foos[0].bar, 'hello',
          reason: 'Expected list to contain the same stuff as the original');
    });
    test('observable lists not copied in setter', () {
      var bar = new Bar();
      var list = new ObservableList<Foo>();
      bar.foos = list;
      expect(bar.foos, same(list),
          reason: 'Expected same instance of list');
    });
  });
  group('.global', () {
    var foo;
    var foo2;
    setUp(() {
      foo = new Foo()..id = 1;
      foo2 = new Foo()..id = 2;
    });
    test('Simple global', () {
      Foo.addGlobal('idStr', (foo) => 'Id #${foo.id}');
      expect(foo['global.idStr'], equals('Id #1'));
      expect(foo2['global.idStr'], equals('Id #2'));
      foo.id = 3;
      expect(foo['global.idStr'], equals('Id #3'));
      expect(foo2['global.idStr'], equals('Id #2'));
    });
    test('Memoized global', () {
      Foo.addGlobal('idStr', (foo) => 'Id #${foo.id}', memoize: true);
      expect(foo['global.idStr'], equals('Id #1'));
      expect(foo2['global.idStr'], equals('Id #2'));
      foo.id = 3;
      foo2.id = 4;
      expect(foo['global.idStr'], equals('Id #1'));
      expect(foo2['global.idStr'], equals('Id #2'));
    });
    test('Persists through cloning', () {
      expect(foo.clone()['global.idStr'], equals('Id #1'));
    });
  });
}
