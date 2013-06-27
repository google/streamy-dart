library method_get_test;

import "dart:async";
import "dart:json";
import "package:unittest/unittest.dart";
import "package:streamy/base.dart";
import "method_get_client.dart";

main() {
  group("MethodGetTest", () {
    test("RequestHttpMethod", () {
      var subject = new MethodGetTest(null);
      expect(subject.foos.get().httpMethod, equals("GET"));
    });
    test("RequestPayload", () {
      var subject = new MethodGetTest(null);
      expect(subject.foos.get().hasPayload, equals(false));
    });
    test("RequestResponseCycle", () {
      Foo testResponse = new Foo()
        ..id = 1
        ..bar = "bar";
      var subject = new MethodGetTest(new ImmediateRequestHandler(testResponse));
      subject.foos.get().send().single.then(expectAsync1((Foo v) {
        expect(v.toJson(), equals(testResponse.toJson()));
      }, count: 1));
    });
    test("API root has proper service path", () {
      var subject = new MethodGetTest(null);
      expect(subject.servicePath, equals("getTest/v1/"));
    });
  });
}

class ImmediateRequestHandler implements RequestHandler {
  Stream<String> stream;
  ImmediateRequestHandler(Foo value) {
    this.stream = new Stream.fromIterable([stringify(value.toJson())]);
  }
  Stream<Foo> handle(Request request) {
    Deserializer d = request.responseDeserializer;
    return new StreamTransformer(
        handleData: (String data, EventSink<Foo> sink) {
          sink.add(d(data));
        }).bind(stream);
  }
}

class DoubleRequestHandler implements RequestHandler {
  Stream<String> stream;
  DoubleRequestHandler(Foo value) {
    this.stream = new Stream.fromIterable([stringify(value), stringify(value)]);
  }
  Stream<Foo> handle(Request request) {
    Deserializer d = request.responseDeserializer;
    return new StreamTransformer(
        handleData: (String data, EventSink<Foo> sink) {
          sink.add(d(data));
        }).bind(stream);
  }
}