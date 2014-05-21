library streamy.generated.addendum.test;

import 'dart:async';
import 'package:json/json.dart';
import 'package:unittest/unittest.dart';
import 'package:streamy/streamy.dart';
import 'addendum_client.dart';
import 'addendum_client_dispatch.dart';
import 'addendum_client_objects.dart';

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
  Stream<Map> stream;
  ImmediateRequestHandler(Foo value) {
    this.stream = new Stream.fromIterable([new Marshaller().marshalFoo(value)]);
  }
  Stream<Response<Foo>> handle(Request request, Trace trace) {
    expect(request.local['dedup'], equals(true));
    expect(request.local['ttl'], equals(800));
    expect(request.local['foo'], equals('baz'));
    return stream.map((data) => new Response(request.unmarshalResponse(data), Source.RPC, 0));
  }
}
