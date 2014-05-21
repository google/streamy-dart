part of streamy.generator;

class Api {
  final String name;
  final String description;
  final HttpConfig httpConfig;
  final bool marshalling;
  /// External imports.
  final Map<String, String> imports = <String, String>{};
  final Map<String, Schema> types = <String, Schema>{};
  final Map<String, Resource> resources = <String, Resource>{};
  
  Api(this.name, this.description,
      {this.httpConfig, this.marshalling: true});
  
  String toString() {
    var sb = new StringBuffer()
      ..writeln("Api: $name");
    sb.writeAll(types.values);
    sb.writeAll(resources.values);
    sb.writeln();
    return sb.toString();
  }
}

class Schema {
  final String name;
  final List<TypeRef> mixins = [];
  
  final Map<String, Field> properties = <String, Field>{};
  
  Schema(this.name);
  
  String toString() {
    var sb = new StringBuffer()
      ..writeln("  Schema: $name:");
    properties.forEach((name, field) {
      sb.writeln("    $name: $field");
    });
    mixins.forEach((mixin) {
      sb.writeln("    [mixin] ${mixin.className} from ${mixin.importFrom}");
    });
    return sb.toString();
  }
}

class Resource {
  final String name;
  final String description;
  
  final Map<String, Resource> subresources = <String, Resource>{};
  final Map<String, Method> methods = <String, Method>{};
  
  Resource(this.name);
  
  String toString() => (new StringBuffer()
      ..writeln("  Resource: $name:")
      ..writeAll(methods.values))
      .toString();
}

class Method {
  final String name;
  final Path httpPath;
  final String httpMethod;
  final TypeDef payloadType;
  final TypeDef responseType;
  final Map<String, Field> parameters = <String, Field>{};
  
  Method(this.name, this.httpPath, this.httpMethod, this.payloadType, this.responseType);
  
  String toString() {
    var sb = new StringBuffer()
      ..writeln("    Method: $name ($httpMethod @ $httpPath)")
      ..writeln("      payload=$payloadType, response=$responseType");
    parameters.forEach((name, field) {
      sb.writeln("      Param[$name]: $field");
    });
    return sb.toString();
  }
}

final PATH_REGEX = new RegExp(r'{([^}]+)}');

class Path {
  final String path;
  
  Path(this.path);
  
  List<String> parameters() => PATH_REGEX
    .allMatches(path)
    .map((match) => match.group(1))
    .toList(growable: false);
  
  String toString() => path;
}

class Field {
  final String name;
  final String description;
  final TypeRef typeRef;
  final String location;
  
  Field(this.name, this.description, this.typeRef, this.location);
  
  String toString() => "type=$typeRef, loc=$location";
}

class TypeRef {
  final String base;
  
  TypeRef(this.base);
  
  const TypeRef.integer() : this('integer');
  const TypeRef.string() : this('string');
  const TypeRef.any() : this('any');
  const TypeRef.number() : this('number');
  const TypeRef.boolean() : this('boolean');
  const TypeRef.double() : this('double');
  const TypeRef.int64() : this('int64');
  factory TypeRef.list(TypeRef subType) => new ListTypeRef(subType);
  factory TypeRef.schema(String schemaClass) =>
      new SchemaTypeRef(schemaClass);
  factory TypeRef.external(String type, String importedFrom) =>
      new ExternalTypeRef(type, importedFrom);
  
      
  String toString() => base;
}

class ExternalTypeRef implements TypeRef {
  
  String get base => 'external';
  final String type;
  final String importedFrom;
  
  ExternalTypeRef(this.type, this.importedFrom);
  
  String toString() => 'external($type, $importedFrom)';
}

class SchemaTypeRef implements TypeRef {
  String get base => 'schema';
  final String schemaClass;
  
  SchemaTypeRef(this.schemaClass);
  
  String toString() => 'schema($schemaClass)';
}

class ListTypeRef implements TypeRef {
  final TypeRef subType;
  String get base => "list";
  
  ListTypeRef(this.subType);
  
  String toString() => 'list($subType)';
}

class HttpConfig {
  final String urlName;
  final String version;
  final String rootUrl;
  final String servicePath;
  
  HttpConfig(this.urlName, this.version, this.rootUrl, this.servicePath);
}