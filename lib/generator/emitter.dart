library streamy.generator.emitter;

import 'dart:async';
import 'package:mustache/mustache.dart' as mustache;
import 'package:streamy/generator/config.dart';
import 'package:streamy/generator/dart.dart';
import 'package:streamy/generator/discovery/json_marshaller.dart';
import 'package:streamy/generator/emitter_util.dart';
import 'package:streamy/generator/generator.dart';
import 'package:streamy/generator/ir.dart';
import 'package:streamy/generator/protobuf/protobuf_marshaller.dart';
import 'package:streamy/generator/util.dart';

class StreamyClient {
  final Config config;
  final DartFile root;
  final DartFile resources;
  final DartFile requests;
  final DartFile objects;
  final DartFile dispatch;
  
  StreamyClient(this.config, this.root, this.resources, this.requests,
      this.objects, this.dispatch);
}

class SchemaDefinition {
  final DartClass clazz;
  final DartTypedef globalDef;
  final Set<String> dependencies;
  
  SchemaDefinition(this.clazz, this.globalDef, this.dependencies);
}

class Emitter {
  final Config config;
  final Map<String, mustache.Template> _templates;

  Emitter(this.config, this._templates);

  StreamyClient process(Api api) {
    return new _EmitterContext(config, _templates, api).process();
  }
}

class _EmitterContext extends EmitterBase implements EmitterContext {

  final Config config;
  final Map<String, mustache.Template> templates;
  final Api api;

  MarshallerEmitter _marshallerEmitter;
  String _libPrefix;
  StreamyClient _client;
  DartLibrary _rootFile;
  String _rootPrefix;
  DartFile _resourceFile;
  String _resourcePrefix;
  DartFile _requestFile;
  String _requestPrefix;
  DartFile _objectFile;
  String _objectPrefix;
  DartFile _dispatchFile;
  String _dispatchPrefix;
  DartClass _requestBaseClass;

  String get libPrefix => _libPrefix;
  StreamyClient get client => _client;
  DartLibrary get rootFile => _rootFile;
  String get rootPrefix => _rootPrefix;
  DartFile get resourceFile => _resourceFile;
  String get resourcePrefix => _resourcePrefix;
  DartFile get requestFile => _requestFile;
  String get requestPrefix => _requestPrefix;
  DartFile get objectFile => _objectFile;
  String get objectPrefix => _objectPrefix;
  DartFile get dispatchFile => _dispatchFile;
  String get dispatchPrefix => _dispatchPrefix;

