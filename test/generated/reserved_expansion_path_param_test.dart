library streamy.generated.reserved_expansion_path_param.test;

import 'package:unittest/unittest.dart';
import 'reserved_expansion_path_param_client_requests.dart';

main() {
  group('ReservedExpansionPathParamTest', () {
    test('Reserved Expansion path parameter may contain a slash', () {
      var req = new FoosGetRequest(null)
        ..barId = 'abc'
        ..fooId = 'def/ghi';
      expect(req.path, equals('foos/abc/def/ghi'));
    });
    test('Reserved Expansion path parameter does require a slash', () {
      var req = new FoosGetRequest(null)
        ..barId = 'abc'
        ..fooId = 'def';
      expect(req.path, equals('foos/abc/def'));
    });
  });
}
