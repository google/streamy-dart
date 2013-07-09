/**
 * WARNING: This code was generated from templates in
 * folder templates. Do not edit by hand.
 */
library schema_unknown_fields;
import "dart:async";
import "dart:json";
import "package:streamy/streamy.dart" as streamy;
import "package:streamy/collections.dart";
Map<String, streamy.TypeInfo> TYPE_REGISTRY = {
  "type#foo": new streamy.TypeInfo((Map json) => new Foo.fromJson(json)),
  "type#bar": new streamy.TypeInfo((Map json) => new Bar.fromJson(json)),
};

class Foo extends streamy.EntityWrapper {
  static final List<String> KNOWN_PROPERTIES = [
    "baz",
  ];
  Foo() : super.wrap(new streamy.RawEntity(), (cloned) => new Foo._wrap(cloned));
  Foo._wrap(streamy.Entity entity) : super.wrap(entity, (cloned) => new Foo._wrap(cloned));
  Foo.wrap(streamy.Entity entity, streamy.EntityWrapperCloneFn cloneWrapper) :
      super.wrap(entity, (cloned) => cloneWrapper(cloned));
  String get baz => this["baz"];
  set baz(String value) {
    this["baz"] = value;
  }
  String removeBaz() => this.remove("baz");
  factory Foo.fromJsonString(String strJson) => new Foo.fromJson(parse(strJson));
  factory Foo.fromJson(Map json) {
    if (json == null) {
      return null;
    }
    json = new Map.from(json);
    var result = new Foo()
      ..baz = json.remove("baz")
;
    streamy.addUnknownProperties(result, json, TYPE_REGISTRY);
    return result;
  }
  Map toJson() {
    Map map = super.toJson();
;
    return map;
  }
  Foo clone() => new Foo._wrap(super.clone());
  Type get streamyType => Foo;
}

class Bar extends streamy.EntityWrapper {
  static final List<String> KNOWN_PROPERTIES = [
  ];
  Bar() : super.wrap(new streamy.RawEntity(), (cloned) => new Bar._wrap(cloned));
  Bar._wrap(streamy.Entity entity) : super.wrap(entity, (cloned) => new Bar._wrap(cloned));
  Bar.wrap(streamy.Entity entity, streamy.EntityWrapperCloneFn cloneWrapper) :
      super.wrap(entity, (cloned) => cloneWrapper(cloned));
  factory Bar.fromJsonString(String strJson) => new Bar.fromJson(parse(strJson));
  factory Bar.fromJson(Map json) {
    if (json == null) {
      return null;
    }
    json = new Map.from(json);
    var result = new Bar()
;
    streamy.addUnknownProperties(result, json, TYPE_REGISTRY);
    return result;
  }
  Map toJson() {
    Map map = super.toJson();
;
    return map;
  }
  Bar clone() => new Bar._wrap(super.clone());
  Type get streamyType => Bar;
}

/// Entry point to all API services for the application.
class SchemaUnknownFieldsTest extends streamy.Root {
  final streamy.RequestHandler requestHandler;
  final String servicePath;
  SchemaUnknownFieldsTest(this.requestHandler, {this.servicePath: "schemaUnknownFieldsTest/v1/"}) {
  }
  Stream send(streamy.Request request) => requestHandler.handle(request);
}
