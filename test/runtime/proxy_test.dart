library streamy.runtime.proxy.test;

import 'dart:async';

import 'package:streamy/streamy.dart';
import 'package:unittest/unittest.dart';
import '../generated/method_get_client.dart';
import '../utils.dart';

main() {
  group('ProxyClient', () {
    FakeStreamyHttpService fakeHttp;
    MethodGetTest root;
    ProxyClient subject;

    setUp(() {
      fakeHttp = new FakeStreamyHttpService();
      subject = new ProxyClient('proxy', fakeHttp);
      root = new MethodGetTest(subject);
    });

    test('should serialize and forward request to a service', () {
      expect(fakeHttp.requests, hasLength(0));
      root.foos.get(1).send();
      expect(fakeHttp.requests, hasLength(1));
      var httpReq = fakeHttp.requests[0];
      expect(httpReq.url, 'proxy/getTest/v1/foos/1');
      expect(httpReq.method, 'GET');
      expect(httpReq.payload, isNull);
    });

    test('should cancel request', async(() {
      expect(fakeHttp.cancelledRequests, hasLength(0));
      root.foos.get(1).send().listen((_) {}).cancel();
      fastForward();
      expect(fakeHttp.cancelledRequests, hasLength(1));
    }));

    test('should deserialize response and return to listener', async(() {
      expect(fakeHttp.cancelledRequests, hasLength(0));
      Foo result;
      root.foos.get(1).send().listen((Foo foo) {
        result = foo;
      });
      fakeHttp.lastCompleter.complete(new StreamyHttpResponse(
          200, {'content-type': 'application/json'}, '{"id": 123}'));
      fastForward();
      expect(result, isNotNull);
      expect(result.id, 123);
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
