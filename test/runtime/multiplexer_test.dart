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
        .catchError(expectAsync((err) {
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
      stream.first.then(expectAsync((e) {
        expect(e['key'], 'alpha');
        subject
          .handle(TEST_GET_REQUEST, const NoopTrace())
          .map((e) => e.entity)
          .first
          .then(expectAsync((e) {
            expect(e['key'], 'beta');
          }));
      }, count: 1));
      stream.skip(1).first.then(expectAsync((e) {
        expect(e['key'], 'beta');
      }, count: 1));
    });
    test('properly forwards a cancellation', () {
      // Expect onCancel to be called.
      var sink = new StreamController(onCancel: expectAsync(() {}, count: 1));
      var testHandler = (testRequestHandler()..stream(sink.stream)).build();
      var subject = new MultiplexingRequestHandler(testHandler);
      subject
          .handle(TEST_GET_REQUEST, const NoopTrace())
          .listen(expectAsync((_) {}, count: 0))
          .cancel();
    });
    test('demotes primary responses to secondary before first response', () {
      var s1 = new StreamController<Response>();
      var s2 = new StreamController<Response>();
      var testHandler = (
          testRequestHandler()
            ..stream(s1.stream)
            ..stream(s2.stream)
        ).build();
      var subject = new MultiplexingRequestHandler(testHandler);

      // First stream used to assert test conditions.
      var stream = subject
        .handle(TEST_GET_REQUEST, const NoopTrace())
        .asBroadcastStream();

      // Crossover response from [s2] considered SECONDARY.
      stream.first.then(expectAsync((r) {
        expect(r.authority, Authority.SECONDARY);
        expect(r.entity['key'], 'bar');
        s1.add(new Response(new RawEntity()..['key'] = 'foo', Source.RPC, 0));
      }));

      // Primary response from [s1] considered PRIMARY.
      stream.skip(1).first.then(expectAsync((r) {
        expect(r.authority, Authority.PRIMARY);
        expect(r.entity['key'], 'foo');
        s2.add(new Response(new RawEntity()..['key'] = 'baz', Source.RPC, 0));
      }));

      // Crossover response from [s2] now considered PRIMARY.
      stream.skip(2).first.then(expectAsync((r) {
        expect(r.authority, Authority.PRIMARY);
        expect(r.entity['key'], 'baz');
      }));

      // Second request used to trigger test conditions (and verify that
      // the response is still considered PRIMARY.
      var second = subject
        .handle(TEST_GET_REQUEST, const NoopTrace())
        .asBroadcastStream();

      // Needed to ensure this listener stays active in the
      // [MultiplexingRequestHandler] so values sent to it will be echoed
      // in [stream].
      second.drain();
      second
        .first
        .then(expectAsync((r) {
          expect(r.authority, Authority.PRIMARY);
          expect(r.entity['key'], 'bar');
        }));

        s2.add(new Response(new RawEntity()..['key'] = 'bar', Source.RPC, 0,
            authority: Authority.PRIMARY));
    });
  });
}
