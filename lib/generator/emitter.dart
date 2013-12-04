part of streamy.generator;

void emitCode(EmitterConfig config) {
  new _Emitter(config).generate();
}

/// Configuration for the [Emitter].
abstract class EmitterConfig {
  Discovery get discovery;
  /// Provides code templates.
  TemplateProvider get templateProvider;
  StringSink get rootCodeSink;
  StringSink get resourceCodeSink;
  StringSink get requestCodeSink;
  StringSink get objectCodeSink;
  Map get addendumData;

  factory EmitterConfig(
      Discovery discovery,
      TemplateProvider templateProvider,
      StringSink rootCodeSink,
      StringSink resourceCodeSink,
      StringSink requestCodeSink,
      StringSink objectCodeSink,
      {Map addendumData: const {}}) =>
          new _DefaultEmitterConfig(
              discovery,
              templateProvider,
              rootCodeSink,
              resourceCodeSink,
              requestCodeSink,
              objectCodeSink,
              addendumData);
}

class _DefaultEmitterConfig implements EmitterConfig {
  final Discovery discovery;
  final TemplateProvider templateProvider;
  final StringSink rootCodeSink;
  final StringSink resourceCodeSink;
  final StringSink requestCodeSink;
  final StringSink objectCodeSink;
  final Map addendumData;

  _DefaultEmitterConfig(
      this.discovery,
      this.templateProvider,
      this.rootCodeSink,
      this.resourceCodeSink,
      this.requestCodeSink,
      this.objectCodeSink,
      this.addendumData);
}

/// Provides templates for the generator.
abstract class TemplateProvider {
  /// Returns the text of a template given template name.
  String operator[](String templateName);
}

class _Emitter {
  _InternalTemplate _clientHeader;
  _InternalTemplate _root;
  _InternalTemplate _object;
  _InternalTemplate _objectFileHeader;
  _InternalTemplate _resource;
  _InternalTemplate _resourceFileHeader;
  _InternalTemplate _request;
  _InternalTemplate _requestFileHeader;

  final EmitterConfig _conf;
  String _discoveryName;
  String _topLevelClassName;
  String _libName;
  String _codeInfoString;
  List _sendParams;

  _Emitter(this._conf) {
    _InternalTemplate _tmpl(String codeTemplateName, StringSink codeSink) =>
        new _InternalTemplate(
            mus.parse(_conf.templateProvider[codeTemplateName]), codeSink);

    _clientHeader = _tmpl('client_header', _conf.rootCodeSink);
    _root = _tmpl('root', _conf.rootCodeSink);
    _object = _tmpl('object', _conf.objectCodeSink);
    _objectFileHeader = _tmpl('object_file_header', _conf.objectCodeSink);
    _resource = _tmpl('resource', _conf.resourceCodeSink);
    _resourceFileHeader = _tmpl('resource_file_header', _conf.resourceCodeSink);
    _request = _tmpl('request', _conf.requestCodeSink);
    _requestFileHeader = _tmpl('request_file_header', _conf.requestCodeSink);

    _discoveryName = _capitalize(_conf.discovery.name);
    _topLevelClassName = _makeClassName(_discoveryName);
    if (_conf.addendumData.containsKey('topLevelClassName')) {
      _topLevelClassName = _conf.addendumData['topLevelClassName'];
    }

    _libName = _conf.addendumData.containsKey('lib_name')
        ? _conf.addendumData['lib_name']
        : _topLevelClassName.toLowerCase();

    _codeInfoString = _conf.addendumData['code_info_string'];

    _sendParams = [];
    if (_conf.addendumData.containsKey('sendParams')) {
      _conf.addendumData['sendParams'].forEach((key, value) {
        value['name'] = key;
        value['last'] = false;
        if (value['type'] == 'String') {
          value['default'] = '\'${value['default']}\'';
        }
        _sendParams.add(value);
      });
      _sendParams[_sendParams.length - 1]['last'] = true;
    }
  }

  /// Generates API client code and returns it as a string.
  void generate() {
    getImport(name) => _addendum.containsKey('${name}_import')
        ? _addendum['${name}_import']
        : '${_libName}_${name}.dart';

    var headerData = {
      'api_library': _libName,
      'code_info_string': _codeInfoString,
      'resources_package': getImport('resources'),
      'requests_package': getImport('requests'),
      'objects_package': getImport('objects'),
    };

    _clientHeader.render(headerData);
    _resourceFileHeader.render(headerData);
    _requestFileHeader.render(headerData);
    _objectFileHeader.render(headerData);

    _conf.discovery.schemas.forEach((String id, TypeDescriptor type) {
      processType(id, type);
    });

    List<Map> resourceFields = new List.from(
        _conf.discovery.resources.map((Resource resource) {
          return processResource(resource);
        }));

    _root.render({
      'discoveryName': _discoveryName,
      'topLevelClassName': _topLevelClassName,
      'resources': resourceFields,
      'servicePath': _conf.discovery.servicePath,
      'docs': _docLines(_conf.discovery.description),
    });
  }

