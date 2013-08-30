library streamy.runtime.multiplexer.test;

import 'package:streamy/streamy.dart';
import 'package:streamy/testing/testing.dart';
import 'package:unittest/unittest.dart';

main() {
  group('Multiplexer', () {
    test('does not throw on error but forward to error catchers', () {
      var testHandler = (
          testRequestHandler()
            ..rpcError(404)
        ).build();
      var subject = new Multiplexer(testHandler);
      subject.handle(TEST_GET_REQUEST).first.catchError(expectAsync1((err) {
        expect(err, new isInstanceOf<StreamyRpcException>());
        expect(err.httpStatus, equals(404));
      }));
    });
    test('returns rpc entity on age query on cache miss', () {
      var resp = new RawEntity()..['foo'] = 'rpc';
      Request req = new TestRequest('GET');
      req.local['noRpcAge'] = 5000;  // 5 seconds

      var testHandler = (testRequestHandler()..value(resp)).build();

      var subject = new Multiplexer(testHandler);
      subject.handle(req).listen(expectAsync1((actual) {
        expect(actual['foo'], 'rpc');
      }, count: 1));
    });
    test('returns cached then rpc entity on age query on stale cache', () {
      var cachedResp = new RawEntity()..['foo'] = 'cached';
      // Cached entity is 10 seconds old
      cachedResp.streamy.ts = new DateTime.now().subtract(
          new Duration(seconds: 10)).millisecondsSinceEpoch;
      Request cachedReq = new TestRequest('GET');

      Request req = new TestRequest('GET');
      // 5-second tolerance to make the cached response is too old
      req.local['noRpcAge'] = 5000;

      var rpcResp = new RawEntity()..['foo'] = 'rpc';
      var testHandler = (testRequestHandler()..value(rpcResp)).build();

      var cache = new AsyncMapCache();
      var subject = new Multiplexer(testHandler, cache: cache);

      int count = 1;
      cache.set(cachedReq, cachedResp).then(expectAsync1((_) {
        subject.handle(req).listen(expectAsync1((actual) {
          if (count == 1) {
            expect(actual['foo'], 'cached');
          } else if (count == 2) {
            expect(actual['foo'], 'rpc');
          } else {
            fail('Did not expect to reach this line');
          }
          count++;
        }, count: 2));
      }, count: 1));
    });
    test('returns cached entity only on age query on fresh cache', () {
      var cachedResp = new RawEntity()..['foo'] = 'cached';
      // Cached entity is 5 seconds old
      cachedResp.streamy.ts = new DateTime.now().subtract(
          new Duration(seconds: 5)).millisecondsSinceEpoch;
      Request cachedReq = new TestRequest('GET');

      Request req = new TestRequest('GET');
      // 10-second tolerance to make the cached response is too old
      req.local['noRpcAge'] = 10000;

      var testHandler = testRequestHandler().build();
      var cache = new AsyncMapCache();
      var subject = new Multiplexer(testHandler, cache: cache);

      cache.set(cachedReq, cachedResp).then(expectAsync1((_) {
        subject.handle(req).listen(expectAsync1((actual) {
          expect(actual['foo'], 'cached');
        }, count: 1));
      }, count: 1));
    });
  });
}
