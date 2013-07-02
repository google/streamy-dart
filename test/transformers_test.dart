import "dart:async";
import "package:streamy/base.dart";
import "package:unittest/unittest.dart";

main() {
  group("EntityDedupTransformer", () {
    test("properly dedups", () {
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
  group("SingleRequestTransformer", () {
    var a = new RawEntity()
      ..['id'] = 'foo'
      ..['seq'] = 1
      ..streamy.source = "CACHE";
    var b = new RawEntity()
      ..['id'] = 'foo'
      ..['seq'] = 2
      ..streamy.source = "RPC";
    var c = new RawEntity()
      ..['id'] = 'foo'
      ..['seq'] = 3
      ..streamy.source = "UPDATE";
    var rpcOnly;
    var cacheAndRpc;
    setUp(() {
      rpcOnly = new Stream.fromIterable([b, c]);
      cacheAndRpc = new Stream.fromIterable([a, b, c]);
    });
    test("handles one RPC response correctly", () {
      var onlyResponse = rpcOnly
        .transform(new SingleRequestTransformer())
        .single;
      asyncExpect(onlyResponse.then(streamySource), equals("RPC"));
    });
    test("handles multiple responses correctly", () {
      var stream = cacheAndRpc
        .transform(new SingleRequestTransformer())
        .asBroadcastStream();
      asyncExpect(stream.first.then(streamySource), equals("CACHE"));
      asyncExpect(stream.last.then(streamySource), equals("RPC"));
      asyncExpect(stream.length, equals(2));
    });
  });
}

streamySource(v) => v.streamy.source;

asyncExpect(Future future, matcher) => future.then(expectAsync1((v) {
  expect(v, matcher);
}));