part of streamy.generator;

const SPLIT_LEVEL_NONE = 1;
const SPLIT_LEVEL_PARTS = 2;
const SPLIT_LEVEL_LIBS = 3;

class Emitter {
  final int splitLevel;
  final PathConfig pathConfig;
  final HierarchyConfig hierarchyConfig;
  final TemplateLoader loader;
  final Config config;
  
  Emitter(
      this.splitLevel,
      this.pathConfig,
      this.hierarchyConfig,
      this.config,
      this.loader);
  
  List<DartFile> process(Api api) {
    var rootFile, rootPrefix;
    var resourceFile, resourcePrefix;
    var requestFile, requestPrefix;
    var objectFile, objectPrefix;
    var libPrefix = api.name;
    if (api.version != null) {
      libPrefix = "$libPrefix.${api.version}";
    }
    rootFile = new DartLibrary(libPrefix);
    rootFile.imports['package:streamy/streamy.dart'] = 'streamy';
    var out = [rootFile];
    switch (splitLevel) {
      case SPLIT_LEVEL_NONE:
        resourceFile = rootFile;
        requestFile = rootFile;
        objectFile = rootFile;
        break;
      case SPLIT_LEVEL_PARTS:
        resourceFile = new DartLibraryPart(rootFile.libraryName,
            pathConfig.relativePath('resources.dart'));
        requestFile = new DartLibraryPart(rootFile.libraryName,
            pathConfig.relativePath('requests.dart'));
        objectFile = new DartLibraryPart(rootFile.libraryName,
            pathConfig.relativePath('objects.dart'));
        rootFile.parts.addAll([resourceFile, requestFile, objectFile]);
        out.addAll([resourceFile, requestFile, objectFile]);
        break;
      case SPLIT_LEVEL_LIBS:
        resourceFile = new DartLibrary('$libPrefix.resources');
        requestFile = new DartLibrary('$libPrefix.requests');
        objectFile = new DartLibrary('$libPrefix.objects');
        resourcePrefix = 'resources';
        requestPrefix = 'requests';
        objectPrefix = 'objects';
        rootFile.imports
          ..[pathConfig.importPath('resources.dart')] = 'resources'
          ..[pathConfig.importPath('requests.dart')] = 'requests'
          ..[pathConfig.importPath('objects.dart')] = 'objects';
        resourceFile.imports['package:streamy/streamy.dart'] = 'streamy';
        requestFile.imports['package:streamy/streamy.dart'] = 'streamy';
        objectFile.imports['package:streamy/streamy.dart'] = 'streamy';
        out.addAll([resourceFile, requestFile, objectFile]);
        break;
    }
    
    // Root class
    rootFile.classes.add(processRoot(api, resourcePrefix));
    
    resourceFile.classes.addAll(processResources(api, requestPrefix, objectPrefix));
    
    requestFile.classes.addAll(processRequests(api, objectPrefix));
    
    objectFile.classes.addAll(processSchemas(api));
    return out;
  }
  
  DartFile processRoot(Api api, String resourcePrefix) {
    // Create the root API class.
    var root = new DartClass(toProperIdentifier(api.name));
    if (api.description != null) {
      root.comments.addAll(splitStringAcrossLines(api.description));
    }
    
    // Set up a _root field for the implementation RequestHandler, and a
    // constructor that sets it.
    var rootType = streamyImport('Root');
    root.fields.add(new DartSimpleField('_root', rootType, isFinal: true));
    var ctor = new DartConstructor(root.name);
    ctor.parameters.add(new DartParameter('_root', rootType, isDirectAssignment: true));
    root.methods.add(ctor);
    
    // Implement backing fields and lazy getters for each resource type.
    var getterTemplate = loader.load('lazy_resource_getter');
    api.resources.forEach((name, resource) {
      // Backing field.
      var fieldName = "_${resource.name}";
      var type = new DartType('${toProperIdentifier(resource.name)}Resource',
          resourcePrefix, const []);
      var field = new DartSimpleField(fieldName, type);
      root.fields.add(field);
      
      // Lazy getter.
      var getter = new DartComplexField.getterOnly(resource.name, type,
          new DartTemplateBody(getterTemplate, {'field': fieldName, 'resource': type}));
      root.fields.add(getter);
    });
    return root;
  }

  List<DartClass> processResources(Api api, String requestPrefix, String objectPrefix) =>
    api
      .resources
      .values
      .map((resource) => processResource(resource, requestPrefix, objectPrefix))
      .toList(growable: false);
  
