library streamy.generated.profiling_test;

import 'dart:async';
import 'dart:json';
import 'package:perf_api/perf_api.dart';
import 'package:unittest/unittest.dart';
import 'package:streamy/streamy.dart';
import 'method_get_client.dart';

main() {
  group('Profiling', () {
    test('Response deserializer', () {
      var p = new TestProfiler();
      var foo = new Foo.fromJsonString('{"id":1}', profiler: p, requestType: 'FooRequest');
      expect(p.events, equals(['start:FooRequest: Json parsing', 'end:0', 'start:FooRequest: Wrapping', 'end:1']));
    });
    test('Proxy', () {
      var b = new TestBackend();
      var p = new TestProfiler();
      var proxy = new ProxyClient('/testUrl', b, profiler: p);
      var test = new MethodGetTest(null);
      proxy.handle(test.foos.get(1));
      expect(p.events, equals(['start:FoosGetRequest: Proxy request']));
      b.complete();
      expect(p.events, equals(['start:FoosGetRequest: Proxy request', 'end:0']));
    });
    test('Multiplexer', () {
      var p = new TestProfiler();
      var c = new TestCache();
      var proxy = new ProxyClient('/testUrl', new TestBackend());
      var mplex = new Multiplexer(proxy, cache: c, profiler: p);
      var test = new MethodGetTest(mplex);
      test.foos.get(1).send();
      expect(p.events, equals(['start:FoosGetRequest: Cache fetch']));
      c.complete();
      expect(p.events, equals(['start:FoosGetRequest: Cache fetch', 'end:0']));
    });
  });
}

class TestProfiler extends Profiler {
  var count = 0;
  final events = [];
  
  int startTimer(String name, [String extraData]) {
    events.add('start:$name');
    return count++;
  }
  
  
  void stopTimer(dynamic idOrName) {
    events.add('end:$idOrName');
  }
}

class TestBackend implements StreamyHttpService {

  var completer = new Completer.sync();
  
  StreamyHttpRequest request(String url, String method,
      {String payload: null, String contentType: 'application/json; charset=utf-8'}) =>
      new StreamyHttpRequest(completer.future, () {});
    
  
  void complete() {
    completer.complete(new StreamyHttpResponse(404, 'Not Found', '', 'text/plain'));
  }
}

class TestCache implements Cache {

  var _completer = new Completer.sync();

  Future get(Request request) {
    return _completer.future;
  }
  
  void complete() {
    _completer.complete();
  }
}