  _EmitterContext(this.config, this.templates, this.api,
      {MarshallerEmitter marshallerEmitter}) {
    _libPrefix = api.name;
    if (api.httpConfig != null) {
      _libPrefix = "$_libPrefix";
    }
    _rootFile = new DartLibrary(_libPrefix)
      ..imports['package:streamy/streamy.dart'] = 'streamy'
      ..imports['package:fixnum/fixnum.dart'] = 'fixnum'
      ..imports[config.baseImport] = BASE_PREFIX
      ..imports['dart:async'] = null;
    var out = [rootFile];
    switch (config.splitLevel) {
      case SPLIT_LEVEL_NONE:
        _resourceFile = rootFile;
        _requestFile = rootFile;
        _objectFile = rootFile;
        _dispatchFile = rootFile;
        _client = new StreamyClient(config, rootFile, null, null, null, null);
        break;
      case SPLIT_LEVEL_PARTS:
        _resourceFile = new DartLibraryPart(rootFile.libraryName,
        '${config.outputPrefix}_resources.dart');
        _requestFile = new DartLibraryPart(rootFile.libraryName,
        '${config.outputPrefix}_requests.dart');
        _objectFile = new DartLibraryPart(rootFile.libraryName,
        '${config.outputPrefix}_objects.dart');
        _dispatchFile = new DartLibraryPart(rootFile.libraryName,
        '${config.outputPrefix}_dispatch.dart');
        rootFile.parts.addAll([resourceFile, requestFile, objectFile, dispatchFile]);
        out.addAll([resourceFile, requestFile, objectFile, dispatchFile]);
        _client = new StreamyClient(config, rootFile, resourceFile, requestFile, objectFile, dispatchFile);
        break;
      case SPLIT_LEVEL_LIBS:
        _resourceFile = new DartLibrary('$libPrefix.resources');
        _requestFile = new DartLibrary('$libPrefix.requests');
        _objectFile = new DartLibrary('$libPrefix.objects');
        _dispatchFile = new DartLibrary('$libPrefix.dispatch');
        _resourcePrefix = 'resources';
        _requestPrefix = 'requests';
        _objectPrefix = 'objects';
        _dispatchPrefix = 'dispatch';
        rootFile.imports
          ..[importPath('resources.dart')] = 'resources'
          ..[importPath('dispatch.dart')] = 'dispatch';
        _resourceFile.imports
          ..['package:streamy/streamy.dart'] = 'streamy'
          ..['package:fixnum/fixnum.dart'] = 'fixnum'
          ..[config.baseImport] = BASE_PREFIX
          ..[importPath('requests.dart')] = 'requests'
          ..[importPath('objects.dart')] = 'objects';
        _requestFile.imports
          ..['package:streamy/streamy.dart'] = 'streamy'
          ..['package:fixnum/fixnum.dart'] = 'fixnum'
          ..[config.baseImport] = BASE_PREFIX
          ..[importPath('objects.dart')] = 'objects'
          ..[importPath('dispatch.dart')] = 'dispatch'
          ..['dart:async'] = null;
        _objectFile.imports
          ..['package:streamy/streamy.dart'] = 'streamy'
          ..['package:fixnum/fixnum.dart'] = 'fixnum'
          ..[config.baseImport] = BASE_PREFIX;
        _dispatchFile.imports
          ..['package:streamy/streamy.dart'] = 'streamy'
          ..['package:fixnum/fixnum.dart'] = 'fixnum'
          ..[config.baseImport] = BASE_PREFIX
          ..[importPath('objects.dart')] = 'objects';
        out.addAll([resourceFile, requestFile, objectFile, dispatchFile]);
        _resourceFile.imports.addAll(api.imports);
        _requestFile.imports.addAll(api.imports);
        _objectFile.imports.addAll(api.imports);
        _dispatchFile.imports.addAll(api.imports);
        _client = new StreamyClient(config, rootFile, resourceFile, requestFile, objectFile, dispatchFile);
        break;
    }

    rootFile.imports.addAll(api.imports);

    if (config.generateMarshallers) {
      if (marshallerEmitter != null) {
        _marshallerEmitter = marshallerEmitter;
      } else if (config.proto != null) {
        _marshallerEmitter = new ProtobufMarshallerEmitter(this);
      } else {
        _marshallerEmitter = new JsonMarshallerEmitter(this);
      }
    }
  }

  void _addDepImports(DartFile file, List<String> imports) {
    var knownImports = {};
    imports.forEach((prefix) {
      knownImports[api.dependencies[prefix]] = prefix;
    });
    file.imports.addAll(knownImports);
  }

  StreamyClient process() {
    // Root class
    if (config.generateApi) {
      rootFile.classes.addAll(processRoot());
      resourceFile.classes.addAll(processResources());
      processRequests();
    }
    var schemas = processSchemas();
    var deps = schemas.expand((schema) => schema.dependencies).toSet();
    objectFile.classes.addAll(schemas.map((schema) => schema.clazz));
    objectFile.typedefs.addAll(schemas.map((schema) => schema.globalDef)
        .where((v) => v != null));
    objectFile.classes.addAll(processEnums());
    _addDepImports(objectFile, _maybeSortDeps(deps));
    if (config.generateMarshallers) {
      _marshallerEmitter.emit();
    }
    return client;
  }
  
  Iterable<String> _maybeSortDeps(Set<String> deps) {
    if (config.proto != null) {
      return config.proto.orderImported(deps);
    }
    return deps;
  }
  
