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
  var protocArgs = ['-o/dev/stdout'];
  if (root is! List) {
    root = [root];
  }
  protocArgs.addAll(root
      .map((r) => r.replaceAll(r'$CWD', io.Directory.current.path))
      .map((r) => new io.Directory(r))
      .where((dir) => dir.existsSync())
      .map((dir) => dir.absolute.path)
      .map((path) => '--proto_path=$path'));
  protocArgs.add(config.sourceFile.replaceAll(
      r'$CWD', io.Directory.current.path));
  return io.Process
    .start(protocPath, protocArgs)
    .then((protoc) {
      var data = protoc.stdout.toList();
      io.stderr.addStream(protoc.stderr);
      return data;
    })
    .then((data) => data.expand((v) => v).toList())
    .then((data) => new protoSchema.FileDescriptorSet.fromBuffer(data))
    .then((data) => data.file.single)
    .then((proto) {
      var httpConfig = new HttpConfig(
        config.name,
        '',
        '/',
        config.servicePath
      );
      var api = new Api(config.name, httpConfig: httpConfig);

      // Prefix nested messages with their containing message's name to reduce
      // name collision.
      proto.messageType.forEach((m) => _prefixNestedMessagesAndEnums(m));
      List<EnumDescriptorProto> allEnums = _getAllEnums(proto);
      List<DescriptorProto> allMessages = _getAllMessages(proto);

      validateNameUnique(allMessages, allEnums);

      allEnums.forEach((def) {
        var enumDef = new Enum(def.name);
        def.value.forEach((value) {
          enumDef.values[value.name] = value.number;
        });
        api.enums[def.name] = enumDef;
      });
      allMessages.forEach((message) {
        var schema = new Schema(message.name);
        message.field.forEach((field) {
          var typeRef = const TypeRef.any();
          switch (field.type) {
            case protoSchema.FieldDescriptorProto_Type.TYPE_INT32:
            case protoSchema.FieldDescriptorProto_Type.TYPE_SINT32:
            case protoSchema.FieldDescriptorProto_Type.TYPE_UINT32:
            case protoSchema.FieldDescriptorProto_Type.TYPE_FIXED32:
            case protoSchema.FieldDescriptorProto_Type.TYPE_SFIXED32:
              typeRef = const TypeRef.integer();
              break;
            case protoSchema.FieldDescriptorProto_Type.TYPE_INT64:
            case protoSchema.FieldDescriptorProto_Type.TYPE_SINT64:
            case protoSchema.FieldDescriptorProto_Type.TYPE_FIXED64:
              typeRef = const TypeRef.int64();
              break;
            case protoSchema.FieldDescriptorProto_Type.TYPE_DOUBLE:
            case protoSchema.FieldDescriptorProto_Type.TYPE_FLOAT:
              typeRef = const TypeRef.double();
              break;
            case protoSchema.FieldDescriptorProto_Type.TYPE_STRING:
              typeRef = const TypeRef.string();
              break;
            case protoSchema.FieldDescriptorProto_Type.TYPE_BOOL:
              typeRef = const TypeRef.boolean();
              break;
            case protoSchema.FieldDescriptorProto_Type.TYPE_MESSAGE:
              typeRef = _typeFromProtoName(field.typeName, proto.package,
                  config.depsByPackage);
              break;
            case protoSchema.FieldDescriptorProto_Type.TYPE_GROUP:
              throw new Exception('Group fields are unsupported.');
              break;
            case protoSchema.FieldDescriptorProto_Type.TYPE_UINT64:
            case protoSchema.FieldDescriptorProto_Type.TYPE_SFIXED64:
              throw new Exception('Unsigned 64-bit integers are unsupported '
                  'in Dart.');
              break;
            case protoSchema.FieldDescriptorProto_Type.TYPE_ENUM:
              typeRef = _typeFromProtoName(field.typeName, proto.package,
                  config.depsByPackage);
              break;
            default:
              throw new Exception('Unknown: ${field.name} / ${field.type}');
          }
          if (field.label ==
              protoSchema.FieldDescriptorProto_Label.LABEL_REPEATED) {
            typeRef = new TypeRef.list(typeRef);
          }
          schema.properties[field.name] =
              new Field(field.name, 'Desc', typeRef, '${field.number}',
                  key: '${field.number}');
        });
        api.types[schema.name] = schema;
        
        // Add dependencies to the IR.
        config
          .depsByImport
          .values
          .forEach((dep) => api.dependencies[dep.prefix] = dep.importPackage);
      });
      proto.service.forEach((serviceDef) {
        var resource = new Resource(serviceDef.name);
        serviceDef.method.forEach((methodDef) {
          var httpPath = new Path('${serviceDef.name}/${methodDef.name}');
          var reqType = _typeFromProtoName(methodDef.inputType, proto.package,
              config.depsByPackage);
          var respType = _typeFromProtoName(methodDef.outputType, proto.package,
              config.depsByPackage);
          resource.methods[methodDef.name] =
              new Method(methodDef.name, httpPath, 'POST', reqType, respType);
          if (reqType is DependencyTypeRef) {
            api.rpcExternalDependencies.add(reqType as DependencyTypeRef);
          }
          if (respType is DependencyTypeRef) {
            api.rpcExternalDependencies.add(respType as DependencyTypeRef);
          }
        });
        api.resources[serviceDef.name] = resource;
      });
      return api;
    });
}

