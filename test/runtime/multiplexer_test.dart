library streamy.runtime.multiplexer.test;

import 'dart:async';

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
      var subject = new MultiplexingRequestHandler(testHandler);
      subject
        .handle(TEST_GET_REQUEST, const NoopTrace())
        .first
        .catchError(expectAsync1((err) {
          expect(err, new isInstanceOf<StreamyRpcException>());
          expect(err.httpStatus, 404);
        }));
    });
    test('sends new value across request bounds', () {
      var r1 = new RawEntity()
        ..['key'] = 'alpha';
      var r2 = new RawEntity()
        ..['key'] = 'beta';
      var testHandler = (
          testRequestHandler()
            ..value(new Response(r1, Source.RPC, 0))
            ..value(new Response(r2, Source.RPC, 1))
        ).build();
      var subject = new MultiplexingRequestHandler(testHandler);
      var stream = subject
          .handle(TEST_GET_REQUEST, const NoopTrace())
          .map((e) => e.entity)
          .asBroadcastStream();
      stream.first.then(expectAsync1((e) {
        expect(e['key'], 'alpha');
        subject
          .handle(TEST_GET_REQUEST, const NoopTrace())
          .map((e) => e.entity)
          .first
          .then(expectAsync1((e) {
            expect(e['key'], 'beta');
          }));
      }, count: 1));
      stream.skip(1).first.then(expectAsync1((e) {
        expect(e['key'], 'beta');
      }, count: 1));
    });
    test('properly forwards a cancellation', () {
      // Expect onCancel to be called.
      var sink = new StreamController(onCancel: expectAsync0(() {}, count: 1));
      var testHandler = (testRequestHandler()..stream(sink.stream)).build();
      var subject = new MultiplexingRequestHandler(testHandler);
      subject
          .handle(TEST_GET_REQUEST, const NoopTrace())
          .listen(expectAsync1((_) {}, count: 0))
          .cancel();
    });
  });
}