  List<DartClass> processRoot() {
    // Create the resource mixin class.
    var resourceMixin = new DartClass('${makeClassName(api.name)}ResourcesMixin');
    if (api.description != null) {
      resourceMixin.comments.addAll(splitStringAcrossLines(api.description));
    }
    
    // Implement backing fields and lazy getters for each resource type.
    api.resources.forEach((name, resource) =>
        _addLazyGetter(resourceMixin, name, resource));
    
    var baseType = streamyImport('Root');
    if (api.httpConfig != null) {
      baseType = streamyImport('HttpRoot');
    }
    final marshallerType = new DartType('Marshaller', dispatchPrefix, const []);
    var mixinType = new DartType.from(resourceMixin);
    var txClassName = makeClassName('${api.name}Transaction');
    var root = new DartClass(makeClassName(api.name), baseClass: baseType)
      ..mixins.add(mixinType)
      ..fields.add(new DartSimpleField('marshaller', marshallerType, isFinal: true))
      ..fields.add(new DartSimpleField('requestHandler', streamyImport('RequestHandler'), isFinal: true))
      ..fields.add(new DartSimpleField('txStrategy', streamyImport('TransactionStrategy'), isFinal: true))
      ..fields.add(new DartSimpleField('tracer', streamyImport('Tracer'), isFinal: true))
      ..methods.add(new DartMethod(
        'beginTransaction',
        new DartType(txClassName, null, const []),
        new DartTemplateBody(_template('root_begin_transaction'), {'txClassName': txClassName})));

    var ctorData = {
      'http': api.httpConfig != null
    };
    var ctor = new DartConstructor(root.name, body: new DartTemplateBody(
      _template('root_constructor'), ctorData))
      ..parameters.add(new DartParameter('requestHandler',
          streamyImport('RequestHandler'), isDirectAssignment: true))
      ..namedParameters.add(new DartNamedParameter('txStrategy',
          streamyImport('TransactionStrategy'),
          isDirectAssignment: true))
      ..namedParameters.add(new DartNamedParameter('tracer', streamyImport('Tracer'),
          isDirectAssignment: true,
          defaultValue: new DartConstantBody('const streamy.NoopTracer()')))
      ..namedParameters.add(new DartNamedParameter('marshaller', marshallerType,
          isDirectAssignment: true,
          defaultValue: new DartConstantBody('const ${marshallerType}()')));
    if (api.httpConfig != null) {
      ctor.namedParameters.add(new DartNamedParameter('servicePath',
          const DartType.string(),
          defaultValue: new DartConstantBody("r'${api.httpConfig.servicePath}'")));
    }
    root.methods.add(ctor);
    
    var send = new DartMethod('send', new DartType('Stream', null, const []),
      new DartTemplateBody(_template('root_send'), {})
    )
      ..parameters.add(new DartParameter('request', streamyImport('Request')));
    root.methods.add(send);
    
    addApiType(root);

    var txRoot = new DartClass(
        txClassName,
        baseClass: streamyImport('HttpTransactionRoot'))
      ..fields.add(new DartSimpleField('marshaller', marshallerType, isFinal: true))
      ..mixins.add(mixinType);

    var txnCtor = new DartConstructor(txRoot.name, body: new DartTemplateBody(
      _template('root_transaction_constructor'), {}));
    txnCtor.parameters
      ..add(new DartParameter('txn', streamyImport('Transaction')))
      ..add(new DartParameter('servicePath', const DartType.string()))
      ..add(new DartParameter('marshaller', marshallerType,
          isDirectAssignment: true));
    txRoot.methods.add(txnCtor);

    addApiType(txRoot);

    return [resourceMixin, root, txRoot];
  }

  List<DartClass> processResources() =>
    api
      .resources
      .values
      .expand(_expandResources)
      .map((resource) => processResource(resource))
      .toList(growable: false);
  
