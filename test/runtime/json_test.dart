library streamy.runtime.json.test;

import 'package:fixnum/fixnum.dart';
import 'package:streamy/streamy.dart';
import 'package:unittest/unittest.dart';

main() {
  group('json', () {
    test('should send trace events', () {
      final trace = new LoggingTrace();
      jsonParse('{}', trace);
      expect(trace.log, hasLength(2));
      expect(trace.log[0].runtimeType, JsonParseStartEvent);
      expect(trace.log[1].runtimeType, JsonParseEndEvent);
    });
  });

  group('jsonMarshal', () {
    test('should toString Int64s', () {
      expect(jsonMarshal({'foo': new Int64(1)}), {'foo': '1'});
    });
    test('should not toString nums', () {
      expect(jsonMarshal({'i': 1, 'd': 1.0}), {'i': 1, 'd': 1.0});
    });
  });
}
