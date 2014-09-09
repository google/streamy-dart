library streamy.mixins.immutable.test;

import 'package:streamy/raw_entity.dart';
import 'package:observe/observe.dart';
import 'package:fixnum/fixnum.dart';
import 'package:unittest/unittest.dart';

main() {
  group('Immutable mixin', () {
    test('should be unfrozen by default', () {
      var entity = raw({
        'foo': 1,
        'bar': 'baz',
        'qux': false,
        'quux': null,
        'garply': new Int64(123),
        'waldo': 3.14,
      });
      expect(entity.isFrozen, isFalse);
      entity['foo'] = 2;
      expect(entity['foo'], 2);
    });
    test('should throw on mutations when frozen', () {
      var entity = raw({'foo': 1});

      entity.freeze();

      expect(entity.isFrozen, isTrue);
      expect(() {
        entity['foo'] = 2;
      }, throwsUnsupportedError);
      expect(entity['foo'], 1);
    });
    test('should freeze nested entities', () {
      var foo = raw({'bar': 1});
      var entity = raw({'foo': foo});

      entity.freeze();

      expect(entity.isFrozen, isTrue);
      expect(foo.isFrozen, isTrue);
      expect(() {
        foo['bar'] = 2;
      }, throwsUnsupportedError);
    });
    test('should freeze nested lists of entities', () {
      var foo = raw({'bar': 1});
      var entity = raw({'foos': olist([foo])});
      entity.freeze();

      expect(() {
        entity['foos'][0] = raw({'baz': 3});
      }, throwsUnsupportedError, reason: 'the list must be frozen');

      expect(() {
        foo['bar'] = 2;
      }, throwsUnsupportedError, reason: 'entities in the list must be frozen');
    });
    test('should freeze lists of lists', () {
      var entity = raw({'list': olist([olist([olist([1])])])});
      entity.freeze();

      expect(() {
        entity['list'][0] = [];
      }, throwsUnsupportedError, reason: 'the list must be frozen');
      expect(() {
        entity['list'][0][0] = [];
      }, throwsUnsupportedError, reason: 'the list must be frozen');
      expect(() {
        entity['list'][0][0][0] = [];
      }, throwsUnsupportedError, reason: 'the list must be frozen');
    });
  });
}

RawEntity raw(Map map) => new RawEntity.wrap(map);
ObservableList olist(List list) => new ObservableList.from(list);