  Map get _addendum => _conf.addendumData;

  Map processResource(Resource resource) {
    // TODO(yjbanov): support sub-resources
    List<Map> methods = [];
    resource.methods.forEach((Method method) {
      MethodInfo methodInfo = processMethod(resource, method);
      var methodData = {
        'name': methodInfo.apiName,
        'reqType': methodInfo.requestTypeName,
        'payload': methodInfo.payloadData,
        'parameters': methodInfo.parameters,
        'hasPathParameters': methodInfo.pathParameters.isNotEmpty,
        'pathParameters': methodInfo.pathParameters,
        'hasPathParametersOrPayload': methodInfo.pathParameters.isNotEmpty || methodInfo.payloadData.isNotEmpty,
        // TODO(arick): Remove "&& false" once dart2js no longer crashes with lots of named parameters.
        'hasQueryParameters': methodInfo.queryParameters.isNotEmpty && false,
        'queryParameters': methodInfo.queryParameters,
        'docs': _docLines(method.description),
        'patch': method.httpMethod == HTTP_PATCH
      };
      methods.add(methodData);
    });
    var resourceClassName = _makeClassName('${resource.name}Resource');
    var resourceData = {
      'name': _makePropertyName(resource.name),
      'type': resourceClassName,
      'methods': methods,
    };
    _resource.render(resourceData);
    return resourceData;
  }

  MethodInfo processMethod(Resource resource, Method method) {
    MethodInfo methodInfo = new MethodInfo(this, resource, method);

    var requestData = {
      'name': methodInfo.requestTypeName,
      'parameters': methodInfo.parameters,
      'payload': methodInfo.payloadData,
      'topLevelClassName': _topLevelClassName,
      'httpMethod': method.httpMethod.name,
      'path': method.path,
      'path_parameters': methodInfo.pathParameters,
      'query_parameters': methodInfo.queryParameters,
      'hasResponse': [],
      'sendParams': _sendParams,
      'hasSendParams': _sendParams.isNotEmpty,
      'docs': _docLines(method.description),
      'patchable': method.name == 'update'
    };

    if (methodInfo.hasResponse) {
      requestData['hasResponse'] = [{
        'responseType':
          processType(methodInfo.responseTypeName, method.response).typeName,
      }];
    }

    // Render the request object type
    _request.render(requestData);
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
        return new ProcessTypeResult.object(
            _makeClassName(type.ref));
      case ARRAY_TYPE:
        ProcessTypeResult elemTypeResult = processType(name, type.items);
        return new ProcessTypeResult.list(elemTypeResult);
      case OBJECT_TYPE:
        var className = _makeClassName(name);
        processObjectType(className, type);
        return new ProcessTypeResult.object(className);
    }
    throw new ApigenException('Unsupported type ${type.type}');
  }

  void processObjectType(String className, TypeDescriptor type) {
    var properties = <Map>[];
    type.properties.forEach((String propertyName, TypeDescriptor propertyType) {
      String fieldName = _makePropertyName(propertyName);
      String removerName = _makeRemoverName(fieldName);
      String classNameSuffix = _makeClassName(propertyName);
      ProcessTypeResult proctr =
          processType('${className}_${classNameSuffix}', propertyType);
      var propertyData = {
        'type': proctr.typeName,
        'raw_name': propertyName,
        'field_name': fieldName,
        'remover_name': removerName,
        'mustSerialize': [],
        'hasParseExpr': [],
        'hasToJsonExpr': [],
        'list': [],
        'docs': _docLines(propertyType.description),
      };
      if (proctr.parseExpr != null) {
        propertyData['hasParseExpr'] = ['true'];
        propertyData['parseExpr'] = proctr.parseExpr;
      }
      if (proctr.isList) {
        propertyData['list'] = ['true'];
      }
      if (proctr.toJsonExpr != null) {
        propertyData['hasToJsonExpr'] = ['true'];
        propertyData['toJsonExpr'] = proctr.toJsonExpr;
      }
      properties.add(propertyData);
    });

    // TODO(yjbanov): support additionalProperties

    _object.render({
      'name': className,
      'properties': properties,
      'docs': _docLines(type.description),
      'hasKind': type.kind != null,
      'kind': type.kind,
    });
  }

  String _makePropertyName(String name) {
    name = _fixIllegalChars(name);
    if (_ILLEGAL_PROPERTY_NAMES.contains(name)) {
      name = '\$${name}';
    }
    return name;
  }

  String _makeMethodName(String name) {
    name = _fixIllegalChars(name);
    if (_ILLEGAL_METHOD_NAMES.contains(name)) {
      name = '\$${name}';
    }
    return name;
  }

  String _makeRemoverName(String name) {
    name = _capitalize(_fixIllegalChars(name));
    return 'remove${name}';
  }

  String _makeClassName(String name) {
    name = _capitalize(_fixIllegalChars(name));
    if (_ILLEGAL_CLASS_NAMES.contains(name)) {
      name = '\$${name}';
    }
    return name;
  }

  String _fixIllegalChars(String name) {
    if (name.length == 0) {
      throw new StateError('Empty property, schema, resource or method name');
    }

    // Replace bad starting character with dollar sign (it has to be public)
    if(!name.startsWith(IDENTIFIER_START)) {
      name = '\$${name.substring(1)}';
    };

    // Replace bad characters in the middle with underscore
    name = name.replaceAll(NON_IDENTIFIER_CHAR_MATCHER, '_');
    if (name.startsWith('_')) {
      name = 'clean${name}';
    }return name;
  }
}

