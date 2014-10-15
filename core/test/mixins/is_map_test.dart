library streamy.mixins.is_map.test;

import 'package:streamy/raw_entity.dart';
import 'package:unittest/unittest.dart';

main() {
  group('IsMap', () {
    test('should implement DynamicAccess', () {
      var entity = raw({
        'a': 1,
        'b': 'c',
      });
      expect(entity.keys, ['a', 'b']);
      expect(entity.containsKey('a'), isTrue);
      expect(entity.containsKey('z'), isFalse);
      expect(entity['a'], 1);
      expect(entity['b'], 'c');
      entity.remove('a');
      expect(entity.containsKey('a'), isFalse);
    });

    test('.containsValue should work', () {
      var entity = raw({'a': 1});
      expect(entity.containsValue(1), isTrue);
      expect(entity.containsValue(2), isFalse);
    });

    test('.putIfAbsent should NOT put if present', () {
      var entity = raw({'a': 1});
      entity.putIfAbsent('a', () {
        fail('Should not have been called');
      });
      expect(entity['a'], 1);
    });

    test('.putIfAbsent should return original value if present', () {
      var entity = raw({'a': 1});
      expect(entity.putIfAbsent('a', () {
        fail('Should not have been called');
      }), 1);
    });

    test('.putIfAbsent should return new value if NOT present', () {
      var entity = raw({});
      expect(entity.putIfAbsent('a', () => 1), 1);
    });

    test('.putIfAbsent should put if absent', () {
      var entity = raw({});
      entity.putIfAbsent('a', () => 1);
      expect(entity['a'], 1);
    });

    test('.addAll should add all', () {
      var entity = raw({'a': 1, 'b': 2});
      entity.addAll({'b': 3, 'c': 4});
      expect(entity, hasLength(3));
      expect(entity['a'], 1);
      expect(entity['b'], 3);
      expect(entity['c'], 4);
    });

    test('.clear should clear', () {
      var entity = raw({'a': 1, 'b': 2})
        ..clear();
      expect(entity, hasLength(0));
    });

    test('.forEach should call back for each pair', () {
      var pairs = {};
      raw({'a': 1, 'b': 2}).forEach((k, v) {
        pairs[k] = v;
      });
      expect(pairs, {'a': 1, 'b': 2});
    });

    test('.values should return values', () {
      expect(raw({'a': 1, 'b': 2}).values, [1, 2]);
    });

    test('.length should return length', () {
      expect(raw({'a': 1, 'b': 2}).length, 2);
    });

    test('.isEmpty should work', () {
      expect(raw({}).isEmpty, isTrue);
      expect(raw({'a': 1}).isEmpty, isFalse);
    });

    test('.isNotEmpty should work', () {
      expect(raw({}).isNotEmpty, isFalse);
      expect(raw({'a': 1}).isNotEmpty, isTrue);
    });
  });
}

RawEntity raw(Map map) => (new RawEntity.wrap(map)..freeze()).clone();
