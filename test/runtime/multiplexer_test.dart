library runtime_multiplexer_test;

import 'dart:async';
import 'package:streamy/streamy.dart';
import 'package:streamy/testing/testing.dart';
import 'package:unittest/unittest.dart';

main() {
  group('Multiplexer', () {
    test('does not throw on error but forward to error catchers', () {
      var testHandler = (
          testRequestHandler()
            ..proxyError("Not found", 404)
        ).build();
      var subject = new Multiplexer(testHandler);
      subject.handle(TEST_GET_REQUEST).first.catchError(expectAsync1((err) {
        expect(err, new isInstanceOf<ProxyException>());
      }));
    });
  });
}
