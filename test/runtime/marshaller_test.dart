library runtime_marshaller_test;

import 'dart:convert';
import 'package:unittest/unittest.dart';
import '../generated/proto_client.dart';

main() {
  group('Marshaller', () {
    final marshaller = new Marshaller();
    Foo entity;
    setUp(() {
      entity = new Foo();
    });
    test('should serialize nulls as JSON nulls', () {
      entity.name = null;
      expect(JSON.encode(marshaller.marshalFoo(entity)),
          '{"2":null}');
    });
    test('.local does not affect serialization of the entity', () {
      var s1 = JSON.encode(marshaller.marshalFoo(entity));
      entity.local['foo'] = 'not serialized';
      var s2 = JSON.encode(marshaller.marshalFoo(entity));
      expect(s2, equals(s1));
    });
  });
}
