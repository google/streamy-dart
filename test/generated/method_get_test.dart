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
    group("Deduping responses", () {
      var subject;
      setUp(() {
        subject = new MethodGetTest(new DoubleRequestHandler(new Foo()..id = 1));
      });
      test("Multiple identical responses are deduped by default", () {
        var calls = 0;
        subject.foos.get().send().listen(expectAsync1((Foo v) {
          expect(v.id, equals(1));
        }, count: 1));
      });
      test("Multiple identical responses are duped if requested", () {
        var calls = 0;
        subject.foos.get().send(dedup: false).listen(expectAsync1((Foo v) {
          expect(v.id, equals(1));
        }, count: 2));
      });
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