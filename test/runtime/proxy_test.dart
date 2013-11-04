library streamy.runtime.proxy.test;

import 'dart:async';

import 'package:fixnum/fixnum.dart';
import 'package:streamy/streamy.dart';
import 'package:unittest/unittest.dart';
import '../generated/bank_api_client.dart';
import '../utils.dart';

main() {
  group('ProxyClient', () {
    FakeStreamyHttpService fakeHttp;
    Bank root;
    ProxyClient subject;

    setUp(() {
      fakeHttp = new FakeStreamyHttpService();
      subject = new ProxyClient('proxy', fakeHttp);
      root = new Bank(subject);
    });

    test('should serialize and forward request to a service', () {
      expect(fakeHttp.requests, hasLength(0));
      root.branches.get(new Int64(1)).send();
      expect(fakeHttp.requests, hasLength(1));
      var httpReq = fakeHttp.requests[0];
      expect(httpReq.url, 'proxy/bank/v1/branches/1');
      expect(httpReq.method, 'GET');
      expect(httpReq.payload, isNull);
    });

    test('should cancel request', async(() {
      expect(fakeHttp.cancelledRequests, hasLength(0));
      root.branches.get(new Int64(1)).send().listen((_) {}).cancel();
      fastForward();
      expect(fakeHttp.cancelledRequests, hasLength(1));
    }));

    test('should deserialize response and return to listener', async(() {
      expect(fakeHttp.cancelledRequests, hasLength(0));
      Branch result;
      root.branches.get(new Int64(1)).send().listen((Branch foo) {
        result = foo;
      });
      fakeHttp.lastCompleter.complete(new StreamyHttpResponse(
          200, {'content-type': 'application/json'}, '{"id": "123"}'));
      fastForward();
      expect(result, isNotNull);
      expect(result.id, new Int64(123));
    }));

    test('should set content-type in requests with payload', () {
      expect(fakeHttp.requests, hasLength(0));
      root.branches.insert(new Branch()..id = new Int64(1)).send();
      expect(fakeHttp.requests, hasLength(1));
      var httpReq = fakeHttp.requests[0];
      expect(httpReq.url, 'proxy/bank/v1/branches');
      expect(httpReq.method, 'POST');
      expect(httpReq.payload, isNotNull);
      expect(httpReq.headers['content-type'],
          'application/json; charset=utf-8');
    });

    test('should not set content-type in requests without payload', () {
      expect(fakeHttp.requests, hasLength(0));
      root.branches.get(new Int64(1)).send();
      expect(fakeHttp.requests, hasLength(1));
      var httpReq = fakeHttp.requests[0];
      expect(httpReq.url, 'proxy/bank/v1/branches/1');
      expect(httpReq.method, 'GET');
      expect(httpReq.payload, isNull);
      expect(httpReq.headers['content-type'], isNull);
    });
  });
}

class FakeStreamyHttpService implements StreamyHttpService {
  List<StreamyHttpRequest> requests = [];
  List<StreamyHttpRequest> cancelledRequests = [];
  Completer<StreamyHttpResponse> lastCompleter;

  Future<StreamyHttpResponse> send(StreamyHttpRequest request) {
    requests.add(request);
    lastCompleter = new Completer();
    request.onCancel.then((_) {
      cancelledRequests.add(request);
    });
    return lastCompleter.future;
  }
}