  DartClass processResource(Resource resource) {
    var clazz = new DartClass('${makeClassName(resource.name)}Resource');
    var requestMethodTemplate = _template('request_method');
    
    // Set up a _root field for the implementation RequestHandler, and a
    // constructor that sets it.
    var rootType = streamyImport('Root');
    clazz.fields.add(new DartSimpleField('_root', rootType, isFinal: true));
    var ctor = new DartConstructor(clazz.name);
    ctor.parameters.add(new DartParameter('_root', rootType, isDirectAssignment: true));
    clazz.methods.add(ctor);
    
    
    if (config.known) {
      clazz.fields.add(new DartSimpleField('KNOWN_METHODS',
          new DartType.list(const DartType.string()),
          isFinal: true, isStatic: true,
          initializer: stringListBody(resource.methods.values.map((m) => m.name))));
    }
    
    resource.methods.forEach((_, method) {
      var plist = [];
      var pnames = [];
      var payloadType;
      
      // Resource methods get a Request object. Either they're built using
      // request URL parameters, or the payload object.
      if (method.payloadType != null) {
        payloadType = toDartType(method.payloadType);
        plist.add(new DartParameter('payload', payloadType));
      } else {
        method.httpPath.parameters().forEach((param) {
          if (!method.parameters.containsKey(param)) {
            return;
          }
          var pRecord = method.parameters[param];
          var pType = toDartType(pRecord.typeRef);
          plist.add(new DartParameter(param, pType));
          pnames.add(param);
        });
      }
      
      var requestType = new DartType(
          makeClassName(joinParts([resource.name, method.name, 'Request'])),
          requestPrefix, const []);
      
      var m = new DartMethod(makeMethodName(method.name), requestType,
          new DartTemplateBody(requestMethodTemplate, {
            'requestType': requestType,
            'parameters': pnames
              .map((name) => {'name': name})
              .toList(growable: false),
            'hasPayload': payloadType != null
          }));
      m.parameters.addAll(plist);
      clazz.methods.add(m);
    });
    
    resource.subresources.forEach((name, resource) =>
        _addLazyGetter(clazz, name, resource, withPrefix: false));
    
    addApiType(clazz);
    return clazz;
  }
  
  String importPath(String file) {
    return config.importPrefix + config.outputPrefix + '_' + file;
  }
  
  List<DartClass> processRequests() {
    _generateRequestBase();

    api.resources.values
        .expand(_expandResources)
        .expand((resource) => resource
        .methods
        .values
        .map((method) => processRequest(makeClassName(resource.name),
            method, objectPrefix, dispatchPrefix)))
        .forEach(requestFile.classes.add);
  }

  _generateRequestBase() {
    final payloadType = new DartType('P');
    final responseType = new DartType('R');

    _requestBaseClass = new DartClass(
        '${makeClassName(api.name)}RequestBase',
        baseClass: streamyImport('HttpRequestBase'),
        typeParameters: [payloadType, responseType],
        isAbstract: true);

    final noPayloadCtor = new DartConstructor(_requestBaseClass.name,
        named: 'noPayload', body: new DartConstantBody('''
      : super.noPayload(root, httpMethod, pathFormat, apiType, pathParameters, queryParameters);'''))
      ..addParameter('root', streamyImport('Root'))
      ..addParameter('httpMethod', DartType.STRING)
      ..addParameter('pathFormat', DartType.STRING)
      ..addParameter('apiType', DartType.STRING)
      ..addParameter('pathParameters', new DartType.list(DartType.STRING))
      ..addParameter('queryParameters', new DartType.list(DartType.STRING))
    ;
    _requestBaseClass.methods.add(noPayloadCtor);

    final withPayloadCtor = new DartConstructor(_requestBaseClass.name,
        named: 'withPayload', body: new DartConstantBody('''
      : super.withPayload(root, httpMethod, pathFormat, apiType, pathParameters, queryParameters, payload);'''))
      ..addParameter('root', streamyImport('Root'))
      ..addParameter('httpMethod', DartType.STRING)
      ..addParameter('pathFormat', DartType.STRING)
      ..addParameter('apiType', DartType.STRING)
      ..addParameter('pathParameters', new DartType.list(DartType.STRING))
      ..addParameter('queryParameters', new DartType.list(DartType.STRING))
      ..addParameter('payload', payloadType)
    ;
    _requestBaseClass.methods.add(withPayloadCtor);

    // Set up send() methods.
    var sendParams = config.sendParams.map((p) {
      var type = toDartType(p.typeRef);
      var defaultValue;
      if (p.defaultValue != null) {
        if (p.defaultValue is String) {
          defaultValue = new DartConstantBody("r'${p.defaultValue}'");
        } else {
          defaultValue = new DartConstantBody(p.defaultValue.toString());
        }
      }
      return new DartNamedParameter(p.name, type, defaultValue: defaultValue);
    }).toList();

    var sendDirectTemplate = _template('request_send_direct');
    var sendTemplate = _template('request_send');

    // Add _sendDirect.
    var rawType = new DartType.stream(
        streamyImport('Response', params: [responseType]));
    _requestBaseClass.methods.add(new DartMethod('_sendDirect', rawType,
    new DartTemplateBody(sendDirectTemplate, {})));

    // Add send().
    var sendParamNames = sendParams
        .map((p) => {'name': p.name})
        .toList(growable: false);

    var send = new DartMethod('send', new DartType.stream(responseType),
      new DartTemplateBody(sendTemplate, {
        'sendParams': sendParamNames,
        'listen': false,
        'raw': false,
      }))
      ..namedParameters.addAll(sendParams);
    _requestBaseClass.methods.add(send);

    // Add sendRaw().
    var sendRaw = new DartMethod('sendRaw', rawType, new DartTemplateBody(
      sendTemplate, {
        'sendParams': sendParamNames,
        'listen': false,
        'raw': true
      }
    ))
      ..namedParameters.addAll(sendParams);
    _requestBaseClass.methods.add(sendRaw);

    var listenType = new DartType('StreamSubscription', null, [responseType]);
    var listen = new DartMethod('listen', listenType, new DartTemplateBody(
      sendTemplate, {
        'sendParams': sendParamNames,
        'listen': true,
        'raw': false
      }
    ))
      ..parameters.add(new DartParameter('onData', const DartType('Function')))
      ..namedParameters.addAll(sendParams);
    _requestBaseClass.methods.add(listen);

    requestFile.classes.add(_requestBaseClass);
  }

