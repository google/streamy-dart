import 'dart:async';
import 'package:streamy/streamy.dart';
import 'package:unittest/unittest.dart';

main() {
  group('RawEntity', () {
    test('does not allow setting closures on non-.local keys', () {
      var e = new RawEntity();
      expect(() => e['foo'] = () => false, throwsA(new isInstanceOf<ClosureInEntityException>()));
    });
    test('does allow setting closures on .local', () {
      var e = new RawEntity();
      e['local.foo'] = () => true;
    });
  });
  group('DynamicEntity', () {
    test('factory constructor returns a DynamicEntity', () {
      expect(new Entity(), new isInstanceOf<DynamicEntity>());
    });
    test('factory constructor fromMap returns a DynamicEntity', () {
      expect(new Entity.fromMap({'foo': 'bar'}), new isInstanceOf<DynamicEntity>());
    });
    test('noSuchMethod getters/setters work', () {
      var e = new Entity();
      e.foo = 'bar';
      expect(e.foo, equals('bar'));
    });
    test('Exception on non-accessor invocation.', () {
      var e = new Entity();
      e.foo = 'a';
      expect(() => e.foo(), throwsA(new isInstanceOf<ClosureInvocationException>()));
    });
  });
  group('.local', () {
    var entity;
    setUp(() {
      entity = new RawEntity();
    });
    test('exists and looks like a Map', () {
      expect(entity.local, isNotNull);
      expect(entity.local, new isInstanceOf<Map>());
    });
    test('stores and retrieves data via operator[]', () {
      entity.local['foo'] = 'bar';
      expect(entity.local['foo'], equals('bar'));
    });
    test('has dot property access', () {
      entity.local['foo'] = 'bar';
      expect(entity.local.foo, equals('bar'));
      entity.local.foo = 'baz';
      expect(entity.local['foo'], equals('baz'));
    });
    test('converts Maps to LocalDataMaps', () {
      entity.local.foo = {'bar': true};
      expect(entity.local.foo, new isInstanceOf<LocalDataMap>());
    });
    test('does not affect serialization of the entity', () {
      var s1 = entity.toJson();
      entity.local.foo = 'not serialized';
      var s2 = entity.toJson();
      expect(s2, equals(s1));
    });
    test('has equality semantics', () {
      var entity2 = new RawEntity();
      entity.local.foo = 'bar';
      entity2.local.foo = 'bar';
      expect(entity.local == entity2.local, isTrue);
      entity2.local.foo = 'baz';
      expect(entity.local == entity2.local, isFalse);
    });
    test('does not survive cloning', () {
      entity.local.foo = 'this should not be cloned';
      expect(entity.clone().local.foo, isNull);
    });
    test('cannot be set', () {
      expect(() => entity.local = {},
          throwsA(new isInstanceOf<NoSuchMethodError>()));
      expect(() => entity['local'] = {},
          throwsA(new isInstanceOf<ArgumentError>()));
    });
  });

  group('EntityDedupTransformer', () {
    test('properly dedups', () {
      var a = new RawEntity()
        ..['id'] = 'foo';
      var b = new RawEntity()
        ..['id'] = 'foo';
      var eStream = new Stream.fromIterable([a, b]);
      eStream
        .transform(new EntityDedupTransformer())
        .single
        .then(expectAsync1((e) {
          expect(e, equals(a));
          expect(e, equals(b));
        }));
    });
  });
  group('OneShotRequestTransformer', () {
    var a = new RawEntity()
      ..['id'] = 'foo'
      ..['seq'] = 1
      ..streamy.source = 'CACHE';
    var b = new RawEntity()
      ..['id'] = 'foo'
      ..['seq'] = 2
      ..streamy.source = 'RPC';
    var c = new RawEntity()
      ..['id'] = 'foo'
      ..['seq'] = 3
      ..streamy.source = 'UPDATE';
    var rpcOnly;
    var cacheAndRpc;
    setUp(() {
      rpcOnly = new Stream.fromIterable([b, c]);
      cacheAndRpc = new Stream.fromIterable([a, b, c]);
    });
    test('handles one RPC response correctly', () {
      var onlyResponse = rpcOnly
        .transform(new OneShotRequestTransformer())
        .single;
      asyncExpect(onlyResponse.then((e) => e.streamy.source), equals('RPC'));
    });
    test('handles multiple responses correctly', () {
      var stream = cacheAndRpc
        .transform(new OneShotRequestTransformer())
        .asBroadcastStream();
      asyncExpect(stream.first.then((e) => e.streamy.source), equals('CACHE'));
      asyncExpect(stream.last.then((e) => e.streamy.source), equals('RPC'));
      asyncExpect(stream.length, equals(2));
    });
  });
  group("fixnum", () {
    test("int64 operator==", () {
      expect(new int64.fromInt(123) == int64.parseInt("123"), equals(true));
      expect(new int64.fromInt(3) == new Object(), equals(false));
    });
  });
}

asyncExpect(Future future, matcher) => future.then(expectAsync1((v) {
  expect(v, matcher);
}));
