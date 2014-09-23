library streamy.generator.emitter_util;

import 'package:mustache/mustache.dart' as mustache;
import 'package:streamy/generator/dart.dart';
import 'package:streamy/generator/ir.dart';
import 'package:streamy/generator/util.dart';

const BASE_PREFIX = '_streamy_base_';

abstract class EmitterBase {

  Map<String, mustache.Template> get templates;
  String get objectPrefix;

  DartBody stringListBody(Iterable<String> strings, {bool getter: false}) =>
  new DartTemplateBody(templates['string_list'], {
      'list': strings.map((i) => {'value': i}).toList(growable: false),
      'getter': getter
  });

  DartBody mapBody(Map<String, String> map) {
    var data = [];
    map.forEach((key, value) {
      data.add({'key': key, 'value': value});
    });
    return new DartTemplateBody(templates['string_map'], {'map': data});
  }

  Map invertMap(Map input) {
    Map output = {};
    input.forEach((key, value) {
      output[value] = key;
    });
    return output;
  }

  DartType streamyImport(String clazz, {params: const []}) =>
      new DartType(clazz, 'streamy', params);

  DartType toDartType(TypeRef ref, {bool withPrefix: true}) {
    if (ref is ListTypeRef) {
      return new DartType.list(toDartType(ref.subType));
    } else if (ref is SchemaTypeRef) {
      final prefix = withPrefix ? objectPrefix : null;
      return new DartType(makeClassName(ref.schemaClass), prefix, const []);
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
          ExternalTypeRef externalTypeRef = ref;
          return new DartType(externalTypeRef.type,
          externalTypeRef.importedFrom, const []);
        case 'dependency':
          return new DartType(makeClassName(ref.type), ref.importedFrom,
              const []);
        default:
          throw new Exception('Unhandled API type: $ref');
      }
    }
  }
}