  DartClass processRequest(String resourceClassName, Method method,
      String objectPrefix, String dispatchPrefix) {
    var paramGetter = _template('request_param_getter');
    var paramSetter = _template('request_param_setter');
    var requestClassName = makeClassName(
        joinParts([resourceClassName, method.name, 'Request']));
    var clazz = new DartClass(
        requestClassName,
        baseClass: new DartType(_requestBaseClass.name));

    // Determine payload type.
    var payloadType;
    if (method.payloadType != null) {
      payloadType = toDartType(method.payloadType);
    }
    
    var listParams = method
      .parameters
      .values
      .where((param) => param.typeRef is ListTypeRef)
      .map((param) => {
        'name': param.name,
        'type': toDartType(param.typeRef.subType),
      })
      .toList(growable: false);

    clazz.fields.add(new DartSimpleField('API_TYPE', const DartType.string(),
        initializer: new DartConstantBody("r'${clazz.name}'"),
        isStatic: true, isFinal: true));

    Iterable<Map> extractParams(bool predicate(Field)) =>
        method.parameters.values.where(predicate)
            .map((p) => { 'name': p.name });

    // Set up a _root field for the implementation RequestHandler, and a
    // constructor that sets it.
    var rootType = streamyImport('Root');
    var ctor = new DartConstructor(clazz.name, body: new DartTemplateBody(
      _template('request_ctor'), {
        'superConstructor':
            payloadType != null ? '.withPayload' : '.noPayload',
        'httpMethod': method.httpMethod,
        'pathFormat': method.httpPath,
        'pathParameters': extractParams((p) => p.location == 'path'),
        'queryParameters': extractParams((p) => p.location != 'path'),
        'hasPayload': payloadType != null,
        'hasListParams': listParams.isNotEmpty,
        'listParams': listParams
    }))
      ..parameters.add(new DartParameter('root', rootType));
    if (payloadType != null) {
        ctor.parameters.add(new DartParameter('payload', payloadType));
    }
    clazz.methods.add(ctor);
    
    if (config.known) {
      clazz.fields.add(new DartSimpleField('KNOWN_PARAMETERS',
          new DartType.list(const DartType.string()),
          isStatic: true, isFinal: true,
          initializer: stringListBody(
              method.parameters.values.map((p) => p.name))));
    }
    
    // Set up fields for all the preferences.
    method.parameters.forEach((name, param) {
      var type = toDartType(param.typeRef);
      clazz.fields.add(
          new DartComplexField(makePropertyName(name), type,
              new DartTemplateBody(paramGetter, {'name': name}),
              new DartTemplateBody(paramSetter, {'name': name})));
      clazz.methods.add(new DartMethod(makeRemoverName(name), type,
          new DartTemplateBody(_template('request_remove'), {'name': name})));
    });

    var clone = new DartMethod('clone',
    new DartType(_requestBaseClass.name, null, const []),
    new DartTemplateBody(_template('request_clone'), {
        'type': clazz.name,
        'hasPayload': payloadType != null
    }));
    clazz.methods.add(clone);

    if (config.generateMarshallers) {
      _marshallerEmitter.decorateRequestClass(method, clazz);
    }

    return clazz;
  }

