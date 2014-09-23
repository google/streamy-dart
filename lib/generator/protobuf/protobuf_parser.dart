library streamy.generator.protobuf;

import 'dart:async';
import 'dart:io' as io;
import 'package:analyzer/analyzer.dart' as analyzer;
import 'package:streamy/generator/config.dart';
import 'package:streamy/generator/ir.dart';
import 'package:streamy/google/protobuf/descriptor.pb.dart' as protoSchema;

part 'service.dart';

Future<Api> parseServiceFromConfig(
    Config config,
    String pathPrefix,
    Future<String> fileReader(String)) {
  return Future
    .wait(config.service.inputs.map(
        (input) => fileReader(pathPrefix + input.filePath)))
    .then((dataList) {
      var api = new Api(config.service.name);
      for (var i = 0; i < config.service.inputs.length; i++) {
        _parseServiceFile(api, config.service.inputs[i].importPath,
            analyzer.parseCompilationUnit(dataList[i]), i);
      }
      return api;
    });
}

/// Generate a Streamy [Api] from a [ProtoConfig].
Future<Api> parseFromProtoConfig(ProtoConfig config, String protocPath) {
  // TODO(Alex): When running via apigen, protocPath is specified on the command
  // line. When running as a transformer, though, this is not specified and
  // defaults to null. This setting of a default value can be removed when
  // specifying protoc is possible under a transformer.
  if (protocPath == null) {
    protocPath = 'protoc';
  }
  // Read the proto file.
  var root = config.root;
  
  // Determine commandline to protoc to get the descriptor.
  // TODO(Alex): Since protoc reads the proto file directly, barback doesn't
  // count it as a dependency (or any of its dependencies). Thus, the
  // edit-save-refresh cycle fails when editing .proto files currently.
  var protoPath = config.root.replaceAll(r'$CWD', io.Directory.current.path);
  var protocArgs = ['-o/dev/stdout', '--proto_path=$protoPath',
      '$protoPath${config.sourceFile}'];
  return io.Process
    .start(protocPath, protocArgs)
    .then((protoc) => protoc.stdout.toList())
    .then((data) => data.expand((v) => v).toList())
    .then((data) => new protoSchema.FileDescriptorSet.fromBuffer(data))
    .then((data) => data.file.single)
    .then((proto) {
      var api = new Api(config.name);
      proto.messageType.forEach((message) {
        var schema = new Schema(message.name);
        message.field.forEach((field) {
          var type = const TypeRef.any();
          switch (field.type) {
            case protoSchema.FieldDescriptorProto_Type.TYPE_INT32:
              type = const TypeRef.integer();
              break;
            case protoSchema.FieldDescriptorProto_Type.TYPE_INT64:
              type = const TypeRef.int64();
              break;
            case protoSchema.FieldDescriptorProto_Type.TYPE_STRING:
              type = const TypeRef.string();
              break;
            case protoSchema.FieldDescriptorProto_Type.TYPE_MESSAGE:
              var parts = field.typeName.split('.').skip(1).toList();
              if (parts[0] == proto.package) {
                type = new TypeRef.schema(parts.skip(1).single);
              } else {
                var entity = parts.removeLast();
                var package = parts.join('.');
                if (config.depsByPackage.containsKey(package)) {
                  var importPrefix = config.depsByPackage[package].prefix;
                  type = new TypeRef.dependency(entity, importPrefix);
                } else {
                  throw new Exception("Unknown dependency $entity from $package");
                }
              }
              break;
            default:
              throw new Exception("Unknown: ${field.name} / ${field.type}");
          }
          if (field.label ==
              protoSchema.FieldDescriptorProto_Label.LABEL_REPEATED) {
            type = new TypeRef.list(type);
          }
          schema.properties[field.name] =
              new Field(field.name, 'Desc', type, "${field.number}",
                  key: "${field.number}");
        });
        api.types[schema.name] = schema;
        
        // Add dependencies to the IR.
        config
          .depsByImport
          .values
          .forEach((dep) => api.dependencies[dep.prefix] = dep.importPackage);
      });
      return api;
    });
}
