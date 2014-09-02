library base_test;

import 'dart:convert';
import 'package:streamy/streamy.dart';
import 'package:unittest/unittest.dart';
import 'package:observe/observe.dart';
import 'generated/bank_api_client_objects.dart';

main() {
  group('base.Entity', () {
    Branch entity;
    setUp(() {
      entity = new Branch();
    });
    test('.wrapMap constructor does not copy data', () {
      var map = toObservable({'list': [1, 2, 3]});
      var e = new Branch.wrap(map);
      map['list'].add(4);
      expect(e['list'].length, equals(4));
      expect(e['list'][3], equals(4));
    });
    test('does allow setting closures on .local', () {
      var e = new Branch();
      e['local.foo'] = () => true;
    });
    test('exists and is a Map', () {
      expect(entity.local, isNotNull);
      expect(entity.local, new isInstanceOf<Map>());
    });
    test('stores and retrieves data via operator[]', () {
      entity.local['foo'] = 'bar';
      expect(entity.local['foo'], equals('bar'));
    });
    test('does not survive cloning', () {
      entity.local['foo'] = 'this should not be cloned';
      expect(entity.clone().local['foo'], isNull);
    });
    test('local cannot be set', () {
      expect(() => entity['local'] = {},
      throwsA(new isInstanceOf<ArgumentError>()));
    });
  });
}
