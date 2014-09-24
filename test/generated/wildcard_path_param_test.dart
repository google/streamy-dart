library streamy.generated.wildcard_path_param.test;

import 'package:unittest/unittest.dart';
import 'wildcard_path_param_client_requests.dart';

main() {
  group('WildcardPathParamTest', () {
    test('Wildcard path parameter contains a slash', () {
      var req = new FoosGetRequest(null)
        ..barId = 'abc'
        ..fooId = 'def/ghi';
      expect(req.path, equals('foos/abc/def/ghi'));
    });
    test('Wildcard path parameter does not contain a slash', () {
      var req = new FoosGetRequest(null)
        ..barId = 'abc'
        ..fooId = 'def';
      expect(req.path, equals('foos/abc/def'));
    });
  });
}