  DartClass processResource(Resource resource, String requestPrefix,
      String objectPrefix) {
    var name = toProperIdentifier(resource.name);
    var clazz = new DartClass('${toProperIdentifier(resource.name)}Resource');
    var requestMethodTemplate = loader.load('request_method');
    
    // Set up a _root field for the implementation RequestHandler, and a
    // constructor that sets it.
    var rootType = streamyImport('Root');
    clazz.fields.add(new DartSimpleField('_root', rootType, isFinal: true));
    var ctor = new DartConstructor(clazz.name);
    ctor.parameters.add(new DartParameter('_root', rootType, isDirectAssignment: true));
    clazz.methods.add(ctor);
    
    
    if (config.knownMethods) {
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
        payloadType = toDartType(method.payloadType, objectPrefix);
        plist.add(new DartParameter('payload', payloadType));
      } else {
        method.httpPath.parameters().forEach((param) {
          if (!method.parameters.containsKey(param)) {
            return;
          }
          var pRecord = method.parameters[param];
          var pType = toDartType(pRecord.typeRef, objectPrefix);
          plist.add(new DartParameter(param, pType));
          pnames.add(param);
        });
      }
      
      var requestType = new DartType(
          '${clazz.name}${toProperIdentifier(method.name)}Request',
          requestPrefix, const []);
      
      var m = new DartMethod(method.name, requestType,
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
    addApiType(clazz);
    return clazz;
  }
  
  List<DartClass> processRequests(Api api, String objectPrefix) =>
    api
      .resources
      .values
      .expand((resource) => resource
        .methods
        .values
        .map((method) => processRequest(api, toProperIdentifier(resource.name), method, objectPrefix))
      )
      .toList(growable: false);
      
  DartClass processRequest(Api api, String resourceName, Method method, String objectPrefix) {
    var paramGetter = loader.load('request_param_getter');
    var paramSetter = loader.load('request_param_setter');
    var methodName = toProperIdentifier(method.name);
    var clazz = new DartClass('$resourceName${methodName}Request',
        baseClass: streamyImport('Request'));
    
    // Set up a _root field for the implementation RequestHandler, and a
    // constructor that sets it.
    var rootType = streamyImport('Root');
    var ctor = new DartConstructor(clazz.name, body: new DartTemplateBody(
      loader.load('request_ctor'), {}
    ))
      ..parameters.add(new DartParameter('root', rootType));
    clazz.methods.add(ctor);
    
    if (config.knownParameters) {
      clazz.fields.add(new DartSimpleField('KNOWN_PARAMETERS',
          new DartType.list(const DartType.string()),
          isStatic: true, isFinal: true,
          initializer: stringListBody(
              method.parameters.values.map((p) => p.name))));
    }
    
    // Set up fields for all the preferences.
    method.parameters.forEach((name, param) {
      var type = toDartType(param.typeRef, objectPrefix);
      clazz.fields.add(
          new DartComplexField(name, type,
              new DartTemplateBody(paramGetter, {'name': name}),
              new DartTemplateBody(paramSetter, {'name': name})));
      clazz.methods.add(new DartMethod(toProperIdentifier('remove_$name', firstLetter: false), type,
          new DartTemplateBody(loader.load('request_remove'), {'name': name})));
    });
    
    addApiType(clazz);
    
    clazz.fields
      ..add(new DartComplexField.getterOnly('hasPayload',
          const DartType.boolean(), new DartConstantBody(
              '=> ${method.payloadType != null};')))
      ..add(new DartComplexField.getterOnly('httpMethod',
          const DartType.string(), new DartConstantBody(
              "=> r'${method.httpMethod}';")))
      ..add(new DartComplexField.getterOnly('pathFormat',
          const DartType.string(), new DartConstantBody(
              "=> r'${method.httpPath}';")))
      ..add(new DartComplexField.getterOnly('pathParameters',
          new DartType.list(const DartType.string()), stringListBody(
              method
                .parameters
                .values
                .where((p) => p.location == 'path')
                .map((p) => p.name), getter: true)))
      ..add(new DartComplexField.getterOnly('queryParameters',
          new DartType.list(const DartType.string()), stringListBody(
              method
                .parameters
                .values
                .where((p) => p.location != 'path')
                .map((p) => p.name), getter: true)));


    // Set up send() methods.
    var sendParams = [];
    api.streamy.sendParams.forEach((p) {
      var type = toDartType(p.typeRef, objectPrefix);
      var defaultValue;
      if (p.defaultValue != null) {
        if (p.defaultValue is String) {
          defaultValue = new DartConstantBody("r'${p.defaultValue}'");
        } else {
          defaultValue = new DartConstantBody(p.defaultValue.toString());
        }
      }
      sendParams.add(new DartNamedParameter(p.name, type, defaultValue: defaultValue));
    });
    
    var sendDirectTemplate = loader.load('request_send_direct');
    var sendTemplate = loader.load('request_send');
    
    // Add _sendDirect.
    var responseType;
    var responseParams = [];
    if (method.responseType != null) {
      responseType = toDartType(method.responseType, objectPrefix);
      responseParams.add(responseType);
    }
    var rawType = new DartType.stream(
        streamyImport('Response', params: responseParams));
    clazz.methods.add(new DartMethod('_sendDirect', rawType,
        new DartTemplateBody(sendDirectTemplate, {})));
    
    // Add send().
    var sendType;
    if (responseType == null) {
      sendType = new DartType('Stream', null, const []);
    } else {
      sendType = new DartType.stream(responseType);
    }
    
    var sendParamNames = sendParams
      .map((p) => {'name': p.name})
      .toList(growable: false);
    
    var send = new DartMethod('send', sendType, new DartTemplateBody(
        sendTemplate, {
          'sendParams': sendParamNames,
          'listen': false,
          'raw': false,
        }))
      ..parameters.addAll(sendParams);
    clazz.methods.add(send);
    
    // Add sendRaw().
    var sendRaw = new DartMethod('sendRaw', rawType, new DartTemplateBody(
        sendTemplate, {
          'sendParams': sendParamNames,
          'listen': false,
          'raw': true
        }
    ))
      ..parameters.addAll(sendParams);
    clazz.methods.add(sendRaw);
    
    var listenType = new DartType('StreamSubscription', null, responseParams);
    var listen = new DartMethod('listen', listenType, new DartTemplateBody(
      sendTemplate, {
        'sendParams': sendParamNames,
        'listen': true,
        'raw': false
      }
    ))
      ..parameters.addAll(sendParams);
    clazz.methods.add(listen);
    
    var clone = new DartMethod('clone',
        new DartType(clazz.name, null, const []),
        new DartTemplateBody(loader.load('request_clone'), {
          'type': clazz.name
    }));
    clazz.methods.add(clone);
    
    return clazz;
  }
  
  List<DartClass> processSchemas(Api api) => api
    .types
    .values
    .map(processSchema)
    .toList(growable: false);
  
  DartClass processSchema(Schema schema) {
    var base = hierarchyConfig.baseClassFor(schema.name);
    var clazz = new DartClass(toProperIdentifier(schema.name), baseClass: base);
    
    var getter = loader.load('object_getter');
    var setter = loader.load('object_setter');
    var remove = loader.load('object_remove');
    
    if (config.knownProperties) {
      clazz.fields.add(new DartSimpleField('KNOWN_PROPERTIES',
          new DartType.list(const DartType.string()),
          isFinal: true, isStatic: true,
          initializer: stringListBody(schema.properties.values.map((m) => m.name))));
    }
    
    schema.properties.forEach((_, field) {
      // Add getter and setter, delegating to map access.
      var name = toProperIdentifier(field.name, firstLetter: false);
      var type = toDartType(field.typeRef, null);
      if (config.mapBackedFields) {
        var f = new DartComplexField(name, type,
            new DartTemplateBody(getter, {'name': field.name}),
            new DartTemplateBody(setter, {'name': field.name}));
        clazz.fields.add(f);
        if (config.removers) {
          var r = new DartMethod('remove${toProperIdentifier(field.name)}', type,
              new DartTemplateBody(remove, {'name': field.name}));
        clazz.methods.add(r);
        }
      } else {
        var f = new DartSimpleField(name, type);
        clazz.fields.add(f);
      }
    });
    
    var schemaType = new DartType.from(clazz);
    if (config.cloneEntity) {
      clazz.methods.add(new DartMethod('clone', schemaType,
          new DartTemplateBody(loader.load('object_clone'), {'type': schemaType})));
    }
    
    addApiType(clazz);
    
    return clazz;
  }
  
  void addApiType(DartClass clazz) {
    clazz.fields.add(new DartComplexField.getterOnly('apiType',
        const DartType.string(), new DartConstantBody("=> r'${clazz.name}';")));
  }
  
  DartBody stringListBody(Iterable<String> strings, {bool getter: false}) =>
      new DartTemplateBody(loader.load('string_list'), {
      'list': strings.map((i) => {'value': i}).toList(growable: false),
      'getter': getter
    });
  
  DartType streamyImport(String clazz, {params: const []}) =>
      new DartType(clazz, 'streamy', params);
  
  DartType toDartType(TypeRef ref, String objectPrefix) {
    if (ref is ListTypeRef) {
      return new DartType.list(toDartType(ref.subType));
    } else if (ref is SchemaTypeRef) {
      return new DartType(ref.schemaClass, objectPrefix, const []);
    } else {
      switch (ref.base) {
        case 'int64':
          return new DartType('Int64', 'fixnum', const []);
        case 'integer':
          return const DartType.integer();
        case 'string':
          return const DartType.string();
        case 'any':
          return const DartType.dynamic();
        case 'double':
          return const DartType.double();
        case 'boolean':
          return const DartType.boolean();
        case 'external':
          return new DartType(ref.type, '', const []);
        default:
          throw new Exception('Unhandled API type: $ref');
      }
    }
  }
}
