library streamy.generated.schema_object.test;

import 'dart:async';
import 'dart:convert';
import 'package:fixnum/fixnum.dart' as fixnum;
import 'package:streamy/streamy.dart' as streamy;
import 'package:unittest/unittest.dart';
import 'package:observe/observe.dart';
import 'schema_object_client.dart';
import 'schema_object_client_objects.dart';
import 'schema_object_client_dispatch.dart';
import '../utils.dart';

main() {
  var marshaller = new Marshaller();
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
      expect(streamy.jsonMarshal(foo), equals({
        'id': 1,
        'bar': 'bar',
        'baz': 2,
        'qux': '1234',
      }));
    });
    test('RemovedKeyNotPresentInJson', () {
      expect(foo.removeBaz(), equals(2));
      expect(streamy.jsonMarshal(foo), equals({
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
      bar = marshaller.unmarshalBar(
          streamy.jsonParse(JSON.encode(streamy.jsonMarshal(bar))));
      expect(bar.foos.length, equals(1));
      expect(bar.foos[0].id, equals(321));
    });
    test('DeserializeMissingListToNull', () {
      var bar = marshaller.unmarshalBar({});
      expect(bar.foos, isNull);
    });
    test('List of doubles works properly', () {
      foo.quux = [1.5, 2.5, 3.5, 4.5];
      expect(foo.quux, equals([1.5, 2.5, 3.5, 4.5]));
      expect(foo['quux'], equals([1.5, 2.5, 3.5, 4.5]));
      expect(streamy.jsonMarshal(foo)['quux'],
          equals([1.5, 2.5, 3.5, 4.5]));
    });
    test('type=number format=double works correctly', () {
      var foo2 = marshaller.unmarshalFoo(new ObservableMap.from({
        'corge': 1.2
      }));
      expect(foo2.corge, equals(1.2));
      expect(foo2.corge, new isInstanceOf<double>());
    });
    test('Deserialize formatted strings and lists', () {
      var foo2 = marshaller.unmarshalFoo(new ObservableMap.from({
        'qux': '123456789123456789123456789',
        'quux': ['2.5', '3.5', '4.5', '5.5']
      }));
      expect(foo2.qux, equals(fixnum.Int64.parseInt('123456789123456789123456789')));
      expect(foo2.quux, equals([2.5, 3.5, 4.5, 5.5]));
    });
    test("clone()'d entities are equal", () {
      expect(streamy.EntityUtils.deepEquals(foo.clone(), foo), equals(true));
      var bar = new Bar()
        ..foos = [foo];
      expect(streamy.EntityUtils.deepEquals(bar.clone(), bar), equals(true));
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
      expect(streamy.EntityUtils.deepEquals(bar, bar2), equals(false));
    });
    test('objects are observable', () {
      var foo = new Foo();
      foo.changes.listen(expectAsync((List<ChangeRecord> changes) {
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
      foo.changes.listen(expectAsync((List<ChangeRecord> changes) {
        expect(changes, hasLength(1));

        var r1 = changes[0] as MapChangeRecord;
        expect(r1.key, 'id');
        expect(r1.isInsert, isTrue);
        expect(r1.isRemove, isFalse);
      }, count: 1));

      // Bar should not receive notifications
      bar.changes.listen(expectAsync((List<ChangeRecord> changes) {
        fail('Should not receive notifications');
      }, count: 0));

      // Fire changes
      foo.id = 1;
    });
    test('local is observable', () {
      var foo = new Foo();
      expect(foo.local, new isInstanceOf<ObservableMap>());
    });
    test('lists are observable', () {
      var bar = marshaller.unmarshalBar(streamy.jsonParse('{"foos": [{}]}'));
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
    test('lists are detached from observable list created by setter', () {
      var bar = new Bar();
      var list = [1, 2];
      bar.foos = list;
      list.add(3);
      expect(bar.foos, [1, 2],
        reason: 'setter does not wrap the list but makes a copy');
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
      foo.global.changes.listen(expectAsync((_) {}, count: 0));
    });
    test('Observation with a property dependency', () {
      foo.global.changes.listen(expectAsync((changes) {
        expect(changes.map((c) => c.key), contains('depStr'));
        expect(foo.global['depStr'], 'Id #3');
      }, count: 1));
      foo.id = 3;
    });
    test('Observation with an external dependency', () {
      var sub;
      sub = foo.global.changes.listen(expectAsync((changes) {
        expect(changes.map((c) => c.key), contains('depStr2'));
        sub.cancel();
      }, count: 1));
      exDepCancel.future.whenComplete(expectAsync(() {}, count: 1));
      exDep.add(foo.id);
    });
    test('Observation with both internal and external dependencies', () {
      var sub;
      sub = foo.global.changes.listen(expectAsync((changes) {
        expect(changes.map((c) => c.key), contains('depStr3'));
        expect(foo.global['depStr3'], 'Id #1');
        var sub2;
        sub2 = foo.global.changes.listen(expectAsync((changes) {
          expect(changes.map((c) => c.key), contains('depStr3'));
          expect(foo.global['depStr3'], 'Id #3');
          sub2.cancel();
        }, count: 1));
        sub.cancel();
        foo.id = 3;
      }, count: 1));
      exDepCancel.future.whenComplete(expectAsync(() {
        expect(foo.id, 3);
      }, count: 1));
      exDep.add(foo.id);
    });
    test('should work with sub-classes', () {
      Foo.addGlobal('testGlobal', (e) {
        expect(e.runtimeType, FooSubclass);
        return 'magic';
      });
      var subject = new FooSubclass();
      expect(subject['global.testGlobal'], 'magic');
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
      e.freeze();
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
      var foo = new Foo()
        ..id = 1
        ..bar = 'this changes';
      var bar = new Bar()
        ..primary = foo;
      bar.freeze();

      var barC = bar.clone();
      barC.primary.bar = 'changed!';

      var barP = barC.patch();
      expect(JSON.encode(streamy.jsonMarshal(barP)),
        '''
        {
          "primary": {
            "bar": "changed!"
          }
        }'''.replaceAll(new RegExp(r'\s'), ''));
    });
    test('handles lists of entities', () {
      var foo1 = new Foo()
        ..id = 2
        ..bar = 'this will be deleted';
      var foo2 = new Foo()
        ..id = 3
        ..bar = 'thisDoesNotChange';
      var bar = new Bar()
        ..foos = [foo1, foo2];
      bar.freeze();

      var barC = bar.clone();
      barC.foos[0].remove('bar');

      var barP = barC.patch();
      expect(JSON.encode(streamy.jsonMarshal(barP)), '''
        {
          "foos": [
            {
              "id": 2
            },
            {
              "id": 3,
              "bar": "thisDoesNotChange"
            }
          ]
        }'''.replaceAll(new RegExp(r'\s'), ''));
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
        .$some_resource_.$some_method_();
    });
  });
  group('Array of arrays', () {
    test('should deserilize correctly', () {
      var subject = marshaller.unmarshalContext(streamy.jsonParse(
'''
{
  "facets": [
    [{"anchor": "a"}, {"anchor": "b"}],
    [],
    null,
    [null]
  ]
}
'''));
      expect(subject.facets, hasLength(4));
      expect(subject.facets[0], hasLength(2));
      subject.facets[0].forEach((f) {
        expect(f, new isAssignableTo<ContextFacets>());
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
            new ContextFacets()..anchor = 'a',
            new ContextFacets()..anchor = 'b',
          ],
          [],
          null,
          [null],
        ];
      expect(JSON.encode(streamy.jsonMarshal(subject)),
          '{"facets":[[{"anchor":"a"},{"anchor":"b"}],[],null,[null]]}');
    });
  });
  group('Lazy deserialization', () {
    test('deserializes array elements into lazy form', () {
      // Construct Bar object with nested Foos and a Marshaller.
      var f1 = new Foo()..id = 1;
      var f2 = new Foo()..id = 2;
      var bar = new Bar()..foos = [f1, f2];
      var m = new Marshaller();
      
      
      // Now serialize Bar. This is the map that will be deserialized and will
      // contain lazy value references.
      var map = streamy.jsonMarshal(bar);
      
      // Deserialize the above map lazily.
      m.unmarshalBar(map, lazy: true);
      
      // Expect that the list will be lazy.
      expect(map['foos'], new isInstanceOf<streamy.LazyList>());
      
      // Expect that the items in the list are lazy.
      expect(map['foos'].delegate[0], new isInstanceOf<streamy.Lazy>());
      expect(map['foos'].delegate[1], new isInstanceOf<streamy.Lazy>());
    });
    test('lazily constructs objects', () {
      // Construct Bar object with nested Foos and a Marshaller.
      var f1 = new Foo()..id = 1;
      var f2 = new Foo()..id = 2;
      var bar = new Bar()..foos = [f1, f2];
      var m = new Marshaller();
      var b = m.unmarshalBar(streamy.jsonMarshal(bar), lazy: true);
      
      expect(b.foos[0], new isInstanceOf<Foo>());
      expect(b.foos[1].id, 2);
    });
  });
}

class FooSubclass extends Foo {

}
