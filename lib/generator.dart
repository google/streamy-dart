part of apigen;

/// Turns the first letter in a string to a capital letter.
String capitalize(String str) {
  if (str == null || str.length == 0) {
    return str;
  }
  return str[0].toUpperCase() + str.substring(1);
}

/// Provides templates for the generator.
abstract class TemplateProvider {
  /// A string embedded in the generated client code to tell people what
  /// templates were used to generate the client. Usually, this is a file
  /// path to the templates.
  String get sourceOfTemplates;
  /// Returns the text of a template given template name.
  String operator[](String templateName);
}

/// Stateful but reusable code generator.
class Generator {
  mus.Template _clientHeaderTmpl;
  mus.Template _rootTmpl;
  mus.Template _objectTmpl;
  mus.Template _resourceTmpl;
  mus.Template _requestTmpl;

  final TemplateProvider _templateProvider;
  StringBuffer _out;
  String _topLevelClassName;

  Generator(this._templateProvider) {
    this._clientHeaderTmpl = _loadTemplate("client_header");
    this._rootTmpl = _loadTemplate("root");
    this._objectTmpl = _loadTemplate("object");
    this._resourceTmpl = _loadTemplate("resource");
    this._requestTmpl = _loadTemplate("request");
  }

  mus.Template _loadTemplate(String templateName) {
    return mus.parse(_templateProvider[templateName]);
  }

  /// Generates API client code and returns it as a string.
  String generate(String libName, Discovery discovery, {Map addendumData: const {}}) {
    this._out = new StringBuffer();
    this._topLevelClassName = capitalize(discovery.name);

    var types = [];
    discovery.schemas.forEach((String name, TypeDescriptor schema) {
      if (schema.kind != null) {
        types.add({
          "name": name,
          "kind": schema.kind,
        });
      }
    });

    _render(_clientHeaderTmpl, {
      "types": types,
      "topLevelClassName": _topLevelClassName,
      "api_library": libName,
      "source_of_templates": _templateProvider.sourceOfTemplates,
    });

    discovery.schemas.forEach((String name, TypeDescriptor type) {
      processType(name, type);
    });

    var sendParams = [];
    if (addendumData.containsKey("sendParams")) {
      addendumData["sendParams"].forEach((key, value) {
        value["name"] = key;
        value["last"] = false;
        if (value["type"] == "String") {
          value["default"] = "\"${value["default"]}\"";
        }
        sendParams.add(value);
      });
      sendParams[sendParams.length - 1]["last"] = true;
    }

    List<Map> resourceFields = new List.from(
        discovery.resources.map((Resource resource) {
          return processResource(resource, sendParams);
        }));

    _render(_rootTmpl, {
      "topLevelClassName": _topLevelClassName,
      "resources": resourceFields,
      "servicePath": discovery.servicePath
    });
    return _out.toString();
  }

  _render(mus.Template template, Map data) {
    String code = template.renderString(data, htmlEscapeValues: false);
    List<String> lines = code.split("\n");
    StringBuffer clean = new StringBuffer();
    String previousLine = "";
    for (String line in lines) {
      String trim = line.trim();
      bool isClassDeclaration = trim.startsWith("class") ||
          trim.startsWith("abstract class");
      bool isComment = trim.startsWith("///");
      if (trim.length > 0) {
        bool previousLineIsComment = previousLine.trim().startsWith("///");
        if (isClassDeclaration || isComment) {
          if (!previousLineIsComment) {
            clean.writeln();
          }
        }
        clean.writeln(line);
      }
      previousLine = line;
    }
    _out.write(clean.toString());
  }

  Map processResource(Resource resource, Map sendParams) {
    // TODO(yjbanov): support sub-resources
    List<Map> methods = [];
    resource.methods.forEach((Method method) {
      MethodInfo methodInfo = processMethod(resource, method, sendParams);
      var methodData = {
        "name": method.name,
        "reqType": methodInfo.requestTypeName,
        "payload": methodInfo.payloadData,
      };
      methods.add(methodData);
    });
    var resourceData = {
      "topLevelClassName": _topLevelClassName,
      "type": "${capitalize(resource.name)}Resource",
      "name": resource.name,
      "capName": capitalize(resource.name),
      "methods": methods,
    };
    _render(_resourceTmpl, resourceData);
    return resourceData;
  }