  List<SchemaDefinition> processSchemas() => api
    .types
    .values
    .map(processSchema)
    .toList(growable: false);

  SchemaDefinition processSchema(Schema schema) {
    var base = new DartType(config.baseClass, BASE_PREFIX, const []);
    var clazz = new DartClass(makeClassName(schema.name), baseClass: base);
    clazz.mixins.addAll(
        schema.mixins.map((mixin) => toDartType(mixin, withPrefix: false)));

    var globalFnDef = null;

    var ctor = _template('object_ctor');
    var getter = _template('object_getter');
    var setter = _template('object_setter');
    var remove = _template('object_remove');

    clazz.methods.add(new DartConstructor(clazz.name, body: new DartTemplateBody(
      ctor, {
        'mapBacked': config.mapBackedFields,
        'wrap': false,
        'basePrefix': BASE_PREFIX,
      })));
      
    if (config.mapBackedFields) {
      clazz.methods.add(new DartConstructor(clazz.name, named: 'wrap',
        body: new DartTemplateBody(ctor, {
          'mapBacked': true,
          'wrap': true,
          'basePrefix': BASE_PREFIX,
        }))
        ..parameters.add(new DartParameter('map', new DartType.map(const DartType.string(), const DartType.dynamic()))));
    }

    if (config.known) {
      clazz.fields.add(new DartSimpleField('KNOWN_PROPERTIES',
          new DartType.list(const DartType.string()),
          isFinal: true, isStatic: true,
          initializer: stringListBody(schema.properties.values.map((m) => m.name))));
    }

    if (config.global) {
      globalFnDef = new DartTypedef('${clazz.name}GlobalFn', const DartType.dynamic())
        ..parameters.add(new DartParameter('entity', new DartType.from(clazz)));
      clazz.methods.add(new DartMethod('addGlobal', const DartType.none(), new DartTemplateBody(
        _template('object_add_global'), {'type': clazz.name}), isStatic: true)
        ..parameters.add(new DartParameter('name', const DartType.string()))
        ..parameters.add(new DartParameter('computeFn', new DartType.from(globalFnDef)))
        ..namedParameters.add(new DartNamedParameter('memoize', const DartType.boolean(), defaultValue: new DartConstantBody('false')))
        ..namedParameters.add(new DartNamedParameter('dependencies', new DartType('List', null, const []))));
    }

    schema.properties.forEach((_, field) {
      // Add getter and setter, delegating to map access.
      var name = makePropertyName(field.name);
      var type = toDartType(field.typeRef, withPrefix: false);
      if (config.mapBackedFields) {
        var f = new DartComplexField(name, type,
            new DartTemplateBody(getter, {'name': field.name}),
            new DartTemplateBody(setter, {'name': field.name}));
        clazz.fields.add(f);
        if (config.removers) {
          var r = new DartMethod(makeRemoverName(field.name), type,
              new DartTemplateBody(remove, {'name': field.name}));
        clazz.methods.add(r);
        }
      } else {
        var f = new DartSimpleField(name, type);
        clazz.fields.add(f);
      }
    });

    var schemaType = new DartType.from(clazz);
    if (config.clone) {
      clazz.methods.add(new DartMethod('clone', schemaType,
          new DartTemplateBody(_template('object_clone'), {'type': schemaType})));
    }
    if (config.patch) {
      clazz.methods.add(new DartMethod('patch', schemaType,
          new DartTemplateBody(_template('object_patch'), {'type': schemaType})));
    }
    if (config.global) {
      clazz.methods.add(new DartComplexField.getterOnly('streamyType',
         new DartType('Type'), new DartConstantBody('=> ${clazz.name};')));
    }

    addApiType(clazz);

    return new SchemaDefinition(clazz, globalFnDef, schema.extractDependencies());
  }
  
