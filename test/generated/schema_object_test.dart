library streamy.generated.schema_object.test;

import 'dart:async';
import 'package:fixnum/fixnum.dart' as fixnum;
import 'package:json/json.dart';
import 'package:streamy/streamy.dart' as streamy;
import 'package:unittest/unittest.dart';
import 'package:observe/observe.dart';
import 'schema_object_client.dart';
import 'schema_object_client_objects.dart';
import '../utils.dart';

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
      bar = new Bar.fromJsonString(stringify(bar.toJson()), const streamy.NoopTrace());
      expect(bar.foos.length, equals(1));
      expect(bar.foos[0].id, equals(321));
    });
    test('DeserializeMissingListToNull', () {
      var bar = new Bar.fromJsonString('{}', const streamy.NoopTrace());
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
        expect(changes, hasLength(4));

        var r1 = changes[0] as MapChangeRecord;
        expect(r1.key, 'id');
        expect(r1.isInsert, isTrue);
        expect(r1.isRemove, isFalse);

        var r2 = changes[1] as MapChangeRecord;
        expect(r2.key, 'id');
        expect(r2.isInsert, isFalse);
        expect(r2.isRemove, isFalse);

        var r4 = changes[2] as MapChangeRecord;
        expect(r4.key, 'bar');
        expect(r4.isInsert, isTrue);
        expect(r4.isRemove, isFalse);

        var r5 = changes[3] as MapChangeRecord;
        expect(r5.key, 'id');
        expect(r5.isInsert, isFalse);
        expect(r5.isRemove, isTrue);
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
        expect(changes, hasLength(1));

        var r1 = changes[0] as MapChangeRecord;
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
        expect(r0.name, const Symbol('length'));

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
        expect(r4.name, const Symbol('length'));
      }, count: 1));

      // Fire changes
      foo.local['hello'] = 1;
      foo.local['hello'] = 2;
      foo.local.remove('hello');
    });
    test('lists are observable', () {
      var bar = new Bar.fromJsonString('{"foos": [{}]}', const streamy.NoopTrace());
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
    test('null assignment to a list works', () {
      var bar = new Bar();
      bar.foos = null;
      expect(bar.foos, isNull, reason: 'Expected null list.');
    });
  });
  group('.global', () {
    var foo;
    var foo2;
    var exDep;
    var exDepCancel;
    setUp(() {
      foo = new Foo()..id = 1;
      foo2 = new Foo()..id = 2;
      idFn(foo) => 'Id #${foo.id}';
      Foo.addGlobal('idStr', idFn);
      exDepCancel = new Completer();
      exDep = new StreamController.broadcast(onCancel: exDepCancel.complete);
      Foo.addGlobal('idStrMemo', idFn, memoize: true);
      Foo.addGlobal('depStr', idFn, dependencies: ['id']);
      // The clause here is used to test that 'foo' is the entity in question.
      Foo.addGlobal('depStr2', idFn, dependencies: [(foo) => exDep.stream.where((v) => v == foo.id)]);
      Foo.addGlobal('depStr3', idFn, dependencies: ['id', (foo) => exDep.stream.where((v) => v == foo.id)]);
    });
    test('Simple global', () {
      expect(foo.global['idStr'], equals('Id #1'));
      expect(foo2.global['idStr'], equals('Id #2'));
      foo.id = 3;
      expect(foo.global['idStr'], equals('Id #3'));
      expect(foo2.global['idStr'], equals('Id #2'));
    });
    test('Memoized global', () {
      expect(foo.global['idStrMemo'], equals('Id #1'));
      expect(foo2.global['idStrMemo'], equals('Id #2'));
      foo.id = 3;
      foo2.id = 4;
      expect(foo.global['idStrMemo'], equals('Id #1'));
      expect(foo2.global['idStrMemo'], equals('Id #2'));
    });
    test('Persists through cloning', () {
      expect(foo.clone().global['idStr'], equals('Id #1'));
    });
    test('Works via dot-property access', () {
      expect(foo['global.idStr'], equals('Id #1'));
    });
    test('Observation with no dependencies', () {
      foo.global.changes.listen(expectAsync1((_) {}, count: 0));
    });
    test('Observation with a property dependency', () {
      foo.global.changes.listen(expectAsync1((changes) {
        expect(changes.map((c) => c.key), contains('depStr'));
        expect(foo.global['depStr'], 'Id #3');
      }, count: 1));
      foo.id = 3;
    });
    test('Observation with an external dependency', () {
      var sub;
      sub = foo.global.changes.listen(expectAsync1((changes) {
        expect(changes.map((c) => c.key), contains('depStr2'));
        sub.cancel();
      }, count: 1));
      exDepCancel.future.whenComplete(expectAsync0(() {}, count: 1));
      exDep.add(foo.id);
    });
    test('Observation with both internal and external dependencies', () {
      var sub;
      sub = foo.global.changes.listen(expectAsync1((changes) {
        expect(changes.map((c) => c.key), contains('depStr3'));
        expect(foo.global['depStr3'], 'Id #1');
        var sub2;
        sub2 = foo.global.changes.listen(expectAsync1((changes) {
          expect(changes.map((c) => c.key), contains('depStr3'));
          expect(foo.global['depStr3'], 'Id #3');
          sub2.cancel();
        }, count: 1));
        sub.cancel();
        foo.id = 3;
      }, count: 1));
      exDepCancel.future.whenComplete(expectAsync0(() {
        expect(foo.id, 3);
      }, count: 1));
      exDep.add(foo.id);
    });
  });
  group('patch()', () {
    test('works like clone() for a new basic entity', () {
      var e = new Foo()
        ..id = 1;
      var p = e.patch();
      expect(p.id, 1);
      expect(p, new isInstanceOf<Foo>());
      p.id = 2;
      expect(e.id, 1);
    });
    test('only copies changed fields for a basic entity', () {
      var e = new Foo()
        ..id = 1
        ..bar = 'this changes'
        ..quux = [1.1, 1.2];
      streamy.freezeForTest(e);
      var c = e.clone();
      c.bar = 'this has changed';
      var p = c.patch();
      expect(p.bar, 'this has changed');
      expect(p.id, isNull);
      expect(p.quux, isNull);
      c.quux.add(1.3);
      expect(p.quux, isNull);
      expect(c.patch().quux, [1.1, 1.2, 1.3]);
    });
    test('handles nested entities', () {
      var foo1 = new Foo()
        ..id = 1
        ..bar = 'this changes';
      var foo2 = new Foo()
        ..id = 2
        ..bar = 'this will be deleted';
      var foo3 = new Foo()
        ..id = 3
        ..bar = 'this does not change';
      var bar = new Bar()
        ..primary = foo1
        ..foos = [foo2, foo3];
      streamy.freezeForTest(bar);
      var barC = bar.clone();
      barC.primary.bar = 'changed!';
      barC.foos[0].remove('bar');
      var barP = barC.patch();
      expect(stringify(barP),
          '{"foos":[{"id":2},{"bar":"this does not change","id":3}],"primary":{"bar":"changed!"}}');
    });
  });
  group('Bad characters', () {
    test('should not appear in entity classes', () {
      new $some_entity_();
    });
    test('should not appear in GlobalFn classes', () {
      $some_entity_.addGlobal('test',
          ($some_entity_ e) => null);
    });
    test('should not appear in entity properties', () {
      new $some_entity_()
        ..$badly_named_property____$_______ = new fixnum.Int64(123);
    });
    test('should not appear in resources and methods names', () {
      new SchemaObjectTest(null)
        .$some_resource_.$some_method_(null, null);
    });
  });
  group('Array of arrays', () {
    test('should deserilize correctly', () {
      var subject = new Context.fromJsonString(
'''
{
  "facets": [
    [{"anchor": "a"}, {"anchor": "b"}],
    [],
    null,
    [null]
  ]
}
''', null);
      expect(subject.facets, hasLength(4));
      expect(subject.facets[0], hasLength(2));
      subject.facets[0].forEach((f) {
        expect(f, new isAssignableTo<Context_Facets>());
      });
      expect(subject.facets[0][0].anchor, 'a');
      expect(subject.facets[1], hasLength(0));
      expect(subject.facets[2], isNull);
      expect(subject.facets[3], hasLength(1));
      expect(subject.facets[3][0], isNull);
    });
    test('should serialize correctly', () {
      var subject = new Context()
        ..facets = [
          [
            new Context_Facets()..anchor = 'a',
            new Context_Facets()..anchor = 'b',
          ],
          [],
          null,
          [null],
        ];
      expect(stringify(subject.toJson()),
          '{"facets":[[{"anchor":"a"},{"anchor":"b"}],[],null,[null]]}');
    });
  });
}
