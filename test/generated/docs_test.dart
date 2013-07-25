library streamy.generated.docs.test;

import 'dart:async';
import 'dart:collection';
import 'dart:json';
import 'dart:io' as io;
import 'package:unittest/unittest.dart';
import 'package:streamy/streamy.dart';
import 'docs_client.dart';

main() {
  var clientFile = new io.File('test/generated/docs_client.dart');
  String clientCode = clientFile.readAsStringSync();
  group('DocsTest', () {
    test('should contain docs for root class', () {
      expectContains(clientCode,
          '/// API definitions with documentation\n' +
          'class DocsTest ');
    });
    test('should contain docs for resource methods', () {
      expectContains(clientCode,
          '  /// Gets a foo\n' +
          '  FoosGetRequest get(');
    });
    test('should contain docs for request class', () {
      expectContains(clientCode,
          '/// Gets a foo\n' +
          'class FoosGetRequest ');
    });
    test('should contain docs for request parameter', () {
      expectContains(clientCode,
          '  /// Primary key of foo\n' +
          '  int get fooId =>');
    });
    test('should contain docs for schema class', () {
      expectContains(clientCode,
          '/// This is a foo.\n'
          'class Foo ');
    });
    test('should contain docs for schema property', () {
      expectContains(clientCode,
          '  /// Primary key.\n'
          '  int get id => ');
    });
  });
}

void expectContains(String container, String containee) {
  expect(container.contains(containee), isTrue,
      reason: "'$container' does not contain '$containee'");
}
