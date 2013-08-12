library streamy.runtime.branching.test;

import 'dart:async';
import 'package:streamy/streamy.dart';
import 'package:streamy/testing/testing.dart';
import 'package:unittest/unittest.dart';



main() {
  group('BranchingRequestHandler', () {
    var defaultHandler;
    var testHandler;
    var testHandler2; 
    setUp(() {
      defaultHandler = (
          testRequestHandler()
            ..value(new RawEntity()..['value'] = 'hello')
        ).build();
      testHandler = (
          testRequestHandler()
            ..value(new RawEntity()..['value'] = 'world')
        ).build();
      testHandler2 = (
          testRequestHandler()
            ..value(new RawEntity()..['value'] = 'universe')
        ).build();
    });
    test('Properly branches on one type of request.', () {
      var brancher = (new BranchingRequestHandlerBuilder()
          ..addBranch(TypedTestRequest, testHandler)
        ).build(defaultHandler);
        brancher.handle(TEST_GET_REQUEST).single.then(expectAsync1((e) {
          expect(e['value'], equals('hello'));
        }));
        brancher.handle(new TypedTestRequest(true)).single.then(expectAsync1((e) {
          expect(e['value'], equals('world'));
        }));
    });
    test('Predicate works to disable branch.', () {
      var brancher = (new BranchingRequestHandlerBuilder()
          ..addBranch(TypedTestRequest, testHandler, predicate: (_) => false)
        ).build(defaultHandler);
        brancher.handle(new TypedTestRequest(true)).single.then(expectAsync1((e) {
          expect(e['value'], equals('hello'));
        }));
    });
    test('Multiple branches of same type, with different predicates.', () {
      var brancher = (new BranchingRequestHandlerBuilder()
          ..addBranch(TypedTestRequest, testHandler, predicate: (r) => r.option)
          ..addBranch(TypedTestRequest, testHandler2, predicate: (r) => !r.option)
        ).build(defaultHandler);
        brancher.handle(new TypedTestRequest(true)).single.then(expectAsync1((e) {
          expect(e['value'], equals('world'));
        }));
        brancher.handle(new TypedTestRequest(false)).single.then(expectAsync1((e) {
          expect(e['value'], equals('universe'));
        }));
        brancher.handle(TEST_GET_REQUEST).single.then(expectAsync1((e) {
          expect(e['value'], equals('hello'));
        }));
    });
    test('Multiple branches of different types.', () {
      var brancher = (new BranchingRequestHandlerBuilder()
          ..addBranch(TypedTestRequest, testHandler)
          ..addBranch(DifferentlyTypedTestRequest, testHandler2)
        ).build(defaultHandler);
        brancher.handle(new TypedTestRequest(true)).single.then(expectAsync1((e) {
          expect(e['value'], equals('world'));
        }));
        brancher.handle(new DifferentlyTypedTestRequest()).single.then(expectAsync1((e) {
          expect(e['value'], equals('universe'));
        }));
        brancher.handle(TEST_GET_REQUEST).single.then(expectAsync1((e) {
          expect(e['value'], equals('hello'));
        }));
    });
  });
}

class TypedTestRequest extends TestRequest {
  final bool option;
  
  TypedTestRequest(this.option) : super("GET");
}

class DifferentlyTypedTestRequest extends TestRequest {
  DifferentlyTypedTestRequest() : super("GET");
}
