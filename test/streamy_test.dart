import 'dart:async';
import 'package:streamy/streamy.dart';
import 'package:streamy/testing/testing.dart';
import 'package:unittest/unittest.dart';

main() {
  group('RawEntity', () {
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
  });
  group('DynamicEntity', () {
    test('noSuchMethod getters/setters work', () {
      var e = new DynamicEntity();
      e.foo = 'bar';
      expect(e.foo, equals('bar'));
    });
    test('Exception on non-accessor invocation.', () {
      var e = new DynamicEntity();
      e.foo = 'a';
      expect(() => e.foo(), throwsA(new isInstanceOf<ClosureInvocationException>()));
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
  group('jsonParse', () {
    test('creates Observable types', () {
      var res = jsonParse('{"a":[{"b":3},{"c":4}]}');
      expect(res, new isInstanceOf<ObservableMap>());
      expect(res['a'], new isInstanceOf<ObservableList>());
      expect(res['a'][0], new isInstanceOf<ObservableMap>());
      expect(res['a'][1], new isInstanceOf<ObservableMap>());
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
          expect(Entity.deepEquals(e, a), equals(true));
          expect(Entity.deepEquals(e, b), equals(true));
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
}

asyncExpect(Future future, matcher) => future.then(expectAsync1((v) {
  expect(v, matcher);
}));
