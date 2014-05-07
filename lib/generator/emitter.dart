part of streamy.generator;

const SPLIT_LEVEL_NONE = 1;
const SPLIT_LEVEL_PARTS = 2;
const SPLIT_LEVEL_LIBS = 3;

class StreamyClient {
  final DartFile root;
  final DartFile resources;
  final DartFile requests;
  final DartFile objects;
  final DartFile dispatch;
  
  StreamyClient(this.root, this.resources, this.requests, this.objects, this.dispatch);
}

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
  
  StreamyClient process(Api api) {
    var client;
    var rootFile, rootPrefix;
    var resourceFile, resourcePrefix;
    var requestFile, requestPrefix;
    var objectFile, objectPrefix;
    var dispatchFile, dispatchPrefix;
    var libPrefix = api.name;
    if (api.version != null) {
      libPrefix = "$libPrefix.${api.version}";
    }
    rootFile = new DartLibrary(libPrefix)
      ..imports['package:streamy/streamy.dart'] = 'streamy'
      ..imports['package:fixnum/fixnum.dart'] = 'fixnum'
      ..imports['dart:async'] = null;
    var out = [rootFile];
    switch (splitLevel) {
      case SPLIT_LEVEL_NONE:
        resourceFile = rootFile;
        requestFile = rootFile;
        objectFile = rootFile;
        dispatchFile = rootFile;
        client = new StreamyClient(rootFile, null, null, null, null);
        break;
      case SPLIT_LEVEL_PARTS:
        resourceFile = new DartLibraryPart(rootFile.libraryName,
            pathConfig.relativePath('resources.dart'));
        requestFile = new DartLibraryPart(rootFile.libraryName,
            pathConfig.relativePath('requests.dart'));
        objectFile = new DartLibraryPart(rootFile.libraryName,
            pathConfig.relativePath('objects.dart'));
        dispatchFile = new DartLibraryPart(rootFile.libraryName,
            pathConfig.relativePath('dispatch.dart'));
        rootFile.parts.addAll([resourceFile, requestFile, objectFile, dispatchFile]);
        out.addAll([resourceFile, requestFile, objectFile, dispatchFile]);
        client = new StreamyClient(rootFile, resourceFile, requestFile, objectFile, dispatchFile);
        break;
      case SPLIT_LEVEL_LIBS:
        resourceFile = new DartLibrary('$libPrefix.resources');
        requestFile = new DartLibrary('$libPrefix.requests');
        objectFile = new DartLibrary('$libPrefix.objects');
        dispatchFile = new DartLibrary('$libPrefix.dispatch');
        resourcePrefix = 'resources';
        requestPrefix = 'requests';
        objectPrefix = 'objects';
        dispatchPrefix = 'dispatch';
        rootFile.imports
          ..[pathConfig.importPath('resources.dart')] = 'resources';
        resourceFile.imports
          ..['package:streamy/streamy.dart'] = 'streamy'
          ..['package:fixnum/fixnum.dart'] = 'fixnum'
          ..[pathConfig.importPath('requests.dart')] = 'requests'
          ..[pathConfig.importPath('objects.dart')] = 'objects';
        requestFile.imports
          ..['package:streamy/streamy.dart'] = 'streamy'
          ..['package:fixnum/fixnum.dart'] = 'fixnum'
          ..[pathConfig.importPath('objects.dart')] = 'objects'
          ..[pathConfig.importPath('dispatch.dart')] = 'dispatch'
          ..['dart:async'] = null;;
        objectFile.imports
          ..['package:streamy/streamy.dart'] = 'streamy'
          ..['package:fixnum/fixnum.dart'] = 'fixnum';
        dispatchFile.imports
          ..['package:streamy/streamy.dart'] = 'streamy'
          ..['package:fixnum/fixnum.dart'] = 'fixnum'
          ..[pathConfig.importPath('objects.dart')] = 'objects';
        out.addAll([resourceFile, requestFile, objectFile, dispatchFile]);
        resourceFile.imports.addAll(api.imports);
        requestFile.imports.addAll(api.imports);
        objectFile.imports.addAll(api.imports);
        dispatchFile.imports.addAll(api.imports);
        client = new StreamyClient(rootFile, resourceFile, requestFile, objectFile, dispatchFile);
        break;
    }
    
    rootFile.imports.addAll(api.imports);
    
    // Root class
    rootFile.classes.addAll(processRoot(api, resourcePrefix));
    resourceFile.classes.addAll(processResources(api, requestPrefix, objectPrefix));
    requestFile.classes.addAll(processRequests(api, objectPrefix, dispatchPrefix));
    objectFile.classes.addAll(processSchemas(api));
    dispatchFile.classes.add(processMarshaller(api, objectPrefix));
    return client;
  }
  
  List<DartClass> processRoot(Api api, String resourcePrefix) {
    // Create the resource mixin class.
    var resourceMixin = new DartClass('${toProperIdentifier(api.name)}ResourceMixin');
    if (api.description != null) {
      resourceMixin.comments.addAll(splitStringAcrossLines(api.description));
    }
    
    // Implement backing fields and lazy getters for each resource type.
    var getterTemplate = loader.load('lazy_resource_getter');
    api.resources.forEach((name, resource) {
      // Backing field.
      var fieldName = "_${resource.name}";
      var type = new DartType('${toProperIdentifier(resource.name)}Resource',
          resourcePrefix, const []);
      var field = new DartSimpleField(fieldName, type);
      resourceMixin.fields.add(field);
      
      // Lazy getter.
      var getter = new DartComplexField.getterOnly(resource.name, type,
          new DartTemplateBody(getterTemplate, {'field': fieldName, 'resource': type}));
      resourceMixin.fields.add(getter);
    });
    
    var mixinType = new DartType.from(resourceMixin);
    var root = new DartClass(toProperIdentifier(api.name), baseClass: streamyImport('HttpRoot'))
      ..mixins.add(mixinType)
      ..fields.add(new DartSimpleField('requestHandler', streamyImport('RequestHandler'), isFinal: true))
      ..fields.add(new DartSimpleField('txStrategy', streamyImport('TransactionStrategy'), isFinal: true))
      ..fields.add(new DartSimpleField('tracer', streamyImport('Tracer'), isFinal: true));
    
    var ctor = new DartConstructor(root.name, body: new DartTemplateBody(
      loader.load('root_constructor'), {
        'servicePath': api.servicePath
      }
    ))
      ..parameters.add(new DartParameter('requestHandler',
          streamyImport('RequestHandler'), isDirectAssignment: true))
      ..namedParameters.add(new DartNamedParameter('servicePath',
          const DartType.string(),
          defaultValue: new DartConstantBody("r'${api.servicePath}'")))
      ..namedParameters.add(new DartNamedParameter('txStrategy',
          streamyImport('TransactionStrategy'),
          isDirectAssignment: true))
      ..namedParameters.add(new DartNamedParameter('tracer', streamyImport('Tracer'),
          isDirectAssignment: true,
          defaultValue: new DartConstantBody('const streamy.NoopTracer()')));
    root.methods.add(ctor);
    
    var send = new DartMethod('send', new DartType('Stream', null, const []),
      new DartTemplateBody(loader.load('root_send'), {})
    )
      ..parameters.add(new DartParameter('request', streamyImport('Request')));
    root.methods.add(send);
    
    addApiType(root);
    
    var transactionRoot = new DartClass(
        '${toProperIdentifier(api.name)}Transaction',
        baseClass: streamyImport('HttpTransactionRoot'))
      ..mixins.add(mixinType);
    
    return [resourceMixin, root, transactionRoot];
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
          '${toProperIdentifier(resource.name)}${toProperIdentifier(method.name)}Request',
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
  
  List<DartClass> processRequests(Api api, String objectPrefix, String dispatchPrefix) =>
    api
      .resources
      .values
      .expand((resource) => resource
        .methods
        .values
        .map((method) => processRequest(api, toProperIdentifier(resource.name), method, objectPrefix, dispatchPrefix))
      )
      .toList(growable: false);
      
  DartClass processRequest(Api api, String resourceName, Method method, String objectPrefix, String dispatchPrefix) {
    var paramGetter = loader.load('request_param_getter');
    var paramSetter = loader.load('request_param_setter');
    var methodName = toProperIdentifier(method.name);
    var clazz = new DartClass('$resourceName${methodName}Request',
        baseClass: streamyImport('HttpRequest'));
        
    // Determine payload type.
    var payloadType;
    if (method.payloadType != null) {
        payloadType = toDartType(method.payloadType, objectPrefix);
    }
    
    var listParams = method
      .parameters
      .values
      .where((param) => param.typeRef is ListTypeRef)
      .map((param) => {'name': param.name, 'type': toDartType(param.typeRef.subType, objectPrefix)})
      .toList(growable: false);
    
    // Set up a _root field for the implementation RequestHandler, and a
    // constructor that sets it.
    var rootType = streamyImport('Root');
    var ctor = new DartConstructor(clazz.name, body: new DartTemplateBody(
      loader.load('request_ctor'), {
        'hasPayload': payloadType != null,
        'hasListParams': listParams.isNotEmpty,
        'listParams': listParams
    }))
      ..parameters.add(new DartParameter('root', rootType));
    if (payloadType != null) {
        ctor.parameters.add(new DartParameter('payload', payloadType));
    }
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
    
    if (responseType != null) {
      clazz.methods.add(new DartMethod('unmarshalResponse', responseType,
          new DartTemplateBody(loader.load('request_unmarshal_response'), {
            'name': toProperIdentifier(method.responseType.schemaClass)
          }
      ))
        ..parameters.add(new DartParameter('marshaller', new DartType('Marshaller', dispatchPrefix, const [])))
        ..parameters.add(new DartParameter('data', new DartType('Map', null, const []))));
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
          'type': clazz.name,
          'hasPayload': payloadType != null
    }));
    clazz.methods.add(clone);
    
    return clazz;
  }
  
  List<DartClass> processSchemas(Api api) => api
    .types
    .values
    .map(processSchema)
    .toList(growable: false);

  DartClass processMarshaller(Api api, String objectPrefix) => api
    .types
    .values
    .fold(new DartClass('Marshaller'), (clazz, schema) => processSchemaForMarshaller(clazz, schema, objectPrefix));
  
  DartClass processSchema(Schema schema) {
    var base = hierarchyConfig.baseClassFor(schema.name);
    var clazz = new DartClass(toProperIdentifier(schema.name), baseClass: base);
    clazz.mixins.addAll(schema.mixins.map((mixin) => toDartType(mixin, '')));
    
    var ctor = loader.load('object_ctor');
    var getter = loader.load('object_getter');
    var setter = loader.load('object_setter');
    var remove = loader.load('object_remove');
    
    clazz.methods.add(new DartConstructor(clazz.name, body: new DartTemplateBody(
      ctor, {'wrap': false})));
    clazz.methods.add(new DartConstructor(clazz.name, named: 'wrap',
      body: new DartTemplateBody(ctor, {'wrap': true}))
      ..parameters.add(new DartParameter('map', new DartType.map(const DartType.string(), const DartType.dynamic()))));
    
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
  
  DartClass processSchemaForMarshaller(DartClass clazz, Schema schema, String objectPrefix) {
    var name = toProperIdentifier(schema.name);
    var type = new DartType(name, objectPrefix, const []);
    var rt = new DartType.map(const DartType.string(), const DartType.dynamic());
    var data = {
      'fields': []
    };
    var marshal = loader.load('marshal');
    var unmarshal = loader.load('unmarshal');
    
    var allFields = [];
    var int64Fields = [];
    var doubleFields = [];
    var entityFields = {};
    
    schema
      .properties
      .forEach((_, field) {
        var name = field.name;
        var type = field.typeRef;
        if (field.typeRef is ListTypeRef) {
          type = type.subType;
        }
        switch (type.base) {
          case 'int64':
            int64Fields.add(field.name);
            break;
          case 'double':
            doubleFields.add(field.name);
            break;
          case 'schema':
            entityFields[field.name] = type.schemaClass;
            break;
        }
        allFields.add({'key': field.name, 'identifier': toProperIdentifier(field.name, firstLetter: false)});
      });
  
    var stringList = new DartType.list(const DartType.string());
    var serialMap = new DartType('Map', '', const []);
    if (int64Fields.isNotEmpty) {
      clazz.fields.add(new DartSimpleField('_int64s$name', stringList, isStatic: true, isFinal: true, initializer: stringListBody(int64Fields)));
    }
    if (doubleFields.isNotEmpty) {
      clazz.fields.add(new DartSimpleField('_doubles$name', stringList, isStatic: true, isFinal: true, initializer: stringListBody(doubleFields)));
    }
    if (entityFields.isNotEmpty) {
      var data = [];
      entityFields.forEach((name, schema) {
        data.add({'key': name, 'value': '_handle${toProperIdentifier(schema)}'});
      });
      clazz.fields.add(new DartSimpleField('_entities$name', rt, isStatic: true, isFinal: true, initializer:
          new DartTemplateBody(loader.load('map'), {'pairs': data})));
    }
    var serializerConfig = {
      'entity': type,
      'name': name,
      'fromFields': !config.mapBackedFields,
      'fields': allFields,
      'hasInt64s': int64Fields.isNotEmpty,
      'int64s': int64Fields,
      'hasDoubles': doubleFields.isNotEmpty,
      'doubles': doubleFields,
      'hasEntities': entityFields.isNotEmpty,
    };
    clazz.methods.add(new DartMethod('marshal$name', rt,
        new DartTemplateBody(marshal, serializerConfig))
      ..parameters.add(new DartParameter('entity', type)));
    clazz.methods.add(new DartMethod('unmarshal$name', type,
        new DartTemplateBody(unmarshal, serializerConfig))
      ..parameters.add(new DartParameter('data', rt)));
      /*
    var unmarshal = new DartMethod('unmarshal$name', type,
        new DartTemplateBody(unmarshal, data));
        */
    return clazz;
  }
  
  SerializationWrapper serializationWrapperFor(TypeRef type) {
    if (type is ListTypeRef) {
      var st = serializationWrapperFor(type.subType);
      // Don't need .map() if the transform is the identity function.
      if (st.isEmpty) {
        return const SerializationWrapper('', '.toList(growable: false)');
      }
      return new SerializationWrapper('', '.map((v) => ${st.prefix}v${st.suffix}).toList(growable: false)');
    } else if (type is SchemaTypeRef) {
      return new SerializationWrapper('marshal${type.schemaClass}(', ')');
    } else if (type.base == 'int64') {
      return const SerializationWrapper('', '.toString()');
    }
    return const SerializationWrapper.empty();
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
      return new DartType.list(toDartType(ref.subType, objectPrefix));
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
        case 'number':
          return const DartType.double();
        case 'external':
          return new DartType(ref.type, ref.importedFrom, const []);
        default:
          throw new Exception('Unhandled API type: $ref');
      }
    }
  }
}

class SerializationWrapper {
  final String prefix;
  final String suffix;
  
  const SerializationWrapper(this.prefix, this.suffix);
  
  const SerializationWrapper.empty() : this('', '');
  
  bool get isEmpty => this.prefix == '' && this.suffix == '';
}