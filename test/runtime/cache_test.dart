library streamy.runtime.cache.test;

import 'dart:async';
import 'package:streamy/streamy.dart';
import 'package:streamy/testing/testing.dart';
import 'package:unittest/unittest.dart';

main() {
  group('CachingRequestHandler', () {
    var handler;
    setUp(() {
      var delegate = (testRequestHandler()
          ..value(new Response(new RawEntity()..['value'] = 'hello', Source.RPC, 0))
          ..value(new Response(new RawEntity()..['value'] = 'world', Source.RPC, 0)))
          .build();
      handler = new CachingRequestHandler(delegate, new AsyncMapCache());
    });
    test('handles a basic get', () {
      handler.handle(TEST_GET_REQUEST, const NoopTrace()).single.then(expectAsync1((v) {
        expect(v.source, Source.RPC);
        expect(v.entity['value'], 'hello');
      }));
    });
    test('handles a cached get', () {
      // First request stages.
      handler.handle(TEST_GET_REQUEST, const NoopTrace()).single.then(expectAsync1((_) {
        handler.handle(TEST_GET_REQUEST, const NoopTrace()).toList().then(expectAsync1((list) {
          expect(list[0].source, Source.CACHE);
          expect(list[0].entity['value'], 'hello');
          expect(list[1].source, Source.RPC);
          expect(list[1].entity['value'], 'world');
        }));
      }));
    });
    test('handles a non-cachable request', () {
      handler.handle(TEST_DELETE_REQUEST, const NoopTrace()).single.then(expectAsync1((_) {
        handler.handle(TEST_DELETE_REQUEST, const NoopTrace()).single.then(expectAsync1((v) {
          expect(v.source, Source.RPC);
        }));
      }));
    });
  });
}