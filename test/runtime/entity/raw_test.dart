library runtime_entity_raw_test;

import 'dart:convert';
import 'package:streamy/streamy.dart';
import 'package:unittest/unittest.dart';
import 'package:observe/observe.dart';

main() {
  /// Because [RawEntity] implements [Map] passing it directly to
  /// `dart:convert` produces different results compared to passing
  /// the result of calling [RawEntity.toJson].
  void expectSerialized(RawEntity e, {String toJson, String direct}) {
    expect(JSON.encode(e.toJson()), toJson);
    //                 ^^^^^^^^^^
    expect(JSON.encode(e), direct);
    //                 ^
  }

  group('RawEntity', () {
    test('should sort JSON keys', () {
      var e = new RawEntity.wrapMap(
          new ObservableMap.linked()
            ..['b'] = 1
            ..['a'] = 2);
      expectSerialized(e,
          toJson: '{"a":2,"b":1}',
          direct: '{"b":1,"a":2}');
    });
    test('should serialize nulls as JSON nulls', () {
      var e = new RawEntity();
      e['foo'] = null;
      expectSerialized(e,
          toJson: '{"foo":null}',
          direct: '{"foo":null}');
    });
  });
}
