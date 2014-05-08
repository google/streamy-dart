library streamy.runtime.cache.test;

import 'package:streamy/streamy.dart';
import 'package:streamy/testing/testing.dart';
import 'package:unittest/unittest.dart';

main() {
  group('CachingRequestHandler', () {
    var handler;
    var cache;
    setUp(() {
      var delegate = (testRequestHandler()
          ..value(new Response(new RawEntity()..['value'] = 'hello', Source.RPC, 0))
          ..value(new Response(new RawEntity()..['value'] = 'world', Source.RPC, 0)))
          .build();
      cache = new AsyncMapCache();
      handler = new CachingRequestHandler(delegate, cache);
    });
    test('handles a basic get', () {
      handler.handle(TEST_GET_REQUEST, const NoopTrace()).single.then(expectAsync1((v) {
        expect(v.source, Source.RPC);
        expect(v.entity['value'], 'hello');
      }));
    });
    test('handles a cached get', () {
      // First request stages.
      handler.handle(TEST_GET_REQUEST, const NoopTrace()).single.then(expectAsync1((_) {
        handler.handle(TEST_GET_REQUEST, const NoopTrace()).toList().then(expectAsync1((list) {
          expect(list[0].source, Source.CACHE);
          expect(list[0].entity['value'], 'hello');
          expect(list[1].source, Source.RPC);
          expect(list[1].entity['value'], 'world');
        }));
      }));
    });
    test('handles a non-cachable request', () {
      handler.handle(TEST_DELETE_REQUEST, const NoopTrace()).single.then(expectAsync1((_) {
        handler.handle(TEST_DELETE_REQUEST, const NoopTrace()).single.then(expectAsync1((v) {
          expect(v.source, Source.RPC);
        }));
      }));
    });
    test('reports noRpcAge CacheMissEvent and delegates', () {
      var tracer = new StreamTracer((_) => false);
      var events = <TraceEvent>[];
      tracer.requests.listen((req) => req.events
          .where((evt) => evt is CacheMissEvent)
          .listen(events.add));
      var req = new TestRequest('GET')
          ..local['noRpcAge'] = 5;
      handler.handle(req, tracer.trace(req)).single.then(expectAsync((v) {
        expect(v.source, Source.RPC);
        expect(v.entity['value'], 'hello');
        expect(events, hasLength(1));
      }));
    });
    test('reports noRpcAge CacheHitEvent and delegates', () {
      var tracer = new StreamTracer((_) => false);
      var events = <TraceEvent>[];
      tracer.requests.listen((req) => req.events
          .where((evt) => evt is CacheHitEvent)
          .listen(events.add));
      var req = new TestRequest('GET')
          ..local['noRpcAge'] = 5;
      handler.handle(req, tracer.trace(req)).single.then(expectAsync((v) {
        expect(v.source, Source.RPC);
        expect(v.entity['value'], 'hello');
        expect(events, hasLength(0));
        handler.handle(req, tracer.trace(req)).toList().then(expectAsync((v) {
          expect(v[0].source, Source.CACHE);
          expect(v[0].entity['value'], 'hello');
          expect(v[1].source, Source.RPC);
          expect(v[1].entity['value'], 'world');
          expect(events, hasLength(1));
        }));
      }));
    });
  });
}
