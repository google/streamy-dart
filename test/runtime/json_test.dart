library streamy.runtime.json.test;

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
}
