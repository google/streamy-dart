library streamy.generated.addendum.test;

import 'dart:async';
import 'dart:json';
import 'package:unittest/unittest.dart';
import 'package:streamy/streamy.dart';
import 'addendum_client.dart';

main() {
  group('Addendum', () {
    test('Can send requests', () {
      var subject = new AddendumApi(new ImmediateRequestHandler(new Foo()..id = 1));
      subject.foos.get(1).send(foo: 'baz').first.then((res) {
        expect(res.id, equals(1));
      });
      expect(subject.servicePath, equals('addendum/v1/'));
    });
    test('listen() shortcut', () {
      var subject = new AddendumApi(new ImmediateRequestHandler(new Foo()..id = 1));
      subject.foos.get(1).listen((res) {
        expect(res.id, equals(1));
      }, foo: 'baz');
    });
  });
}

class ImmediateRequestHandler extends RequestHandler {
  Stream<String> stream;
  ImmediateRequestHandler(Foo value) {
    this.stream = new Stream.fromIterable([stringify(value.toJson())]);
  }
  Stream<Foo> handle(Request request) {
    expect(request.local['dedup'], equals(true));
    expect(request.local['ttl'], equals(800));
    expect(request.local['foo'], equals('baz'));
    Deserializer d = request.responseDeserializer;
    return new StreamTransformer.fromHandlers(
        handleData: (String data, EventSink<Foo> sink) {
          sink.add(d(data));
        }).bind(stream);
  }
}
