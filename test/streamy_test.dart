library streamy.streamy.test;

import 'dart:async';
import 'package:observe/observe.dart';
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
    test('.wrapMap constructor does not copy data', () {
      var map = toObservable({'list': [1, 2, 3]});
      var e = new RawEntity.wrapMap(map);
      map['list'].add(4);
      expect(e['list'].length, equals(4));
      expect(e['list'][3], equals(4));
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
      var a = new Response(new RawEntity()
        ..['id'] = 'foo', Source.RPC, 0);
      var b = new Response(new RawEntity()
        ..['id'] = 'foo', Source.RPC, 0);
      (testRequestHandler()..values([a, b]))
        .build()
        .transform(() => new EntityDedupTransformer())
        .handle(new TestRequest('GET'), const NoopTrace())
        .single
        .then(expectAsync1((e) {
          expect(Entity.deepEquals(e.entity, a.entity), isTrue);
          expect(Entity.deepEquals(e.entity, b.entity), isTrue);
        }));
    });
  });
  group('OneShotRequestTransformer', () {
    var a = new Response(new RawEntity()
      ..['id'] = 'foo'
      ..['seq'] = 1, Source.CACHE, 0, authority: Authority.SECONDARY);
    var b = new Response(new RawEntity()
      ..['id'] = 'foo'
      ..['seq'] = 2, Source.RPC, 0);
    var c = new Response(new RawEntity()
      ..['id'] = 'foo'
      ..['seq'] = 3, Source.RPC, 0);
    var d = new Response(new RawEntity()
      ..['id'] = 'foo'
      ..['seq'] = 4, Source.CACHE, 0, authority: Authority.PRIMARY);
    var rpcOnly;
    var cacheAndRpc;
    var primaryCache;
    setUp(() {
      rpcOnly = (testRequestHandler()
        ..values([b, c]))
        .build();
      cacheAndRpc = (testRequestHandler()
        ..values([a, b, c]))
        .build();
      primaryCache = (testRequestHandler()
        ..values([d, b]))
        .build();
    });
    test('handles one RPC response correctly', () {
      var onlyResponse = rpcOnly
        .transform(() => const OneShotRequestTransformer())
        .handle(new TestRequest('GET'), const NoopTrace())
        .single;
      asyncExpect(onlyResponse.then((e) => e.source), equals('RPC'));
    });
    test('handles multiple responses correctly', () {
      var stream = cacheAndRpc
        .transform(() => const OneShotRequestTransformer())
        .handle(new TestRequest('GET'), const NoopTrace())
        .asBroadcastStream();
      asyncExpect(stream.first.then((e) => e.source), equals('CACHE'));
      asyncExpect(stream.last.then((e) => e.source), equals('RPC'));
      asyncExpect(stream.length, equals(2));
    });
    test('handles cache with PRIMARY authority correctly', () {
      var onlyResponse = primaryCache
        .transform(() => const OneShotRequestTransformer())
        .handle(new TestRequest('GET'), const NoopTrace())
        .single;
      asyncExpect(onlyResponse.then((e) => e.source), 'CACHE');
    });
  });
}

asyncExpect(Future future, matcher) => future.then(expectAsync1((v) {
  expect(v, matcher);
}));
