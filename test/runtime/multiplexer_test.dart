library streamy.runtime.multiplexer.test;

import 'dart:async';
import 'package:streamy/streamy.dart';
import 'package:streamy/testing/testing.dart';
import 'package:unittest/unittest.dart';
import '../utils.dart';

main() {
 group('Multiplexer', () {
    test('does not throw on error but forward to error catchers', () {
      var testHandler = (
          testRequestHandler()
            ..rpcError(404)
        ).build();
      var subject = new Multiplexer(testHandler);
      subject.handle(TEST_GET_REQUEST, const NoopTrace()).first.catchError(expectAsync1((err) {
        expect(err, new isInstanceOf<StreamyRpcException>());
        expect(err.httpStatus, 404);
      }));
    });
    test('returns rpc entity on age query on cache miss', () {
      var resp = new Response(new RawEntity()..['foo'] = 'rpc', Source.RPC, 0);
      Request req = new TestRequest('GET');
      req.local['noRpcAge'] = 5000;  // 5 seconds

      var testHandler = (testRequestHandler()..value(resp)).build();

      var subject = new Multiplexer(testHandler);
      subject.handle(req, const NoopTrace()).listen(expectAsync1((actual) {
        expect(actual.entity['foo'], 'rpc');
        expect(actual.source, Source.RPC);
        expect(actual.authority, Authority.PRIMARY);
      }, count: 1));
    });
    test('returns cached then rpc entity on age query on stale cache', () {
      var cachedResp = new Response(new RawEntity()..['foo'] = 'cached', Source.CACHE,
          new DateTime.now().subtract(new Duration(seconds: 10)).millisecondsSinceEpoch);
      Request cachedReq = new TestRequest('GET');

      Request req = new TestRequest('GET');
      // 5-second tolerance to make the cached response is too old
      req.local['noRpcAge'] = 5000;

      var rpcResp = new Response(new RawEntity()..['foo'] = 'rpc', Source.RPC,
          new DateTime.now().millisecondsSinceEpoch);
      var testHandler = (testRequestHandler()..value(rpcResp)).build();

      var cache = new AsyncMapCache();
      var subject = new Multiplexer(testHandler, cache: cache);

      int count = 1;
      cache.set(cachedReq, new CachedEntity(cachedResp.entity, cachedResp.ts))
        .then(expectAsync1((_) {
          subject.handle(req, const NoopTrace()).listen(expectAsync1((actual) {
            if (count == 1) {
              expect(actual.entity['foo'], 'cached');
              expect(actual.source, Source.CACHE);
              expect(actual.authority, Authority.SECONDARY);
            } else if (count == 2) {
              expect(actual.entity['foo'], 'rpc');
              expect(actual.source, Source.RPC);
              expect(actual.authority, Authority.PRIMARY);
            } else {
              fail('Did not expect to reach this line');
            }
            count++;
          }, count: 2));
      }, count: 1));
    });
    test('returns cached entity only on age query on fresh cache', () {
      var cachedResp = new CachedEntity(new RawEntity()..['foo'] = 'cached',
          new DateTime.now().subtract(new Duration(seconds: 5)).millisecondsSinceEpoch);
      Request cachedReq = new TestRequest('GET');

      Request req = new TestRequest('GET');
      // 10-second tolerance to make the cached response is too old
      req.local['noRpcAge'] = 10000;

      var testHandler = testRequestHandler().build();
      var cache = new AsyncMapCache();
      var subject = new Multiplexer(testHandler, cache: cache);

      cache.set(cachedReq, cachedResp).then(expectAsync1((_) {
        subject.handle(req, const NoopTrace()).listen(expectAsync1((actual) {
          expect(actual.entity['foo'], 'cached');
          expect(actual.source, Source.CACHE);
          expect(actual.authority, Authority.PRIMARY);
        }, count: 1));
      }, count: 1));
    });
    test('should trace deduped requests', () {
      // Test handler never returns any values (so everything is deduped)
      var received = <Request>[];
      var reqHandler = new RequestHandler
          .fromFunction((req) {
            received.add(req);
            return new StreamController().stream;
          });
      var tracer = new StreamTracer((_) => false);
      var events = <TraceEvent>[];
      tracer.requests.listen((req) => req.events
          .where((evt) => evt is MultiplexerRpcDedupEvent)
          .listen(events.add));

      var subject = new Multiplexer(reqHandler);

      subject.handle(TEST_GET_REQUEST, tracer.trace(TEST_GET_REQUEST));
      expect(received, hasLength(1),
          reason: 'No in-flight requests to dedupe');
      expect(events, hasLength(0),
          reason: 'This request is not deduped');

      subject.handle(TEST_GET_REQUEST, tracer.trace(TEST_GET_REQUEST));
      expect(received, hasLength(1),
          reason: 'Request should be deduped');
      expect(events, hasLength(1),
          reason: 'The second request is deduped');
      expect(events[0], new isAssignableTo<MultiplexerRpcDedupEvent>(),
          reason: 'Something is wrong with the test setup. We should only '
                  'capture MultiplexerRpcDedupEvents.');
    });
  });
}
