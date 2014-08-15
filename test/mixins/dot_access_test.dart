library streamy.mixins.dot_access.test;

import 'package:streamy/raw_entity.dart';
import 'package:unittest/unittest.dart';

main() {
  group('DotAccess', () {
    test('map can contain keys with dots', () {
      var e = raw({'foo': raw({
        'bar': 'baz',
      })});
      expect(e.containsKey('foo.bar'), isTrue);
      expect(e['foo.bar'], equals('baz'));
    });
    test('removes lowest-most element in the path', () {
      var e = raw({'foo': raw({
          'bar': 'baz',
          'cruft': 1,
      })});
      expect(e['foo'].keys, hasLength(2));
      e.remove('foo.bar');
      expect(e['foo'].keys, hasLength(1));
      expect(e['foo.cruft'], 1);
    });
  });
}

RawEntity raw(Map map) => (new RawEntity.wrap(map)..freeze()).clone();
