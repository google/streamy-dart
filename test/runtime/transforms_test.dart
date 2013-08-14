library streamy.runtime.transforms.test;

import 'dart:async';
import 'package:unittest/unittest.dart';
import 'package:streamy/testing/testing.dart';
import 'package:streamy/streamy.dart';

main() {
  group('RequestTrackingTransformer', () {
    test('Properly tracks a request', () {
      var bareHandler = (testRequestHandler()
        ..values([new Entity()..['x'] = 'a', new Entity()..['x'] = 'b']))
        .build();
      var tracker = new RequestTrackingTransformer();
      var handler = bareHandler.transformResponses(tracker);

      var x = ' ';
      tracker.trackingStream.listen(expectAsync1((event) {
        expect(event.request, equals(TEST_GET_REQUEST));
        expect(x, equals(' '));
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

      tracker.trackingStream.listen(expectAsync1((event) {
        expect(event.request, equals(TEST_GET_REQUEST));
        print("Got tracker");
        event.onFirstResponse.then(expectAsync1((error) {
          print("onFirstResponse");
          expect(error, new isInstanceOf<ArgumentError>());
        }));
      }));
      handler.handle(TEST_GET_REQUEST).listen((_) {
        // Never called.
      }).onError(expectAsync1((error) {
        print("OnError");
        expect(error, new isInstanceOf<ArgumentError>());
      }));
    });
  });
}