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
    test('factory constructor returns a RawEntity', () {
      expect(new Entity(), new isInstanceOf<RawEntity>());
    });
    test('factory constructor fromMap returns a RawEntity', () {
      expect(new Entity.fromMap({'foo': 'bar'}), new isInstanceOf<RawEntity>());
    });
    test('does not allow setting closures on non-.local keys', () {
      var e = new RawEntity();
      expect(() => e['foo'] = () => false, throwsA(new isInstanceOf<ClosureInEntityException>()));
    });
    test('does allow setting closures on .local', () {
      var e = new RawEntity();
      e['local.foo'] = () => true;
    });
    test('.wrapMap constructor does not copy data', () {
      var map = toObservable({'list': [1, 2, 3]});
      var e = new RawEntity.wrapMap(map);
      map['list'].add(4);
      expect(e['list'].length, equals(4));
      expect(e['list'][3], equals(4));
    });
  });

  group('.local', () {
    var entity;
    setUp(() {
      entity = new RawEntity();
    });
    test('exists and is a Map', () {
      expect(entity.local, isNotNull);
      expect(entity.local, new isInstanceOf<Map>());
    });
    test('stores and retrieves data via operator[]', () {
      entity.local['foo'] = 'bar';
      expect(entity.local['foo'], equals('bar'));
    });
    test('does not affect serialization of the entity', () {
      var s1 = entity.toJson();
      entity.local['foo'] = 'not serialized';
      var s2 = entity.toJson();
      expect(s2, equals(s1));
    });
    test('does not survive cloning', () {
      entity.local['foo'] = 'this should not be cloned';
      expect(entity.clone().local['foo'], isNull);
    });
    test('cannot be set', () {
      expect(() => entity.local = {},
          throwsA(new isInstanceOf<NoSuchMethodError>()));
      expect(() => entity['local'] = {},
          throwsA(new isInstanceOf<ArgumentError>()));
    });
  });
}
