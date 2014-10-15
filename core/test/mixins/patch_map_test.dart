library streamy.mixins.patch.test;

import 'dart:convert' show JSON;
import 'package:streamy/raw_entity.dart';
import 'package:streamy/base.dart';
import 'package:streamy/streamy.dart';
import 'package:unittest/unittest.dart';
import '../utils.dart' show RawEntity;

main() {
  group('Patch', () {

    test('contains only updated properties', () {
      // Create original
      var entity = raw({
        'foo': 0,
        'bar': 2,
      });

      // Make updates
      entity['foo'] = 1;  // change
      entity['baz'] = 3;  // new property

      // Patch and verify
      var patch = entity.patch();
      expect(patch.keys, hasLength(2));
      expect(patch.keys, contains('foo'));
      expect(patch.keys, contains('baz'));
    });

    test('patches EXISTING nested entity', () {
      // Create original
      var entity = raw({
        'foo': raw({
          'bar': 1,
          'baz': 2,
        }),
      });

      // Make updates
      entity['foo']['bar'] = 2;

      // Patch and verify
      var patch = entity.patch();
      var expected = raw({
        'foo': raw({
          'bar': 2,
          // 'baz' should disappear due to patch
        }),
      });
      expect(EntityUtils.deepEquals(patch, expected), isTrue,
      reason: '${getMap(patch)} should be equal to ${getMap(expected)}');
    });

    test('should NOT patch NEW nested entity', () {
      // Create original
      var entity = raw({});

      // Make updates
      entity['foo'] = raw({
        'bar': 1,
      });

      // Patch and verify
      var patch = entity.patch();
      var expected = raw({
        'foo': raw({
          // 'bar' should remain because we're not patching
          'bar': 1,
        }),
      });
      expect(EntityUtils.deepEquals(patch, expected), isTrue,
      reason: '${getMap(patch)} should be '
      'equal to ${getMap(expected)}');
    });
  });
}

RawEntity raw(Map map) => (new RawEntity.wrap(map)..freeze()).clone();
