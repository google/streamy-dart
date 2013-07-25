library streamy.generated.method_params.test;

import 'dart:json';
import 'package:unittest/unittest.dart';
import 'method_params_client.dart';

main() {
  group('MethodParamsTest', () {
    var req;
    setUp(() {
      req = new FoosGetRequest(null)
        ..barId = 'abc'
        ..fooId = 123;
    });
    test('All non-repeated parameters populated', () {
      req
        ..param1 = true
        ..param2 = false;
      expect(req.path, equals('foos/abc/123?param1=true&param2=false'));
    });
    test('Missing query parameter', () {
      req.param1 = true;
      expect(req.path, equals('foos/abc/123?param1=true'));
    });
    test('No query parameter', () {
      expect(req.path, equals('foos/abc/123'));
    });
    test('Repeated parameter type is list', () {
      expect(req.param3, new isInstanceOf<List>());
    });
    test('Repeated parameters', () {
      req
        ..param1 = true
        ..param3.addAll(['foo', 'bar']);
      expect(req.path, equals(
          'foos/abc/123?param1=true&param3=foo&param3=bar'));
    });
  });
  group('Request object tests', () {
    var r1;
    var r2;
    setUp(() {
      r1 = new FoosGetRequest(null)
        ..param3.addAll(['foo', 'bar']);
      r2 = new FoosGetRequest(null)
        ..param3.addAll(['foo', 'bar']);
    });
    test('Repeated parameters are comparable', () {
      expect(r1 == r2, isTrue);
    });
    test('Cloned requests are equal', () {
      expect(r1.clone(), equals(r1));
    });
    test('Cloned repeated parameters are not identical', () {
      expect(identical(r1.param3, r1.clone().param3), isFalse);
    });
    test('Named parameters get copied into the request object', () {
      var req = new MethodParamsTest(null)
          .foos
          .get("a", 2, param1: false, param2: true, param3: ["b", "c"]);
      expect(req.barId, equals("a"));
      expect(req.fooId, equals(2));
      expect(req.param1, isFalse);
      expect(req.param2, isTrue);
      expect(req.param3, equals(["b", "c"]));
    });
    test('Not specifying a named parameter does not add null to the request object.', () {
      var req = new MethodParamsTest(null)
          .foos
          .get("a", 2, param1: false);
      expect(req.parameters.containsKey('param2'), isFalse);
      expect(req.parameters.containsKey('param3'), isTrue);
    });
  });
}
