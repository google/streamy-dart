library streamy.runtime.batching.test;

import 'dart:async';
import 'dart:math';

import 'package:streamy/streamy.dart';
import 'package:streamy/testing/testing.dart';
import 'package:unittest/unittest.dart';

main() {
  group('BatchingHttpService', () {
    TestHttpService testHttpService;
    TestBatchingStrategy testStrategy;
    BatchingHttpService subject;
    Random testRandom = new FakeRandom();

    setUp(() {
      testHttpService = new TestHttpService();
      testStrategy = new TestBatchingStrategy();
      subject = new BatchingHttpService('/batch', 'POST',
          {'i-am-batch': 'true'}, testStrategy, testHttpService,
          random: testRandom);
    });

    test('should send single requests', () {
      var req = new StreamyHttpRequest('/test', 'GET', {'a': 'b'}, {}, null);
      var resp = new StreamyHttpResponse(200, {}, 'hello');
      testHttpService.expect(req, resp);
      subject.send(req).then(expectAsync1((r) {
        expect(r, resp);
      }, count: 1));
      testHttpService.flush();
    });

    test('should cancel single requests', () {
      var canceller = new Completer.sync();
      var reqCancel = new StreamyHttpRequest('/one', 'GET', {},
          {}, canceller.future);
      var reqProceed = new StreamyHttpRequest('/two', 'GET', {},
          {}, null);
      var resp = new StreamyHttpResponse(200, {}, '');
      testHttpService.expect(reqProceed, resp);

      subject.send(reqCancel).then(expectAsync1((_) {}, count: 0));
      subject.send(reqProceed).then(expectAsync1((_) {}, count: 1));

      // Cancel batch
      canceller.complete(null);
      testHttpService.flush();
    });

    test('should batch requests', () {
      var req1 = new StreamyHttpRequest('/one', 'GET', {'a': 'b'},
          {'batchMe': 'please'}, null);
      var req2 = new StreamyHttpRequest('/one', 'GET', {'a': 'b'},
          {'iAmLastInBatch': 'indeed'}, null);
      var batchReq = new StreamyHttpRequest.multipart(
          '/batch', 'POST', {'i-am-batch': 'true'}, null, [req1, req2],
          random: testRandom);
      var batchResp = StreamyHttpResponse.parse([
        'HTTP/1.1 200 OK',
        'Host: google.com',
        'Content-Type: multipart/mixed; boundary=ABCDEFG',
        '',
        '--ABCDEFG',
        'HTTP/1.1 200 OK',
        'Host: google.com',
        'Content-Type: text/plain; charset=utf-8',
        'Content-Length: 12',
        '',
        'response1',
        '--ABCDEFG',
        'HTTP/1.1 200 OK',
        'Host: google.com',
        'Content-Type: text/plain; charset=utf-8',
        'Content-Length: 12',
        '',
        'response2',
      ].join('\r\n'));

      testHttpService.expect(batchReq, batchResp);

      subject.send(req1).then(expectAsync1((r) {
        expect(r.body, 'response1\r\n');
      }, count: 1));
      subject.send(req2).then(expectAsync1((r) {
        expect(r.body, 'response2');
      }, count: 1));
      testHttpService.flush();
    });

    test('should cancel batch requests', () {
      var req1 = new StreamyHttpRequest('/one', 'GET', {'a': 'b'},
          {'batchMe': 'please'}, null);
      var canceller = new Completer.sync();
      var req2 = new StreamyHttpRequest('/one', 'GET', {'a': 'b'},
          {'iAmLastInBatch': 'indeed'}, canceller.future);
      var batchReq = new StreamyHttpRequest.multipart(
          '/batch', 'POST', {}, null, [req1, req2], random: testRandom);

      subject.send(req1).then(expectAsync1((_) {}, count: 0));
      subject.send(req2).then(expectAsync1((_) {}, count: 0));

      // Cancel batch
      canceller.complete(null);
      testHttpService.flush();
    });
  });
}

/**
 * Test strategy is:
 * - Put requests with 'batchMe' local field into a batch
 * - Use requests with 'iAmLastInBatch' as a signal that it's time to actually
 *   send the batch. Also this last request's onCacnel is used to cancel the
 *   entire batch request.
 * - Send all other requests immediately
 */
class TestBatchingStrategy implements BatchingStrategy {
  final batchSink = new StreamController(sync: true);

  List<StreamyHttpRequest> batch = [];

  void add(StreamyHttpRequest req) {
    if (req.local.containsKey('batchMe')) {
      batch.add(req);
    } else if (req.local.containsKey('iAmLastInBatch')) {
      batch.add(req);
      batchSink.add(new TestBatch(batch, req.onCancel));
    } else {
      batchSink.add(req);
    }
  }

  Stream get batches => batchSink.stream;
}

class TestBatch extends Batch {
  StreamyHttpResponse batchResponse;
  TestBatch(List<StreamyHttpRequest> batch, Future onCancel)
      : super(batch, onCancel);
  void done(StreamyHttpResponse batchResponse) {
    this.batchResponse = batchResponse;
  }
}

class FakeRandom implements Random {
  nextInt(a) => 1;

  noSuchMethod(i) {
    throw 'Not supported';
  }
}
