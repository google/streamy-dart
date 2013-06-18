import "dart:async";
import "dart:json";
import "package:third_party/dart/streamy/lib/base.dart";
import "package:third_party/dart/streamy/test/generated/method_post_client.dart";
import "package:third_party/dart/unittest/lib/unittest.dart";

main() {
  group("MethodPostTest", () {
    var foo;
    setUp(() {
      foo = new Foo()
        ..id = 1
        ..bar = "bar";
    });
    test("RequestHttpMethod", () {
      var subject = new MethodPostTest(null);
      expect(subject.foos.update(foo).httpMethod, equals("POST"));
    });
    test("RequestPayload", () {
      var subject = new MethodPostTest(null);
      expect(subject.foos.update(foo).hasPayload, equals(true));
    });
    test("RequestResponseCycle", () {
      var subject = new MethodPostTest(new ImmediateRequestHander());
      var testReq = subject.foos.update(foo)
        ..fooId = 123;
      testReq.send().single.then(expectAsync1((Object v) {
        expect(v, equals("test"));
      }, count: 1));
    });
  });
}

class ImmediateRequestHander implements RequestHandler {
  Stream<Foo> handle(Request request) => new Stream.fromIterable(["test"]);
}
