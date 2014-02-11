library runtime_entity_wrapper_test;

import 'dart:convert';

import 'package:unittest/unittest.dart';
import '../../generated/bank_api_client_objects.dart';

main() {
  group('EntityWrapper', () {
    test('should serialize nulls as JSON nulls', () {
      var e = new Branch();
      e.name = null;
      expect(JSON.encode(e), '{"name":null}');
    });
  });
}
