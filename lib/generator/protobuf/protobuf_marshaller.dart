library streamy.generator.discovery.protobuf_marshaller;

import 'package:streamy/generator/dart.dart';
import 'package:streamy/generator/emitter_util.dart';
import 'package:streamy/generator/ir.dart';
import 'package:streamy/generator/generator.dart';
import 'package:streamy/generator/util.dart';
import 'package:mustache/mustache.dart' as mustache;

class ProtobufMarshallerEmitter
    extends EmitterBase
    implements MarshallerEmitter {

  final EmitterContext _ctx;
  final DartClass _marshallerClass;

  ProtobufMarshallerEmitter(this._ctx)
      : _marshallerClass = new DartClass('Marshaller');

  @override
  Map<String, mustache.Template> get templates => _ctx.templates;

  @override
  String get objectPrefix => _ctx.objectPrefix;

  void emit() {
    var importedMarshallers = _ctx
      .api
      .types
      .values
      .expand(_marshallerImportsForSchema)
      .toSet();
    importedMarshallers.addAll(_ctx
      .api
      .rpcExternalDependencies
      .expand(_marshallerImportsForType)
      .toSet());
    importedMarshallers = _ctx.config.proto.orderImported(importedMarshallers);
    var marshallers = importedMarshallers
        .map((prefix) => {'import': prefix, 'last': false})
        .toList(growable: false);
    if (marshallers.isNotEmpty) {
      marshallers.last['last'] = true;
    }
    var emptyCtor = new DartConstructor(_marshallerClass.name, isConst: true,
        body: new DartTemplateBody(_ctx.templates['proto_marshaller_ctor'],
            {'marshallers': marshallers}));
      
    var fullCtor = new DartConstructor(_marshallerClass.name,
        named: 'withMarshallers', isConst: true);
    fullCtor.parameters.addAll(importedMarshallers.map((prefix) =>
        new DartParameter('${prefix}Marshaller',
            new DartType('Marshaller', prefix), isDirectAssignment: true)));
    _marshallerClass
      ..methods.add(fullCtor)
      ..methods.add(emptyCtor)
      ..fields.addAll(importedMarshallers.map((prefix) =>
          new DartSimpleField('${prefix}Marshaller',
              new DartType('Marshaller', prefix), isFinal: true)));
    _ctx.api.types.values.forEach(_processSchemaForMarshaller);
    _ctx.api.enums.values.forEach(_processEnumForMarshaller);
    _ctx.dispatchFile.classes.add(_marshallerClass);
  }

  void decorateRequestClass(Method method, DartClass requestClass) {
    var responseType;
    if (method.responseType != null) {
      responseType = toDartType(method.responseType);
    }
    if (responseType != null && _ctx.api.httpConfig != null) {
      requestClass.methods.add(new DartMethod('unmarshalResponse',
          responseType, new DartTemplateBody(
              _ctx.templates['request_unmarshal_response'],
              {'name': makeClassName((method.responseType as SchemaTypeRef)
                  .schemaClass)}))
          ..parameters.add(new DartParameter('data',
              new DartType('Map', null, const []))));
    }

    if (method.payloadType != null) {
      var templateContext = {
        'name': makeClassName((method.payloadType as TypeRef).dataType),
        'imported': false,
        'prefix': null
      };
      if (method.payloadType is DependencyTypeRef) {
        templateContext['prefix'] =
          (method.payloadType as DependencyTypeRef).importedFrom;
        templateContext['imported'] = true;
      }
      var methodTemplate = new DartTemplateBody(
        _ctx.templates['request_marshal_payload'], templateContext);
      requestClass.methods.add(new DartMethod('marshalPayload',
          new DartType('Map'),
          methodTemplate));
    }
  }

  void _processSchemaForMarshaller(Schema schema) {
    var name = makeClassName(schema.name);
    var type = new DartType(name, objectPrefix, const []);
    var rt = new DartType.map(const DartType.string(),
        const DartType.dynamic());
    var marshal = templates['marshal'];
    var unmarshal = templates['unmarshal'];

    var allFields = [];
    var int64Fields = [];
    var doubleFields = [];
    var entityFields = {};
    var dependencyFields = {};

    schema
      .properties
      .forEach((_, field) {
        _accumulateMarshallingTypes(field.name, field.typeRef, int64Fields,
            doubleFields, entityFields, dependencyFields);
        allFields.add({
            'key': field.name,
            'identifier': makePropertyName(field.name),
        });
      });

    var stringList = new DartType.list(const DartType.string());
    var serialMap = new DartType('Map');
    if (int64Fields.isNotEmpty) {
      _marshallerClass.fields.add(new DartSimpleField('_int64s$name',
          stringList, isStatic: true, isFinal: true,
          initializer: stringListBody(int64Fields)));
    }
    if (doubleFields.isNotEmpty) {
      _marshallerClass.fields.add(new DartSimpleField('_doubles$name',
          stringList, isStatic: true, isFinal: true,
          initializer: stringListBody(doubleFields)));
    }

    var fieldMapping = {};
    schema.properties.values.forEach((field) {
      if (field.key != null) {
        fieldMapping[field.key] = field.name;
      }
    });
    if (fieldMapping.isNotEmpty) {
      _marshallerClass.fields.add(new DartSimpleField('_fieldMapping$name',
          serialMap, isStatic: true, isFinal: true,
          initializer: mapBody(fieldMapping)));
      _marshallerClass.fields.add(new DartSimpleField('_fieldUnmapping$name',
          serialMap, isStatic: true, isFinal: true,
          initializer: mapBody(invertMap(fieldMapping))));
    }
    var data = [];
    if (entityFields.isNotEmpty) {
      entityFields.forEach((name, schema) {
        data.add({
            'key': name,
            'string': true,
            'value': makeHandlerName(schema),
        });
      });
    }
    dependencyFields.forEach((name, dep) {
      data.add({
          'key': name,
          'string': true,
          'value': "${dep['import']}Marshaller.${makeHandlerName(dep['type'])}",
      });
    });
    if (data.isNotEmpty) {
      _marshallerClass.fields.add(new DartComplexField.getterOnly(
          '_entities$name', rt, new DartTemplateBody(templates['map'], {
            'pairs': data,
            'getter': true,
            'const': false,
          })));
    }
    var serializerConfig = {
        'entity': type,
        'name': name,
        'fromFields': !_ctx.config.mapBackedFields,
        'fields': allFields,
        'hasInt64s': int64Fields.isNotEmpty,
        'int64s': int64Fields,
        'hasDoubles': doubleFields.isNotEmpty,
        'doubles': doubleFields,
        'hasEntities': data.isNotEmpty,
        'hasFieldMapping': fieldMapping.isNotEmpty,
        'basePrefix': BASE_PREFIX,
    };
    _marshallerClass.methods.add(new DartMethod('marshal$name', rt,
    new DartTemplateBody(marshal, serializerConfig))
      ..parameters.add(new DartParameter('entity', type)));
    _marshallerClass.methods.add(new DartMethod('unmarshal$name', type,
    new DartTemplateBody(unmarshal, serializerConfig))
      ..parameters.add(new DartParameter('data', rt)));
    _marshallerClass.methods.add(new DartMethod(makeHandlerName(schema.name),
    const DartType.dynamic(),
    new DartTemplateBody(templates['marshal_handle'], {'type': name}))
      ..parameters.add(new DartParameter('data', const DartType.dynamic()))
      ..parameters.add(new DartParameter('marshal', const DartType.boolean())));
  }
  
  void _processEnumForMarshaller(Enum enumDef) {
    var name = makeClassName(enumDef.name);
    var type = new DartType(name, objectPrefix, const []);
    _marshallerClass.methods.add(new DartMethod('marshal$name',
        const DartType.integer(), new DartConstantBody('=> value.index;'))
        ..parameters.add(new DartParameter('value', type)));
    _marshallerClass.methods.add(new DartMethod('unmarshal$name', type,
        new DartConstantBody('=> $name.mapping[value];'))
        ..parameters.add(new DartParameter('value', const DartType.integer())));
    _marshallerClass.methods.add(new DartMethod(makeHandlerName(enumDef.name),
    const DartType.dynamic(),
    new DartTemplateBody(templates['marshal_handle'], {'type': name}))
      ..parameters.add(new DartParameter('data', const DartType.dynamic()))
      ..parameters.add(new DartParameter('marshal', const DartType.boolean())));
  }
  
  Iterable<String> _marshallerImportsForType(TypeRef ref) {
    switch (ref.base) {
      case 'list':
        return _marshallerImportsForType((ref as ListTypeRef).subType);
      case 'dependency':
        return <String>[(ref as DependencyTypeRef).importedFrom];
      default:
        return const <String>[];
    }
  }
  
  Set<String> _marshallerImportsForSchema(Schema schema) => schema
    .properties
    .values
    .map((field) => field.typeRef)
    .expand(_marshallerImportsForType)
    .toSet();

  _accumulateMarshallingTypes(String name, TypeRef typeRef,
      List<String> int64Fields, List<String> doubleFields, Map entityFields,
      Map dependencyFields) {
    switch (typeRef.base) {
      case 'int64':
        int64Fields.add(name);
        break;
      case 'double':
        doubleFields.add(name);
        break;
      case 'schema':
        entityFields[name] = (typeRef as SchemaTypeRef).schemaClass;
        break;
      case 'list':
        _accumulateMarshallingTypes(name, (typeRef as ListTypeRef).subType,
        int64Fields, doubleFields, entityFields, dependencyFields);
        break;
      case 'dependency':
        var ref = typeRef as DependencyTypeRef;
        dependencyFields[name] = {
          'import': ref.importedFrom,
          'type': ref.type,
        };
        break;
    }
  }
}
