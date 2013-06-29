library addendum_test;

import "dart:async";
import "dart:json";
import "package:unittest/unittest.dart";
import "package:streamy/base.dart";
import "addendum_client.dart";

main() {
  group("Addendum", () {
    test("Can send requests", () {
      var subject = new AddendumTest(new ImmediateRequestHandler(new Foo()..id = 1));
      subject.foos.get().send(foo: "baz").first.then((res) {
        expect(res.id, equals(1));
      });
      expect(subject.servicePath, equals("addendum/v1/"));
    });
  });
}

class ImmediateRequestHandler implements RequestHandler {
  Stream<String> stream;
  ImmediateRequestHandler(Foo value) {
    this.stream = new Stream.fromIterable([stringify(value.toJson())]);
  }
  Stream<Foo> handle(Request request) {
    expect(request.local.dedup, equals(true));
    expect(request.local.ttl, equals(800));
    expect(request.local.foo, equals("baz"));
    Deserializer d = request.responseDeserializer;
    return new StreamTransformer(
        handleData: (String data, EventSink<Foo> sink) {
          sink.add(d(data));
        }).bind(stream);
  }
}
