library streamy.runtime.error.test;

import 'dart:async';
import 'package:streamy/streamy.dart';
import 'package:streamy/testing/testing.dart';
import 'package:unittest/unittest.dart';

main() {
  group('RetryingRequestHandler', () {
    test('retries immediately on single 503 error', () {
      var testHandler = (
          testRequestHandler()
            ..rpcError(503)
            ..value(new Response(new RawEntity(), Source.RPC, 0))
        ).build();
      var subject = new RetryingRequestHandler(testHandler);
      subject.handle(TEST_GET_REQUEST, const NoopTrace()).first.then(expectAsync1((res) {
        expect(res.entity, new isInstanceOf<RawEntity>());
      }));
    });
    test("doesn't retry on 404 error", () {
      var testHandler = (
          testRequestHandler()
            ..rpcError(404)
        ).build();
      // Expect the retry strategy to not be called.
      var subject = new RetryingRequestHandler(testHandler, strategy: expectAsync3((a, b, c) {}, count: 0));
      subject.handle(TEST_GET_REQUEST, const NoopTrace()).first.catchError(expectAsync1((e) {
        expect(e, new isInstanceOf<StreamyRpcException>());
      }));
    });
    test('retries the maximum number of times', () {
      var testHandler = (
          testRequestHandler()
            ..rpcError(503, times: 3)
            ..value(new Response(new RawEntity(), Source.RPC, 0))
        ).build();

      int retryCount = 0;
      Future<bool> testStrategy(Request request, int retryNum, e) {
        expect(e.httpStatus, equals(503));
        expect(retryNum, equals(++retryCount));
        return new Future.value(true);
      }

      var subject = new RetryingRequestHandler(testHandler, strategy: expectAsync3(testStrategy, count: 3, max: 3));
      subject.handle(TEST_GET_REQUEST, const NoopTrace()).first.then(expectAsync1((res) {
        expect(res.entity, new isInstanceOf<RawEntity>());
      }));
    });
    test("doesn't retry past the maximum number of times", () {
      var testHandler = (
          testRequestHandler()
            ..rpcError(503, times: 4)
            ..value(new Response(new RawEntity(), Source.RPC, 0))
        ).build();

      int retryCount = 0;
      Future<bool> testStrategy(Request request, int retryNum, e) {
        expect(e.httpStatus, equals(503));
        expect(retryNum, equals(++retryCount));
        return new Future.value(true);
      }

      var subject = new RetryingRequestHandler(testHandler, maxRetries: 3, strategy: expectAsync3(testStrategy, count: 3, max: 3));
      subject.handle(TEST_GET_REQUEST, const NoopTrace()).first.catchError(expectAsync1((e) {
        expect(e, new isInstanceOf<StreamyRpcException>());
      }));
    });
  });
}

expectAsync3(fn, {count: 1, max: 0}) {
  var tracker = expectAsync0(() {}, count: count, max: max);
  return (a, b, c) {
    tracker();
    return fn(a, b, c);
  };
}