  List<DartClass> processEnums() {
    var enums = <DartClass>[];
    api.enums.forEach((name, enumDef) {
      var enumClass = new DartClass(enumDef.name);
      enumClass.fields.add(new DartSimpleField(
          'index', const DartType.integer(), isFinal: true));
      enumClass.fields.add(new DartSimpleField(
          '_displayName', const DartType.string(), isFinal: true));
      var ctor = new DartConstructor(enumClass.name, named: '_private',
          isConst: true);
      enumClass.methods.add(ctor);
      ctor.parameters.add(new DartParameter(
          'index', const DartType.integer(), isDirectAssignment: true));
      ctor.parameters.add(new DartParameter(
          '_displayName', const DartType.string(), isDirectAssignment: true));
      enumClass.methods.add(new DartMethod('toString', const DartType.string(),
          new DartConstantBody('=> _displayName;')));
      var enumType = new DartType.from(enumClass);
      enums.add(enumClass);
      var seenValues = <int, String>{};
      enumDef.values.forEach((name, value) {
        if (!seenValues.containsKey(value)) {
          enumClass.fields.add(new DartSimpleField(name, enumType,
              isStatic: true, isConst: true, initializer: new DartConstantBody(
                  'const ${enumClass.name}._private($value, \'$name\')')));
          seenValues[value] = name;
        } else {
          enumClass.fields.add(new DartSimpleField(
              name, enumType, isStatic: true, isConst: true, initializer:
              new DartConstantBody('${seenValues[value]}')));
        }
      });
      var mappingData = {
        'const': true,
        'getter': false,
        'pairs': [],
        'values': []
      };
      seenValues.forEach((index, name) {
        mappingData['pairs'].add({
          'key': '$index',
          'value': name,
          'string': false
        });
        mappingData['values'].add({'value': name, 'last': false});
      });
      if (seenValues.isNotEmpty) {
        mappingData['values'].last['last'] = true;
      }
      enumClass.fields.add(new DartSimpleField('mapping',
          new DartType.map(const DartType.integer(), enumType),
          isStatic: true, isConst: true, initializer:
          new DartTemplateBody(_template('map'), mappingData)));
      enumClass.fields.add(new DartSimpleField('values',
          new DartType.list(enumType), isStatic: true, isConst: true,
          initializer: new DartTemplateBody(_template('list'), mappingData)));
    });
    return enums;
  }

  void addApiType(DartClass clazz) {
    clazz.fields.add(new DartSimpleField('API_TYPE', const DartType.string(),
        initializer: new DartConstantBody("r'${clazz.name}'"),
        isStatic: true, isFinal: true));
    clazz.fields.add(new DartComplexField.getterOnly('apiType',
        const DartType.string(), new DartConstantBody("=> r'${clazz.name}';")));
  }

  mustache.Template _template(String name) => templates[name];
  
  _addLazyGetter(DartClass clazz, String name, Resource resource,
      {bool withPrefix: true}) {
    var getterTemplate = _template('lazy_resource_getter');

    // Backing field.
    var fieldName = makePropertyName(name);
    var privateFieldName = '_$fieldName';
    final prefix = withPrefix ? resourcePrefix : null;
    var type = new DartType('${makeClassName(resource.name)}Resource',
        prefix, const []);
    var field = new DartSimpleField(privateFieldName, type);
    clazz.fields.add(field);
    
    // Lazy getter.
    var root = clazz.fields.any((DartField field) => field.name == '_root')
        ? '_root' : 'this as streamy.Root';
    var templateBody = new DartTemplateBody(
        getterTemplate, {'field': privateFieldName, 'resource': type, 'root': root});
    var getter = new DartComplexField.getterOnly(fieldName, type, templateBody);
    clazz.fields.add(getter);
  }
  
  List<Resource> _expandResources(Resource resource) {
    var expanded = [resource];
    resource.subresources.values.forEach((r) => expanded.addAll(_expandResources(r)));
    return expanded;
  }
}