class ProcessTypeResult {
  final String typeName;
  final String parseExpr;
  final String toJsonExpr;
  final bool isList;

  ProcessTypeResult._private(
      this.typeName,
      this.parseExpr,
      this.toJsonExpr,
      {this.isList: false});

  factory ProcessTypeResult.basic(String typeName, String format) {
    String parseExpr;
    String toJsonExpr;
    switch (format) {
      case 'int64':
        if (typeName == 'String') {
          parseExpr = 'streamy.atoi64';
          toJsonExpr = 'streamy.str';
        } else if (typeName == 'num') {
          parseExpr = 'streamy.itoi64';
          toJsonExpr = 'streamy.str';
        }
        typeName = 'fixnum.Int64';
        break;
      case 'double':
        if (typeName == 'String') {
          parseExpr = 'streamy.atod';
          toJsonExpr = 'streamy.str';
        }
        typeName = 'double';
        break;
      default:
        // Do nothing.
    }
    return new ProcessTypeResult._private(typeName, parseExpr, toJsonExpr);
  }

  factory ProcessTypeResult.object(String className) {
    String parseExpr = '''((v) => new ${className}.fromJson(v))''';
    return new ProcessTypeResult._private(className, parseExpr, null);
  }

  factory ProcessTypeResult.list(ProcessTypeResult elemTypeResult) {
    String elemParseExpr = elemTypeResult.parseExpr;
    String elemToJsonExpr = elemTypeResult.toJsonExpr;
    String elemTypeName = elemTypeResult.typeName;
    String typeName = 'List<${elemTypeName}>';
    String parseExpr = null;
    if (elemParseExpr != null) {
      parseExpr = 'streamy.mapInline(${elemParseExpr})';
    }
    String toJsonExpr = null;
    if (elemToJsonExpr != null) {
      toJsonExpr = 'streamy.mapCopy(${elemToJsonExpr})';
    }
    return new ProcessTypeResult._private(typeName, parseExpr, toJsonExpr,
        isList: true);
  }
}

class MethodInfo {
  String apiName;
  String requestTypeName;
  bool hasResponse;
  String responseTypeName;
  bool hasPayload;
  String payloadTypeName = null;

  List<Map> parameters = [];
  List<Map> pathParameters = [];
  List<Map> queryParameters = [];

  MethodInfo(_Emitter gen, Resource resource, Method method) {
    this.apiName = gen._makeMethodName(method.name);
    var typeNamePrefix =
        '${_capitalize(resource.name)}${_capitalize(method.name)}';
    this.hasPayload = method.request != null;
    if (hasPayload) {
      this.payloadTypeName = gen.processType(
          gen._makeClassName('${typeNamePrefix}Payload'),
          method.request).typeName;
    }

    this.requestTypeName = gen._makeClassName('${typeNamePrefix}Request');

    this.hasResponse = method.response != null;
    if (hasResponse) {
      this.responseTypeName = '${typeNamePrefix}Response';
    }

    method.parameters.forEach((String paramName, Parameter param) {
      TypeDescriptor paramType = param.type;
      var paramVarName = gen._makePropertyName(paramName);
      String paramTypeName =
          gen.processType('${method.name}_${paramVarName}', paramType).typeName;
      var paramArgTypeName = paramTypeName;
      if (param.repeated) {
        paramArgTypeName = 'List<$paramTypeName>';
        paramTypeName = 'List<$paramTypeName>';
      }
      var parameter = {
        'type': paramTypeName,
        'argType': paramArgTypeName,
        'name': paramName,
        'varName': paramVarName,
        'repeated': param.repeated,
        'removerName': gen._makeRemoverName(paramVarName),
        'docs': _docLines(paramType.description),
        'last': false,
      };
      parameters.add(parameter);
      switch(param.location) {
        case LOCATION_PATH: pathParameters.add(new Map.from(parameter)); break;
        case LOCATION_QUERY: queryParameters.add(new Map.from(parameter)); break;
        default: throw new ApigenException('Unsupported parameter location');
      }
    });

    if (parameters.isNotEmpty) {
      parameters.last['last'] = true;
    }
    if (pathParameters.isNotEmpty) {
      pathParameters.last['last'] = true;
    }
    if (queryParameters.isNotEmpty) {
      queryParameters.last['last'] = true;
    }
  }

