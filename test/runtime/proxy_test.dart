library streamy.runtime.proxy.test;

import 'dart:async';

import 'package:fixnum/fixnum.dart';
import 'package:streamy/streamy.dart';
import 'package:unittest/unittest.dart';
import '../generated/bank_api_client.dart';
import '../generated/bank_api_client_objects.dart';
import '../utils.dart';

main() {
  group('ProxyClient', () {
    FakeStreamyHttpService fakeHttp;
    Bank root;
    ProxyClient subject;
    StreamTracer tracer;

    setUp(() {
      fakeHttp = new FakeStreamyHttpService();
      subject = new ProxyClient('proxy', fakeHttp);
      tracer = new StreamTracer((_) => false);
      root = new Bank(subject, tracer: tracer);
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

    test('should deserialize response and return to listener frozen', async(() {
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
      expect(result.isFrozen, isTrue);
    }));

    test('should accept 204 No Content and report it as null', async(() {
      expect(fakeHttp.cancelledRequests, hasLength(0));
      Response<Branch> result;
      root.branches.get(new Int64(1)).sendRaw().listen((Response<Branch> r) {
        result = r;
      });
      fakeHttp.lastCompleter.complete(new StreamyHttpResponse(204, {}, ''));
      fastForward();
      expect(result, isNotNull);
      expect(result.entity, isNull);
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

    test('should send trace events', async(() {
      var events = [];
      tracer.requests.listen((TracedRequest req) {
        req.events.listen(events.add);
      });
      root.branches.get(new Int64(1)).send();
      fakeHttp.lastCompleter.complete(new StreamyHttpResponse(
          200, {'content-type': 'application/json'}, '{"id": "123"}'));
      fastForward();
      expect(events, hasLength(4));
      expect(events[0].runtimeType, JsonParseStartEvent);
      expect(events[1].runtimeType, JsonParseEndEvent);
      expect(events[2].runtimeType, DeserializationStartEvent);
      expect(events[3].runtimeType, DeserializationEndEvent);
    }));

    test('should turn errors into StreamyRpcException', async(() {
      var result;
      StreamyRpcException err;
      root.branches.get(new Int64(1)).send()
        .listen((r) { result = r; },
            onError: (e) { err = e; });
      fakeHttp.lastCompleter.complete(new StreamyHttpResponse(500, {
        'content-type': 'application/json'
      }, '''
        {
          "error": {
            "errors": [{ "message": "this is an error!" }]
          }
        }'''));
      fastForward();
      expect(result, isNull);
      expect(err, isNotNull);
      expect(err.errors, hasLength(1));
      expect(err.error.containsKey('message'), isTrue);
      expect(err.message, 'this is an error!');
    }));
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
