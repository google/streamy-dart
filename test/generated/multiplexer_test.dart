library streamy.generated.multiplexer.test;

import 'dart:async';
import 'package:streamy/streamy.dart';
import 'package:unittest/unittest.dart';
import 'multiplexer_client.dart';

main() {
  group('multiplexer', () {
    var mplex;
    MultiplexerTest client;
    setUp(() {
      mplex = new Multiplexer(
          new ImmediateRequestHandler(), cache: new AsyncMapCache());
      client = new MultiplexerTest(mplex);
    });

    test('handles a basic get', () {
      client.foos.get(1).send().listen(expectAsync1((v) {
        expect(v.id, equals(1));
        expect(v.streamy.source, equals('RPC'));
      }, count: 1));
    });
    test('handles a cached get', () {
      // Issue the first RPC just to get stuff in cache.
      client.foos.get(2).send().first.then(expectAsync1((v) {
        var expects = [(v1) {
          expect(v1.id, equals(2));
          expect(v1.streamy.source, equals('CACHE'));
        }, (v2) {
          expect(v2.id, equals(2));
          expect(v2.streamy.source, equals('RPC'));
        }].iterator;
          client.foos.get(2).send().listen(expectAsync1(
            (v) => (expects..moveNext()).current(v), count: 2));
      }, count: 1));
    });
    test('handles dual streams', () {
      var v1ts = null;
      var expects = [(v1) {
        expect(v1.id, equals(3));
        expect(v1.streamy.source, equals('RPC'));
        v1ts = v1.streamy.ts;

        // Issue a second RPC after the first one returns.
        client.foos.get(3).send();
        // Results of this second RPC are tested in 'cached get' above.
      }, (v2) {
        expect(v2.id, equals(3));
        expect(v2.streamy.source, equals('RPC'));
        expect(v2.streamy.ts, greaterThanOrEqualTo(v1ts));
      }].iterator;

      // First RPC
      client.foos.get(3).send().listen(expectAsync1(
        (v) => (expects..moveNext()).current(v), count: 2));
    });
    test('handles a basic non-cachable request', () {
      var foo = new Foo()
        ..id = 1
        ..bar = 'foo';
      client.foos.update(foo).send().single.then(expectAsync1((v) {
        expect(v, isNot(same(foo)));
        expect(v.id, equals(1));
        expect(v.bar, equals("foo.updated.1"));
      }));
    });
    test('handles two simultaneous identical non-cachable requests', () {
      var foo = new Foo()
        ..id = 2
        ..bar = 'foo';
      Future<Foo> first = client.foos.update(foo).send().single;
      Future<Foo> second = client.foos.update(foo).send().single;
      Future.wait([first, second]).then(expectAsync1((results) {
        expect(results[0].bar, anyOf(equals('foo.updated.1'), equals('foo.updated.2')));
        expect(results[1].bar, anyOf(equals('foo.updated.1'), equals('foo.updated.2')));
        expect(results[0].bar != results[1].bar, isTrue);
      }));
    });
    test('handles a no-response method', () {
      client.foos.delete(1).send().single.then(expectAsync1((response) {
        expect(response, new isInstanceOf<EmptyEntity>());
      }));
    });
    test('handles a request cancellation', () {
      var sub = client.foos.cancel(1).send().listen((_) {
        fail("Request should have been canceled.");
      });
      sub.cancel();
    });
  });
}

class ImmediateRequestHandler extends RequestHandler {
  var _id = 1;
  Stream<Foo> handle(Request request) {
    if (request is FoosGetRequest) {
      return new Future.value(new Foo()
        ..id = request.parameters['id']
        ..bar = (_id++).toString()).asStream();
    } else if (request is FoosUpdateRequest) {
      return new Future.value(new Foo()
        ..id = request.parameters['id']
        ..bar = '${request.payload['bar']}.updated.${_id++}').asStream();
    } else if (request is FoosDeleteRequest) {
      return new Future.value(request.responseDeserializer("")).asStream();
    } else if (request is FoosCancelRequest) {
      var c;
      c = new StreamController<Foo>(onCancel: expectAsync0(() {
        expect(c.isClosed, isFalse);
      }));
      c.add(new Foo()..id = 1);
      return c.stream;
    }
  }
}