  List<Map> get payloadData {
    if (hasPayload) {
      return [{
        'payloadType': payloadTypeName,
      }];
    }
    return [];
  }
}

/// Turns the first letter in a string to a capital letter.
String _capitalize(String str) {
  if (str == null || str.length == 0) {
    return str;
  }
  return str[0].toUpperCase() + str.substring(1);
}

/// Breaks up a [String] into list of lines.
List<String> _docLines(String s) =>
    s != null ? s.split('\n') : <String>[];

/// Characters allowed as starting identifier characters. Note the absence of
/// underscore. This is because generated identifiers have to be public.
final IDENTIFIER_START = new RegExp(r'[a-zA-Z\$]');
final NON_IDENTIFIER_CHAR_MATCHER = new RegExp(r'[^a-zA-Z\d\$_]');

/// Disallowed property names.
const _ILLEGAL_PROPERTY_NAMES = const [
  // Streamy reserved symbols
  'parameters',
  'global',
  'clone',
  'patch',
  'isFrozen',
  'containsKey',
  'fieldNames',
  'remove',
  'toJson',
  'local',
  'streamyType',
  'changes',
  'deliverChanges',
  'notifyChange',
  'notifyPropertyChange',
  'hasObservers',
  'apiType',

  // Dart keywords
  'continue',
  'extends',
  'throw',
  'default',
  'rethrow',
  'true',
  'assert',
  'do',
  'false',
  'in',
  'return',
  'try',
  'break',
  'final',
  'is',
  'case',
  'else',
  'finally',
  'var',
  'catch',
  'enum',
  'for',
  'new',
  'super',
  'void',
  'class',
  'null',
  'switch',
  'while',
  'const',
  'if',
  'this',
  'with',
];

/// Disallowed method names.
const _ILLEGAL_METHOD_NAMES = const [
  'abstract',
  'continue',
  'extends',
  'throw',
  'default',
  'factory',
  'rethrow',
  'true',
  'assert',
  'do',
  'false',
  'in',
  'return',
  'try',
  'break',
  'final',
  'is',
  'case',
  'else',
  'finally',
  'static',
  'var',
  'catch',
  'enum',
  'for',
  'new',
  'super',
  'void',
  'class',
  'null',
  'switch',
  'while',
  'const',
  'external',
  'if',
  'this',
  'with',
];

/// Disallowed class names (e.g. they are from dart:core).
const _ILLEGAL_CLASS_NAMES = const [
  'BidirectionalIterator',
  'Comparable',
  'Comparator',
  'DateTime',
  'Deprecated',
  'Duration',
  'Expando',
  'Function',
  'Invocation',
  'Iterable',
  'Iterator',
  'List',
  'Map',
  'Match',
  'Null',
  'Object',
  'Pattern',
  'RegExp',
  'RuneIterator',
  'Runes',
  'Set',
  'StackTrace',
  'Stopwatch',
  'String',
  'StringBuffer',
  'StringSink',
  'Symbol',
  'Type',
  'Uri',
  'AbstractClassInstantiationError',
  'ArgumentError',
  'AssertionError',
  'CastError',
  'ConcurrentModificationError',
  'CyclicInitializationError',
  'Error',
  'Exception',
  'FallThroughError',
  'FormatException',
  'IntegerDivisionByZeroException',
  'NoSuchMethodError',
  'NullThrownError',
  'OutOfMemoryError',
  'RangeError',
  'StackOverflowError',
  'StateError',
  'TypeError',
  'UnimplementedError',
  'UnsupportedError',
];

class _InternalTemplate {
  final mus.Template _template;
  final StringSink _codeSink;

  _InternalTemplate(this._template, this._codeSink);

  render(Map data) {
    String code = _template.renderString(data, htmlEscapeValues: false);
    List<String> lines = code.split('\n');
    StringBuffer clean = new StringBuffer();
    String previousLine = '';
    for (String line in lines) {
      String trim = line.trim();
      bool isClassDeclaration = trim.startsWith('class') ||
          trim.startsWith('abstract class');
      bool isComment = trim.startsWith('///');
      if (trim.length > 0) {
        bool previousLineIsComment = previousLine.trim().startsWith('///');
        if (isClassDeclaration || isComment) {
          if (!previousLineIsComment) {
            clean.writeln();
          }
        }
        clean.writeln(line);
      }
      previousLine = line;
    }
    _codeSink.write(clean.toString());
  }
}
