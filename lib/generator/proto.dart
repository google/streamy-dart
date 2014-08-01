part of streamy.generator;

Api fromProtoX(req) {
  var proto = req
    .protoFile
    .where((proto) => req
      .fileToGenerate
      .contains(proto.name))
    .single;
}

Future<Api> fromProto(ProtoConfig config) {
  // Read the proto file.
  var root = config.root;
  
  // Determine commandline to protoc to get the descriptor.
  var protoPath = config.root.replaceAll(r'$CWD', io.Directory.current.path);
  var protocArgs = ['-o/dev/stdout', '--proto_path=$protoPath', '$protoPath${config.sourceFile}'];
  return io
    .Process
    .start('protoc', protocArgs)
    .then((protoc) => protoc.stdout.toList())
    .then((data) => data.expand((v) => v).toList())
    .then((data) => new protoSchema.FileDescriptorSet.fromBuffer(data))
    .then((proto) => proto.file.single)
    .then((proto) {
      var api = new Api(config.name, 'This is a description.');
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
              throw new Exception("Unknown type: ${field.name} / ${field.type} / $proto");
          }
          if (field.label == protoSchema.FieldDescriptorProto_Label.LABEL_REPEATED) {
            type = new TypeRef.list(type);
          }
          schema.properties[field.name] =
              new Field(field.name, 'Desc', type, "${field.number}", key: "${field.number}");
        });
        api.types[schema.name] = schema;
      });
      return api;
    });
}