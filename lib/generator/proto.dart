library streamy.generator.protobuf;

import 'dart:async';
import 'dart:io' as io;
import 'package:streamy/generator/config.dart';
import 'package:streamy/generator/ir.dart';
import 'package:streamy/google/protobuf/descriptor.pb.dart' as protoSchema;

/// Generate a Streamy [Api] from a [ProtoConfig].
Future<Api> fromProto(ProtoConfig config) {
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
    .start('protoc', protocArgs)
    .then((protoc) => protoc.stdout.toList())
    .then((data) => data.expand((v) => v).toList())
    .then((data) => new protoSchema.FileDescriptorSet.fromBuffer(data))
    .then((proto) => proto.file.single)
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
              type = new TypeRef.schema(field.typeName.split('.')[2]);
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
      });
      return api;
    });
}