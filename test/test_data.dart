library streamy.test_data;

const SAMPLE_DISCOVERY =
"""
{
  "name": "DocsTest",
  "description": "API definitions.\\nWith documentation",
  "servicePath": "docsTest/v1/",
  "schemas": {
    "Foo": {
      "id": "Foo",
      "type": "object",
      "description": "This is a foo.\\nEnough said.",
      "properties": {
        "id": {
          "type": "integer",
          "description": "Primary key.\\nSometimes called ID."
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
          "description": "Gets a foo.\\nReturns 404 on bad ID.",
          "parameters": {
            "fooId": {
              "type": "integer",
              "description": "Primary key of foo.\\nSecond line",
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
""";
