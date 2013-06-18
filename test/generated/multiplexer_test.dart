import "dart:async";
import "dart:json";
import "package:third_party/dart/streamy/lib/base.dart";
import "package:third_party/dart/streamy/lib/cache.dart";
import "package:third_party/dart/streamy/lib/multiplexer.dart";
import "package:third_party/dart/streamy/test/generated/multiplexer_client.dart";
import "package:third_party/dart/unittest/lib/unittest.dart";

main() {
  group("basic multiplexer tests", () {
    var mplex;
    MultiplexerTest client;
    setUp(() {
      mplex = new Multiplexer(
          new ImmediateRequestHandler(), new AsyncMapCache());
      client = new MultiplexerTest(mplex);
    });

    test("basic get", () {
      (client.foos.get()
        ..fooId = 1).send().listen(expectAsync1((v) {
          expect(v.id, equals(1));
          expect(v.streamy.source, equals("RPC"));
        }, count: 1));
    });
    test("cached get", () {
      // Issue the first RPC just to get stuff in cache.
      (client.foos.get()
        ..fooId = 2).send().first.then(expectAsync1((v) {
          var expects = [(v1) {
            expect(v1.id, equals(2));
            expect(v1.streamy.source, equals("CACHE"));
          }, (v2) {
            expect(v2.id, equals(2));
            expect(v2.streamy.source, equals("RPC"));
          }].iterator;

          (client.foos.get()
            ..fooId = 2).send().listen(expectAsync1(
                (v) => (expects..moveNext()).current(v), count: 2));
        }, count: 1));
    });
    test("dual streams", () {
      var v1ts = null;
      var expects = [(v1) {
        expect(v1.id, equals(3));
        expect(v1.streamy.source, equals("RPC"));
        v1ts = v1.streamy.ts;

        // Issue a second RPC after the first one returns.
        (client.foos.get()
            ..fooId = 3).send();
        // Results of this second RPC are tested in "cached get" above.
      }, (v2) {
        expect(v2.id, equals(3));
        expect(v2.streamy.source, equals("RPC"));
        expect(v2.streamy.ts, greaterThanOrEqualTo(v1ts));
      }].iterator;

      // First RPC
      (client.foos.get()
          ..fooId = 3).send().listen(expectAsync1(
              (v) => (expects..moveNext()).current(v), count: 2));
    });
  });
}

class ImmediateRequestHandler implements RequestHandler {
  var _id = 1;
  Stream<Foo> handle(Request request) => new Future.value(new Foo()
      ..id = request.parameters['fooId']
      ..bar = (_id++).toString()).asStream();
}