/// Prefixes all nested message/enum's name with the parent name to avoid name
/// collision.
void _prefixNestedMessagesAndEnums(DescriptorProto message) {
  var namePrefix = message.name;
  message.nestedType.forEach((m) => m.name = '${namePrefix}${m.name}');
  message.enumType.forEach((e) => e.name = '${namePrefix}${e.name}');
  message.nestedType.forEach((m) => _prefixNestedMessagesAndEnums(m));
}

/// Returns all messages defined in a proto file, including nested messages.
List<DescriptorProto> _getAllMessages(FileDescriptorProto protoFile) {
  var allMessages = [];
  allMessages.addAll(protoFile.messageType);
  protoFile.messageType.forEach((message)
    => allMessages.addAll(_getAllNestedMessages(message)));
  return allMessages;
}

/// Returns all messages nested in a message. Including the nested messages of
/// each directly nested message, and so on.
List<DescriptorProto> _getAllNestedMessages(DescriptorProto message) {
  var allMessages = [];
  allMessages.addAll(message.nestedType);
  message.nestedType.forEach((nestedMessage)
    => allMessages.addAll(_getAllNestedMessages(nestedMessage)));
  return allMessages;
}

/// Validates that all messages/enums have unique names. Note that the compiler
/// prefixes the nested messages/enums with their parent message. However, this
/// does not guarantee uniqueness of the names.
void validateNameUnique(List<DescriptorProto> messages,
    List<EnumDescriptorProto> enums) {

  var names = messages
    .map((m) => m.name)
    .toList();
  names.addAll(enums.map((e) => e.name).toList());

  int nameCount = names.length;
  int uniqueNameCount = names.toSet().length;
  if (nameCount != uniqueNameCount) {
    throw new Exception('Found name collision in $names');
  }
}

/// Returns all enum defined in a proto file, including nested messages.
List<EnumDescriptorProto> _getAllEnums(FileDescriptorProto protoFile) {
  var allEnums = [];
  allEnums.addAll(protoFile.enumType);
  protoFile.messageType.forEach((message)
    => allEnums.addAll(_getAllNestedEnums(message)));
  return allEnums;
}

/// Returns all enums nested in a message. Including the nested enums of
/// each directly nested message, and so on.
List<EnumDescriptorProto> _getAllNestedEnums(DescriptorProto message) {
  var allEnums = [];
  allEnums.addAll(message.enumType);
  message.nestedType.forEach((nestedMessage)
    => allEnums.addAll(_getAllNestedEnums(nestedMessage)));
  return allEnums;
}

/// Looks up the package given a [typeName] who contains the package, from
/// either the current package or from one of the dependencies. Throw an error
/// if the package cannot be found.
String _lookupPackage(String typeName, String currentPackage,
    Map depsByPackage) {

  if (typeName.contains(currentPackage)) {
    return currentPackage;
  }
  for (var package in depsByPackage.keys) {
    if (typeName.contains(package)) {
      return package;
    }
  };
  throw new Exception('Unknown type: $typeName. Did you forget a '
    'dependency in your .streamy.yaml file?');
}

/// Returns the [TypeRef] for a proto message type.
TypeRef _typeFromProtoName(String typeName, String currentPackage,
    Map depsByPackage) {

  // Proto compiler type path starts with '.', but in [depsByPackage] the
  // package names do not.
  if (typeName[0] == '.') {
    typeName = typeName.replaceFirst('.', '');
  }
  var package = _lookupPackage(typeName, currentPackage, depsByPackage);
  var shortTypeName = typeName
    .replaceFirst(package, '') // Remove the package from the type name.
    .replaceAll('.', ''); // Remove the remaining '.' afterwards. Nested
                          // messages' names are joined with their containing
                          // message's name..
  var isCurrent = package == currentPackage;
  if (isCurrent) {
    return new TypeRef.schema(shortTypeName);
  } else {
    var importPrefix = depsByPackage[package].prefix;
    return new TypeRef.dependency(shortTypeName, importPrefix);
  }
}
