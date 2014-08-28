library streamy.generated.identifier_name.test;

import 'dart:async';
import 'package:unittest/unittest.dart';
import 'package:streamy/streamy.dart';
import 'identifier_name_client.dart';
import '../utils.dart';

main() {
  group('Identifier name', () {
    IdentifierNameTest root;

    setUp(() {
      root = new IdentifierNameTest(null);
    });

    test('for root class', () {
      expectType(IdentifierNameTest);
    });
    test('for resources mixin', () {
      expectType(IdentifierNameTestResourcesMixin);
    });
    test('for transaction', () {
      expectType(IdentifierNameTestTransaction);
    });
    test('for schema object', () {
      expectType(Foo);
    });
    test('for property', () {
      var foo = new Foo()..bar = 3;
      expect(foo.bar, 3);
    });
    test('for method get', () {
      root.foos.get(1);
    });
    test('for request class for method get', () {
      expectType(FoosGetRequest);
      var req = root.foos.get(1);
      expect(req, new isAssignableTo<FoosGetRequest>());
    });
    test('for method list', () {
      root.foos.list();
    });
    test('for request class for method list', () {
      expectType(FoosListRequest);
      var req = root.foos.list();
      expect(req, new isAssignableTo<FoosListRequest>());
    });
    test('for query parameter', () {
      root.foos.list()
        ..bar = 234;
    });
  });
}

expectType(Type type) {
  expect(type, isType);
}
