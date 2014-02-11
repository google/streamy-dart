library streamy.streamy.test;

import 'dart:async';
import 'package:fixnum/fixnum.dart';
import 'package:observe/observe.dart';
import 'package:streamy/streamy.dart';
import 'package:streamy/testing/testing.dart';
import 'package:unittest/unittest.dart';

main() {
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
        .then(expectAsync((e) {
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
  group('FastComparator', () {
    test('sorts by nested fields properly', () {
      var data = [3, 1, 2, 5, 4]
        .map((v) => new RawEntity()
          ..['outer'] = (new RawEntity()
            ..['middle'] = (new RawEntity()
              ..['inner'] = v)))
        .toList();
      data.sort(new FastComparator('outer.middle.inner'));
      expect(data.map((e) => e['outer.middle.inner']), [1, 2, 3, 4, 5]);
    });
    test('minimizes field accesses', () {
      var data = [3, 1, 2, 5, 4]
        .map((v) => new RawEntity()
          ..['outer'] = (new RawEntity()
            ..['middle'] = new AccessCounter('inner', v)))
        .toList();
      data.sort(new FastComparator('outer.middle.inner'));
      expect(data.map((e) => e['outer.middle.accessCount']), [1, 1, 1, 1, 1]);
    });
  });
  group('mapInline', () {
    test('should apply a function to each element', () {
      var l = [1, 2, 3];
      var r = mapInline(str)(l);
      expect(r, same(l));
      expect(l[0], '1');
      expect(l[1], '2');
      expect(l[2], '3');
    });
    test('should leave null list as null', () {
      expect(mapInline(null)(null), isNull);
    });
  });
  group('mapCopy', () {
    test('should apply a function to each element '
         'and leave the original list intact', () {
      var l = [1, 2, 3];
      var r = mapCopy(str)(l);
      expect(r, isNot(same(l)));

      expect(r[0], '1');
      expect(r[1], '2');
      expect(r[2], '3');

      expect(l[0], 1);
      expect(l[1], 2);
      expect(l[2], 3);
    });
    test('should leave null list as null', () {
      expect(mapCopy(null)(null), isNull);
    });
  });
  group('atoi64', () {
    test('should convert String to Int64', () {
      expect(atoi64('123'), new Int64(123));
    });
    test('should leave null as null', () {
      expect(atoi64(null), isNull);
    });
  });
  group('itoi64', () {
    test('should convert int to Int64', () {
      expect(itoi64(123), new Int64(123));
    });
    test('should leave null as null', () {
      expect(itoi64(null), isNull);
    });
  });
  group('atod', () {
    test('should convert String to double', () {
      expect(atod('123'), 123.0);
    });
    test('should leave null as null', () {
      expect(atod(null), isNull);
    });
  });
  group('str', () {
    test('should convert objects to strings', () {
      expect(str(123), '123');
    });
    test('should leave null as null', () {
      expect(str(null), isNull);
    });
  });
}

asyncExpect(Future future, matcher) => future.then(expectAsync((v) {
  expect(v, matcher);
}));

class AccessCounter {
  final String key;
  final int value;
  int accessCount = 0;

  AccessCounter(this.key, this.value);

  operator[](String key) {
    if (key == this.key) {
      accessCount++;
      return value;
    } else if (key == 'accessCount') {
      return accessCount;
    }
    return null;
  }
}
