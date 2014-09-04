library streamy.generator.discovery.json_marshaller;

import 'package:streamy/generator/dart.dart';
import 'package:streamy/generator/emitter_util.dart';
import 'package:streamy/generator/ir.dart';
import 'package:streamy/generator/generator.dart';
import 'package:streamy/generator/util.dart';
import 'package:mustache/mustache.dart' as mustache;

class JsonMarshallerEmitter
    extends EmitterBase
    implements MarshallerEmitter {

  final EmitterContext _ctx;
  final DartClass _marshallerClass;

  JsonMarshallerEmitter(this._ctx)
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
    if (method.responseType != null && _ctx.api.httpConfig != null) {
      final responseType = toDartType(method.responseType);
      final data = {
        'name': makeClassName(
            (method.responseType as SchemaTypeRef).schemaClass)
      };
      final body = new DartTemplateBody(
          _ctx.templates['request_unmarshal_response'], data);
      final unmarshalMethod =
          new DartMethod('unmarshalResponse', responseType, body)
            ..parameters.add(
              new DartParameter('data', new DartType('Map', null, const [])));
      requestClass.methods.add(unmarshalMethod);
    }
  }

  void _processSchemaForMarshaller(Schema schema) {
    var name = makeClassName(schema.name);
    var type = new DartType(name, _ctx.objectPrefix, const []);
    var rt = new DartType.map(const DartType.string(), const DartType.dynamic());
    var data = {
        'fields': []
    };
    var unmarshal = _ctx.templates['unmarshal_json'];

    var allFields = [];
    var int64Fields = fieldsOf('int64', schema.properties).keys;
    var doubleFields = fieldsOf('double', schema.properties).keys;
    var entityFields = fieldsOf('schema', schema.properties);

    schema.properties.forEach((_, field) {
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

    if (entityFields.isNotEmpty) {
      var data = [];
      entityFields.forEach((String name, String type) {
        data.add({
            'key': name,
            'value': _makeUnmarshallerName(type),
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
        'fields': allFields,
        'hasInt64s': int64Fields.isNotEmpty,
        'int64s': int64Fields,
        'hasDoubles': doubleFields.isNotEmpty,
        'doubles': doubleFields,
        'hasEntities': entityFields.isNotEmpty,
        'basePrefix': BASE_PREFIX,
    };
    _marshallerClass.methods.add(
        new DartMethod(_makeUnmarshallerName(schema.name), type,
            new DartTemplateBody(unmarshal, serializerConfig))
          ..parameters.add(new DartParameter('data', rt)));
  }

  String _makeUnmarshallerName(String type) {
    return makeMethodName(joinParts(['unmarshal', type]));
  }
}