  MethodInfo processMethod(Resource resource, Method method, List sendParams) {
    MethodInfo methodInfo = new MethodInfo(this, resource, method);
    List<Map> parameters = [];
    List<Map> pathParameters = [];
    List<Map> queryParameters = [];
    method.parameters.forEach((String paramName, Parameter param) {
      TypeDescriptor paramType = param.type;
      var paramVarName = paramName.replaceAll("\.", "_");
      String paramTypeName =
          processType("${method.name}_${paramVarName}", paramType).typeName;
      if (param.repeated) {
        paramTypeName = "ComparableList<$paramTypeName>";
      }
      parameters.add({
        "type": paramTypeName,
        "name": paramName,
        "varName": paramVarName,
        "repeated": param.repeated,
        "capVarName": capitalize(paramVarName),
      });
      switch(param.location) {
        case LOCATION_PATH: pathParameters.add({"name": paramName}); break;
        case LOCATION_QUERY: queryParameters.add({"name": paramName}); break;
        default: throw new ApigenException("Unsupported parameter location");
      }
    });

    var requestData = {
      "name": methodInfo.requestTypeName,
      "parameters": parameters,
      "payload": methodInfo.payloadData,
      "topLevelClassName": _topLevelClassName,
      "httpMethod": method.httpMethod.name,
      "path": method.path,
      "path_parameters": pathParameters,
      "query_parameters": queryParameters,
      "hasResponse": [],
      "sendOptionalParams": {},
      "sendParams": sendParams,
      "hasSendParams": sendParams.isNotEmpty
    };

    if (methodInfo.hasResponse) {
      requestData["hasResponse"] = [{
        "responseType":
          processType(methodInfo.responseTypeName, method.response).typeName,
      }];
    }

    // Render the request object type
    _render(_requestTmpl, requestData);
    return methodInfo;
  }

  /// Renders any object definitions declared by the type and returns the Dart
  /// name of the type.
  ProcessTypeResult processType(String name, TypeDescriptor type) {
    switch(type.type) {
      case ANY_TYPE:
      case BOOLEAN_TYPE:
      case INTEGER_TYPE:
      case NUMBER_TYPE:
      case NULL_TYPE:
      case STRING_TYPE:
        return new ProcessTypeResult.basic(type.type.dartType, type.format);
      case REF_TYPE:
        // TODO: is ref == class name?
        return new ProcessTypeResult.object(type.ref);
      case ARRAY_TYPE:
        ProcessTypeResult elemTypeResult = processType(name, type.items);
        return new ProcessTypeResult.list(elemTypeResult);
      case OBJECT_TYPE:
        return new ProcessTypeResult.object(processObjectType(name, type));
    }
    throw new ApigenException("Unsupported type ${type.type}");
  }

  String processObjectType(String name, TypeDescriptor type) {
    var properties = <Map>[];
    type.properties.forEach((String propertyName, TypeDescriptor propertyType) {
      String capName = capitalize(propertyName);
      ProcessTypeResult proctr =
          processType("${name}_${capName}", propertyType);
      var propertyData = {
        "type": proctr.typeName,
        "name": propertyName,
        "capName": capName,
        "mustSerialize": [],
        "hasParseExpr": [],
        "list": [],
      };
      if (proctr.parseExpr != null) {
        propertyData["hasParseExpr"] = ["true"];
        propertyData["parseExpr"] = proctr.parseExpr;
      }
      if (!proctr.isBasic) {
        propertyData["mustSerialize"] = ["true"];
      }
      if (proctr.isList) {
        propertyData["list"] = ["true"];
        propertyData["listType"] = proctr.elemTypeName;
      }
      properties.add(propertyData);
    });

    // TODO(yjbanov): support additionalProperties

    _render(_objectTmpl, {
      "name": name,
      "properties": properties,
    });

    return name;
  }
}

class ProcessTypeResult {
  String typeName;
  bool isBasic;
  bool isList;
  String elemTypeName;
  String parseExpr;

  ProcessTypeResult._private(
      this.typeName,
      this.isBasic,
      this.isList,
      this.elemTypeName,
      this.parseExpr);

  factory ProcessTypeResult.basic(String typeName, String format) {
    String parseExpr;
    switch (format) {
      case "int64":
        typeName = "int";
        parseExpr = "int.parse";
        break;
      case "double":
        typeName = "double";
        parseExpr = "double.parse";
        break;
      default:
        // Do nothing.
    }
    return new ProcessTypeResult._private(
        typeName, true, false, null, parseExpr);
  }

  factory ProcessTypeResult.object(String typeName) {
    return new ProcessTypeResult._private(typeName, false, false, null, null);
  }

  factory ProcessTypeResult.list(ProcessTypeResult elemTypeResult) {
    bool isBasic = elemTypeResult.isBasic;
    String elemTypeName = elemTypeResult.typeName;
    String typeName = "List<${elemTypeName}>";
    return new ProcessTypeResult._private(
        typeName, isBasic, true, elemTypeName, elemTypeResult.parseExpr);
  }
}

class MethodInfo {
  String requestTypeName;
  bool hasResponse;
  String responseTypeName;
  bool hasPayload;
  String payloadTypeName = null;

  MethodInfo(Generator gen, Resource resource, Method method) {
    var typeNamePrefix =
        "${capitalize(resource.name)}${capitalize(method.name)}";
    this.hasPayload = method.request != null;
    if (hasPayload) {
      this.payloadTypeName = gen.processType(
          "${typeNamePrefix}Payload",
          method.request).typeName;
    }

    this.requestTypeName = "${typeNamePrefix}Request";

    this.hasResponse = method.response != null;
    if (hasResponse) {
      this.responseTypeName = "${typeNamePrefix}Response";
    }
  }

  List<Map> get payloadData {
    if (hasPayload) {
      return [{
        "payloadType": payloadTypeName,
      }];
    }
    return [];
  }
}
