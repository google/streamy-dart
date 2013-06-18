/**
 * WARNING: This code was generated from templates in
 * folder templates. Do not edit by hand.
 */
library schema_unknown_fields;
import "dart:async";
import "dart:json";
import "package:third_party/dart/streamy/lib/base.dart" as base;
import "package:third_party/dart/streamy/lib/comparable.dart";
Map<String, base.TypeInfo> TYPE_REGISTRY = {
  "type#foo": new base.TypeInfo((Map json) => new Foo.fromJson(json)),
  "type#bar": new base.TypeInfo((Map json) => new Bar.fromJson(json)),
};

class Foo extends base.EntityWrapper {
  static final List<String> KNOWN_PROPERTIES = [
    "baz",
  ];
  Foo() : super.wrap(new base.RawEntity(), (cloned) => new Foo._wrap(cloned));
  Foo._wrap(base.Entity entity) : super.wrap(entity, (cloned) => new Foo._wrap(cloned));
  Foo.wrap(base.Entity entity, base.EntityWrapperCloneFn cloneWrapper) :
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
    base.addUnknownProperties(result, json, TYPE_REGISTRY);
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

class Bar extends base.EntityWrapper {
  static final List<String> KNOWN_PROPERTIES = [
  ];
  Bar() : super.wrap(new base.RawEntity(), (cloned) => new Bar._wrap(cloned));
  Bar._wrap(base.Entity entity) : super.wrap(entity, (cloned) => new Bar._wrap(cloned));
  Bar.wrap(base.Entity entity, base.EntityWrapperCloneFn cloneWrapper) :
      super.wrap(entity, (cloned) => cloneWrapper(cloned));
  factory Bar.fromJsonString(String strJson) => new Bar.fromJson(parse(strJson));
  factory Bar.fromJson(Map json) {
    if (json == null) {
      return null;
    }
    json = new Map.from(json);
    var result = new Bar()
;
    base.addUnknownProperties(result, json, TYPE_REGISTRY);
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
class SchemaUnknownFieldsTest extends base.Root {
  base.RequestHandler requestHandler;
  SchemaUnknownFieldsTest(this.requestHandler) {
  }
  Stream send(base.Request request) {
    return requestHandler.handle(request);
  }
}
