library streamy.runtime.transforms.test;

import 'dart:async';
import 'package:unittest/unittest.dart';
import 'package:streamy/testing/testing.dart';
import 'package:streamy/streamy.dart';

main() {
  group('RequestTrackingTransformer', () {
    solo_test('Properly tracks a request', () {
      var bareHandler = (testRequestHandler()
        ..values([
          new Response(new Entity()..['x'] = 'a', Source.RPC, 0),
          new Response(new Entity()..['x'] = 'b', Source.RPC, 0)]))
        .build();
      var handler = bareHandler.transform(() => new UserCallbackTracingTransformer());
      var tracer = new StreamTracer();
      var root = new TestingRoot(handler, tracer);

      var x = ' ';
      tracer.listen(expectAsync1((event) {
        expect(event.request, equals(TEST_GET_REQUEST));
        expect(x, equals(' '));
        x = '_';
        event.beforeFirstResponse.then(expectAsync1((_) {
          expect(x, equals('_'));
        }));
        event.onFirstResponse.then(expectAsync1((entity) {
          expect(x, equals('a'));
        }));
      }));
      handler.handle(TEST_GET_REQUEST).listen(expectAsync1((entity) {
        x = entity['x'];
      }, count: 2));
    });
    test('Properly handles errors', () {
      var bareHandler = (testRequestHandler()
        ..error(new ArgumentError("test")))
        .build();
      var tracker = new RequestTrackingTransformer();
      var handler = bareHandler.transformResponses(tracker);
      var sawErrorOnStream = false;

      tracker.trackingStream.listen(expectAsync1((event) {
        expect(event.request, equals(TEST_GET_REQUEST));
        event.beforeFirstResponse.then(expectAsync1((error) {
          expect(error, new isInstanceOf<ArgumentError>());
          expect(sawErrorOnStream, isFalse);
        }));
        event.onFirstResponse.then(expectAsync1((error) {
          expect(error, new isInstanceOf<ArgumentError>());
          expect(sawErrorOnStream, isTrue);
        }));
      }));
      handler.handle(TEST_GET_REQUEST).listen((_) {
        // Never called.
      }).onError(expectAsync1((error) {
        expect(error, new isInstanceOf<ArgumentError>());
        sawErrorOnStream = true;
      }));
    });
  });
}