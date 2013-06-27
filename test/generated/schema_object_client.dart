/**
 * WARNING: This code was generated from templates in
 * folder templates. Do not edit by hand.
 */
library schema_object;
import "dart:async";
import "dart:json";
import "package:streamy/base.dart" as base;
import "package:streamy/comparable.dart";
Map<String, base.TypeInfo> TYPE_REGISTRY = {
};

class Foo extends base.EntityWrapper {
  static final List<String> KNOWN_PROPERTIES = [
    "id",
    "bar",
    "baz",
    "qux",
    "quux",
  ];
  Foo() : super.wrap(new base.RawEntity(), (cloned) => new Foo._wrap(cloned));
  Foo._wrap(base.Entity entity) : super.wrap(entity, (cloned) => new Foo._wrap(cloned));
  Foo.wrap(base.Entity entity, base.EntityWrapperCloneFn cloneWrapper) :
      super.wrap(entity, (cloned) => cloneWrapper(cloned));
  int get id => this["id"];
  set id(int value) {
    this["id"] = value;
  }
  int removeId() => this.remove("id");
  String get bar => this["bar"];
  set bar(String value) {
    this["bar"] = value;
  }
  String removeBar() => this.remove("bar");
  int get baz => this["baz"];
  set baz(int value) {
    this["baz"] = value;
  }
  int removeBaz() => this.remove("baz");
  double get qux => this["qux"];
  set qux(double value) {
    this["qux"] = value;
  }
  double removeQux() => this.remove("qux");
  List<int> get quux => this["quux"];
  set quux(List<int> value) {
    this["quux"] = value;
  }
  List<int> removeQuux() => this.remove("quux");
  factory Foo.fromJsonString(String strJson) => new Foo.fromJson(parse(strJson));
  factory Foo.fromJson(Map json) {
    if (json == null) {
      return null;
    }
    json = new Map.from(json);
    var result = new Foo()
      ..id = json.remove("id")
      ..bar = json.remove("bar")
      ..baz = json.remove("baz")
      ..qux = base.nullSafeOperation(json.remove("qux"), double.parse)
      ..quux = base.nullSafeMapToList(json.remove("quux"), (val) => base.nullSafeOperation(val, int.parse))
;
    base.addUnknownProperties(result, json, TYPE_REGISTRY);
    return result;
  }
  Map toJson() {
    Map map = super.toJson();
    if (map.containsKey("qux")) {
      map["qux"] = map["qux"].toString();
    }
    if (map.containsKey("quux")) {
      map["quux"] = base.nullSafeMapToList(map["quux"], (o) => o.toString());
    }
;
    return map;
  }
  Foo clone() => new Foo._wrap(super.clone());
  Type get streamyType => Foo;
}

class Bar extends base.EntityWrapper {
  static final List<String> KNOWN_PROPERTIES = [
    "foos",
  ];
  Bar() : super.wrap(new base.RawEntity(), (cloned) => new Bar._wrap(cloned));
  Bar._wrap(base.Entity entity) : super.wrap(entity, (cloned) => new Bar._wrap(cloned));
  Bar.wrap(base.Entity entity, base.EntityWrapperCloneFn cloneWrapper) :
      super.wrap(entity, (cloned) => cloneWrapper(cloned));
  List<Foo> get foos => this["foos"];
  set foos(List<Foo> value) {
    this["foos"] = value;
  }
  List<Foo> removeFoos() => this.remove("foos");
  factory Bar.fromJsonString(String strJson) => new Bar.fromJson(parse(strJson));
  factory Bar.fromJson(Map json) {
    if (json == null) {
      return null;
    }
    json = new Map.from(json);
    var result = new Bar()
      ..foos = base.nullSafeMapToList(json.remove("foos"), (val) => new Foo.fromJson(val))
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
class SchemaObjectTest extends base.Root {
  final base.RequestHandler requestHandler;
  final String servicePath;
  SchemaObjectTest(this.requestHandler, {this.servicePath: "schemaObjectTest/v1/"}) {
  }
  Stream send(base.Request request) => requestHandler.handle(request);
}
