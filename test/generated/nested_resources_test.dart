library streamy.generated.nested_resources.test;

import 'dart:async';
import 'package:unittest/unittest.dart';
import 'package:streamy/streamy.dart';
import 'nested_resources_client.dart';
import 'nested_resources_client_requests.dart';
import 'nested_resources_client_resources.dart';
import 'nested_resources_client_objects.dart';
import 'nested_resources_client_dispatch.dart';

main() {
  group('NestedResourcesTest', () {
    test('Generates top-level resources', () {
      var subject = new NestedResourcesTest(null);
      expect(subject.foos.runtimeType, equals(FoosResource));
    });
    test('Generates second-level resources', () {
      var subject = new NestedResourcesTest(null);
      expect(subject.foos.bars.runtimeType, equals(FoosBarsResource));
    });
    test('Generates third-level resources', () {
      var subject = new NestedResourcesTest(null);
      expect(subject.foos.bars.bazes.runtimeType, equals(FoosBarsBazesResource));
    });
    test('Generates methods for top-level resources', () {
      var subject = new NestedResourcesTest(null);
      expect(subject.foos.get(1).httpMethod, equals('GET'));
    });
    test('Generates methods for second-level resources', () {
      var subject = new NestedResourcesTest(null);
      expect(subject.foos.bars.get(1, 2).httpMethod, equals('GET'));
    });
    test('Generates methods for third-level resources', () {
      var subject = new NestedResourcesTest(null);
      expect(subject.foos.bars.bazes.get(1, 2, 3).httpMethod, equals('GET'));
    });
  });
}
