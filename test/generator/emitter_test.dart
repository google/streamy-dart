library streamy.generator.emitter.test;

import 'package:streamy/generator.dart';
import 'package:unittest/unittest.dart';
import '../project.dart';

main() {
  var discovery = new Discovery.fromJsonString(
"""
{
  "name": "DocsTest",
  "description": "API definitions with documentation",
  "servicePath": "docsTest/v1/",
  "schemas": {
    "Foo": {
      "id": "Foo",
      "type": "object",
      "description": "This is a foo.",
      "properties": {
        "id": {
          "type": "integer",
          "description": "Primary key."
        }
      }
    }
  },
  "resources": {
    "foos": {
      "methods": {
        "get": {
          "id": "service.foos.get",
          "path": "foos/{fooId}",
          "name": "",
          "response": {
            "\$ref": "Foo"
          },
          "httpMethod": "GET",
          "description": "Gets a foo",
          "parameters": {
            "fooId": {
              "type": "integer",
              "description": "Primary key of foo",
              "required": true,
              "location": "path"
            }
          },
          "parameterOrder": ["fooId"]
        }
      }
    }
  }
}
""");
  var clientCode = new Emitter(new DefaultTemplateProvider(
      "$projectRootDir/templates")).generate("docstestapi", discovery);
  group('Emitter', () {
    test('should emit docs for root class', () {
      expectContains(clientCode,
          '/// API definitions with documentation\n' +
          'class DocsTest ');
    });
    test('should emit docs for resource methods', () {
      expectContains(clientCode,
          '  /// Gets a foo\n' +
          '  FoosGetRequest get(');
    });
    test('should emit docs for request class', () {
      expectContains(clientCode,
          '/// Gets a foo\n' +
          'class FoosGetRequest ');
    });
    test('should emit docs for request parameter', () {
      expectContains(clientCode,
          '  /// Primary key of foo\n' +
          '  int get fooId =>');
    });
    test('should emit docs for schema class', () {
      expectContains(clientCode,
          '/// This is a foo.\n'
          'class Foo ');
    });
    test('should emit docs for schema property', () {
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
