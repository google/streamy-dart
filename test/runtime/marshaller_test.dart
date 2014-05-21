library runtime_marshaller_test;

import 'dart:convert';
import 'package:unittest/unittest.dart';
import '../../generated/bank_api_client_objects.dart';
import '../../generated/bank_api_client_dispatch.dart';

main() {
  group('Marshaller', () {
    final marshaller = new Marshaller();
    Branch entity;
    setUp(() {
      entity = new Branch();
    });
    test('should serialize nulls as JSON nulls', () {
      entity.name = null;
      expect(JSON.encode(marshaller.marshalBranch(entity)), '{"name":null}');
    });
    test('.local does not affect serialization of the entity', () {
      var s1 = JSON.encode(marshaller.marshalBranch(entity));
      entity.local['foo'] = 'not serialized';
      var s2 = JSON.encode(marshaller.marshalBranch(entity));
      expect(s2, equals(s1));
    });
  });
}
