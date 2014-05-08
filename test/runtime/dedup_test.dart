library streamy.runtime.dedup.test;

import 'dart:async';
import 'package:streamy/streamy.dart';
import 'package:streamy/testing/testing.dart';
import 'package:unittest/unittest.dart';
import '../utils.dart';

main() {
  group('DeduplicatingRequestHandler', () {
    test('deduplicates 5 identical cachable requests', () {
      var handler = (testRequestHandler()
        ..values([
            new Response(new RawEntity()..['key'] = 'foo', Source.CACHE, 0),
            new Response(new RawEntity()..['key'] = 'bar', Source.RPC, 1)
        ]))
        .build();
      var subject = new DeduplicatingRequestHandler(handler);
      void sendOneRequest() {
        var first = true;
        subject
          .handle(TEST_GET_REQUEST, const NoopTrace())
          .map((r) => r.entity)
          .listen(expectAsync1((e) {
            if (first) {
              expect(e['key'], 'foo');
              first = false;
            } else {
              expect(e['key'], 'bar');
            }
          }, count: 2));
      }
      sendOneRequest();
      sendOneRequest();
      sendOneRequest();
      sendOneRequest();
      sendOneRequest();
    });
    test('does not deduplicate after first response', () {
      var handler = (testRequestHandler()
        ..value(new Response(new RawEntity()..['key'] = 'foo', Source.RPC, 0))
        ..value(new Response(new RawEntity()..['key'] = 'bar', Source.RPC, 0)))
        .build();
      var subject = new DeduplicatingRequestHandler(handler);
      subject
        .handle(TEST_GET_REQUEST, const NoopTrace())
        .map((r) => r.entity)
        .single
        .then(expectAsync1((e) {
          expect(e['key'], 'foo');
          subject
            .handle(TEST_GET_REQUEST, const NoopTrace())
            .map((r) => r.entity)
            .single
            .then(expectAsync1((e) {
              expect(e['key'], 'bar');
            }));
        }));
    });
    test('does not deduplicate 3 non-cachable requests', () {
      var handler = (testRequestHandler()
        ..value(new Response(new RawEntity()..['key'] = 'foo', Source.RPC, 1))
        ..value(new Response(new RawEntity()..['key'] = 'bar', Source.RPC, 1))
        ..value(new Response(new RawEntity()..['key'] = 'baz', Source.RPC, 1)))
        .build();
      var subject = new DeduplicatingRequestHandler(handler);
      void sendOneRequest(expected) {
        var first = true;
        subject
          .handle(TEST_DELETE_REQUEST, const NoopTrace())
          .map((r) => r.entity)
          .single
          .then(expectAsync1((e) {
            expect(e['key'], expected);
          }));
      }
      sendOneRequest('foo');
      sendOneRequest('bar');
      sendOneRequest('baz');
    });
    test('delegate request cancelled when deduped requests are cancelled immediately', () {
      var cancelled = false;
      var sink = new StreamController(onCancel: () {
        cancelled = true;
      });
      var handler = (testRequestHandler()..stream(sink.stream)).build();
      var subject = new DeduplicatingRequestHandler(handler);
      void nop(_) {}
      var a = subject.handle(TEST_GET_REQUEST, const NoopTrace()).listen(nop);
      var b = subject.handle(TEST_GET_REQUEST, const NoopTrace()).listen(nop);
      expect(cancelled, isFalse);
      a.cancel();
      expect(cancelled, isFalse);
      b.cancel();
      expect(cancelled, isTrue);
    });
    test('delegate request cancelled when deduped requests are cancelled after first value', () {
      var cancelled = false;
      var sink = new StreamController<Response>(onCancel: () {
        cancelled = true;
      });
      var handler = (testRequestHandler()..stream(sink.stream)).build();
      var subject = new DeduplicatingRequestHandler(handler);
      var a;
      var b;
      a = subject.handle(TEST_GET_REQUEST, const NoopTrace()).listen((_) {});
      b = subject.handle(TEST_GET_REQUEST, const NoopTrace()).listen(expectAsync1((_) {
        expect(cancelled, isFalse);
        a.cancel();
        expect(cancelled, isFalse);
        b.cancel();
        expect(cancelled, isTrue);
      }));
      sink.add(new Response(new RawEntity(), Source.RPC, 0));
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
          .where((evt) => evt is RpcDeduplicatedEvent)
          .listen(events.add));

      var subject = new DeduplicatingRequestHandler(reqHandler);

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
      expect(events[0], new isAssignableTo<RpcDeduplicatedEvent>(),
          reason: 'Something is wrong with the test setup. We should only '
                  'capture MultiplexerRpcDedupEvents.');
    });
  });
}