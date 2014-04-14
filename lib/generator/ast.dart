part of streamy.generator;

class Api {
  final String name;
  final String description;
  final String urlName;
  final String version;
  final String rootUrl;
  
  final Map<String, Schema> types = <String, Schema>{};
  final Map<String, Resource> resources = <String, Resource>{};
  
  Api(this.name, this.description, this.urlName, this.version, this.rootUrl);
  
  String toString() {
    var sb = new StringBuffer()
      ..writeln("Api: $name (urlName=$urlName, v=$version, root=$rootUrl)");
    sb.writeAll(types.values);
    sb.writeAll(resources.values);
    sb.writeln();
    return sb.toString();
  }
}

class Schema {
  final String name;
  
  final Map<String, Field> properties = <String, Field>{};
  
  Schema(this.name);
  
  String toString() {
    var sb = new StringBuffer()
      ..writeln("  Schema: $name:");
    properties.forEach((name, field) {
      sb.writeln("    $name: $field");
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
  final String httpPath;
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

const PATH_REGEX = const Regexp(r'{([^}]+)}');

class Path {
  final String fullPath;
  
  List<String> parameters() => PATH_REGEX
    .allMatches(fullPath)
    .map((match) => match.group(1))
    .toList(growable: false);
}

class Field {
  final String description;
  final TypeRef typeRef;
  
  Field(this.description, this.typeRef);
  
  String toString() => "type=$typeRef";
}

class TypeRef {
  final String dartType;
  
  TypeRef(this.dartType);
  
  const TypeRef.integer() : this('int');
  const TypeRef.string() : this('String');
  const TypeRef.any() : this('dynamic');
  const TypeRef.number() : this('num');
  const TypeRef.boolean() : this('bool');
  const TypeRef.double() : this('double');
  const TypeRef.int64() : this('fixnum.Int64');
  factory TypeRef.list(TypeRef subType) => new ListTypeRef(subType);
  factory TypeRef.schema(String importPrefix, String schemaClass)
      => new SchemaTypeRef(importPrefix, schemaClass);
      
  String toString() => dartType;
}

class SchemaTypeRef implements TypeRef {
  final String importPrefix;
  final String schemaClass;
  String get dartType => "$importPrefix$schemaClass";
  
  SchemaTypeRef(this.importPrefix, this.schemaClass);
  
  String toString() => dartType;
}

class ListTypeRef implements TypeRef {
  final TypeRef subType;
  String get dartType => "List<${subType.dartType}>";
  
  ListTypeRef(this.subType);
  
  String toString() => dartType;
}
