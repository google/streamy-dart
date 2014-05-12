library streamy.runtime.cache.test;

import 'package:streamy/streamy.dart';
import 'package:streamy/testing/testing.dart';
import 'package:quiver/time.dart';
import 'package:unittest/unittest.dart';

main() {
  group('CachingRequestHandler', () {
    var time = new DateTime.utc(2013, 4, 25);
    var clock = new Clock(() => time);
    var handler;
    var cache;
    setUp(() {
      var delegate = (testRequestHandler()
          ..value(new Response(
              new RawEntity()..['value'] = 'hello',
              Source.RPC,
              time.millisecondsSinceEpoch))
          ..value(new Response(
              new RawEntity()..['value'] = 'world',
              Source.RPC,
              time.millisecondsSinceEpoch + 1000)))
          .build();
      cache = new AsyncMapCache();
      handler = new CachingRequestHandler(delegate, cache, clock: clock);
    });
    test('handles a basic get', () {
      handler.handle(TEST_GET_REQUEST, const NoopTrace()).single.then(expectAsync((v) {
        expect(v.source, Source.RPC);
        expect(v.entity['value'], 'hello');
      }));
    });
    test('handles a cached get', () {
      // First request stages.
      handler.handle(TEST_GET_REQUEST, const NoopTrace()).single.then(expectAsync((_) {
        handler.handle(TEST_GET_REQUEST, const NoopTrace()).toList().then(expectAsync((list) {
          expect(list[0].source, Source.CACHE);
          expect(list[0].authority, Authority.SECONDARY);
          expect(list[0].entity['value'], 'hello');
          expect(list[1].source, Source.RPC);
          expect(list[1].authority, Authority.PRIMARY);
          expect(list[1].entity['value'], 'world');
        }));
      }));
    });
    test('handles a non-cachable request', () {
      handler.handle(TEST_DELETE_REQUEST, const NoopTrace()).single.then(expectAsync((_) {
        handler.handle(TEST_DELETE_REQUEST, const NoopTrace()).single.then(expectAsync((v) {
          expect(v.source, Source.RPC);
        }));
      }));
    });
    test('reports CacheMissEvent and delegates', () {
      var tracer = new StreamTracer((_) => false);
      var events = <TraceEvent>[];
      tracer.requests.listen((req) => req.events
          .where((evt) => evt is CacheMissEvent)
          .listen(events.add));
      var req = new TestRequest('GET');
      handler.handle(req, tracer.trace(req)).single.then(expectAsync((v) {
        expect(v.source, Source.RPC);
        expect(v.entity['value'], 'hello');
        expect(events, hasLength(1));
      }));
    });
    test('reports CacheHitEvent and delegates', () {
      var tracer = new StreamTracer((_) => false);
      var events = <TraceEvent>[];
      tracer.requests.listen((req) => req.events
          .where((evt) => evt is CacheHitEvent)
          .listen(events.add));
      var req = new TestRequest('GET');
      handler.handle(req, tracer.trace(req)).single.then(expectAsync((v) {
        // First time cache is cold
        expect(v.source, Source.RPC);
        expect(v.entity['value'], 'hello');
        expect(events, hasLength(0));
        handler.handle(req, tracer.trace(req)).toList().then(expectAsync((v) {
          // Second time cache is hot
          expect(v[0].source, Source.CACHE);
          expect(v[0].entity['value'], 'hello');
          expect(v[1].source, Source.RPC);
          expect(v[1].entity['value'], 'world');
          expect(events, hasLength(1));
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
    test('reports noRpcAge CacheHitEvent and does not delegates', () {
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
          expect(v, hasLength(1),
              reason: 'Because entity is young enough to be PRIMARY');
          expect(v[0].source, Source.CACHE);
          expect(v[0].authority, Authority.PRIMARY);
          expect(v[0].entity['value'], 'hello');
          expect(events, hasLength(1));
        }));
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
      time = time.add(new Duration(milliseconds: 10));  // past noRpcAge value
      handler.handle(req, tracer.trace(req)).single.then(expectAsync((v) {
        expect(v.source, Source.RPC);
        expect(v.entity['value'], 'hello');
        expect(events, hasLength(0));
        handler.handle(req, tracer.trace(req)).toList().then(expectAsync((v) {
          expect(v, hasLength(2),
              reason: 'Because entity is old');
          expect(v[0].source, Source.CACHE);
          expect(v[0].authority, Authority.SECONDARY);
          expect(v[0].entity['value'], 'hello');
          expect(v[1].source, Source.RPC);
          expect(v[1].authority, Authority.PRIMARY);
          expect(v[1].entity['value'], 'world');
          expect(events, hasLength(1));
        }));
      }));
    });
  });
}
