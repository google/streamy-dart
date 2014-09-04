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
    _marshallerClass.methods
    .add(new DartConstructor(_marshallerClass.name, isConst: true));
    _ctx.api.types.values.forEach((schema) =>
    _processSchemaForMarshaller(schema));
    _ctx.dispatchFile.classes.add(_marshallerClass);
  }

  void decorateRequestClass(Method method, DartClass requestClass) {
    var responseType;
    if (method.responseType != null) {
      responseType = toDartType(method.responseType);
    }
    if (responseType != null && _ctx.api.httpConfig != null) {
      requestClass.methods.add(new DartMethod('unmarshalResponse', responseType,
      new DartTemplateBody(_ctx.templates['request_unmarshal_response'], {
          'name': makeClassName((method.responseType as SchemaTypeRef).schemaClass)
      }))
        ..parameters.add(new DartParameter('data', new DartType('Map', null, const []))));
    }

    if (method.payloadType != null) {
      requestClass.methods.add(new DartMethod('marshalPayload', new DartType('Map'),
      new DartTemplateBody(_ctx.templates['request_marshal_payload'], {
          'name': makeClassName((method.payloadType as SchemaTypeRef).schemaClass)
      })));
    }
  }

  void _processSchemaForMarshaller(Schema schema) {
    var name = makeClassName(schema.name);
    var type = new DartType(name, objectPrefix, const []);
    var rt = new DartType.map(const DartType.string(), const DartType.dynamic());
    var data = {
        'fields': []
    };
    var marshal = templates['marshal'];
    var unmarshal = templates['unmarshal'];

    var allFields = [];
    var int64Fields = [];
    var doubleFields = [];
    var entityFields = {};

    schema
    .properties
    .forEach((_, field) {
      _accumulateMarshallingTypes(field.name, field.typeRef, int64Fields,
      doubleFields, entityFields);
      allFields.add({
          'key': field.name,
          'identifier': makePropertyName(field.name),
      });
    });

    var stringList = new DartType.list(const DartType.string());
    var serialMap = new DartType('Map');
    if (int64Fields.isNotEmpty) {
      _marshallerClass.fields.add(new DartSimpleField('_int64s$name', stringList,
      isStatic: true, isFinal: true,
      initializer: stringListBody(int64Fields)));
    }
    if (doubleFields.isNotEmpty) {
      _marshallerClass.fields.add(new DartSimpleField('_doubles$name', stringList,
      isStatic: true, isFinal: true,
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
    if (entityFields.isNotEmpty) {
      var data = [];
      entityFields.forEach((name, schema) {
        data.add({
            'key': name,
            'value': makeHandlerName(schema),
        });
      });
      _marshallerClass.fields.add(new DartComplexField.getterOnly('_entities$name', rt,
      new DartTemplateBody(templates['map'], {
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
        'hasEntities': entityFields.isNotEmpty,
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
    new DartTemplateBody(templates['marshal_handle'], {'type': name}),
    isStatic: true)
      ..parameters.add(new DartParameter('marshaller', new DartType('Marshaller', null, const [])))
      ..parameters.add(new DartParameter('data', const DartType.dynamic()))
      ..parameters.add(new DartParameter('marshal', const DartType.boolean())));
  }

  _accumulateMarshallingTypes(String name, TypeRef typeRef,
      List<String> int64Fields, List<String> doubleFields, Map entityFields) {
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
        int64Fields, doubleFields, entityFields);
        break;
    }
  }
}
