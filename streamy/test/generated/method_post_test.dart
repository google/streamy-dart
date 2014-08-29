library streamy.generated.method_post.test;

import 'dart:async';
import 'package:streamy/streamy.dart';
import 'package:unittest/unittest.dart';
import 'method_post_client.dart';
import 'method_post_client_objects.dart';

main() {
  group('MethodPostTest', () {
    var foo;
    setUp(() {
      foo = new Foo()
        ..id = 1
        ..bar = 'bar';
    });
    test('RequestHttpMethod', () {
      var subject = new MethodPostTest(null);
      expect(subject.foos.update(foo).httpMethod, equals('POST'));
    });
    test('RequestPayload', () {
      var subject = new MethodPostTest(null);
      expect(subject.foos.update(foo).hasPayload, equals(true));
    });
    test('Can clone request payload', () {
      var subject = new MethodPostTest(null);
      var update = subject.foos.update(foo);
      var clone = update.clone();
      expect(clone, equals(update));
      expect(clone, isNot(same(update)));
      expect(clone.payload, isNot(same(update.payload)));
    });
    test('RequestResponseCycle', () {
      var subject = new MethodPostTest(new ImmediateRequestHander());
      var testReq = subject.foos.update(foo)
        ..id = 123;
      testReq.send().single.then(expectAsync((e) {
        expect(e.bar, equals('test'));
      }, count: 1));
    });
    test('Prepopulates id from payload', () {
      var subject = new MethodPostTest(null);
      expect(subject.foos.update(foo).path, equals('foos/1'));
    });
  });
}

class ImmediateRequestHander extends RequestHandler {
  Stream<Response> handle(Request request, Trace trace) => new Stream.fromIterable([new Response(new Foo()..bar = 'test', Source.RPC, 0)]);
}
