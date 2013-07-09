/**
 * WARNING: This code was generated from templates in
 * folder templates. Do not edit by hand.
 */
library schema_object;
import "dart:async";
import "dart:json";
import "package:streamy/streamy.dart" as streamy;
import "package:streamy/collections.dart";
Map<String, streamy.TypeInfo> TYPE_REGISTRY = {
};

class Foo extends streamy.EntityWrapper {
  static final List<String> KNOWN_PROPERTIES = [
    "id",
    "bar",
    "baz",
    "qux",
    "quux",
  ];
  Foo() : super.wrap(new streamy.RawEntity(), (cloned) => new Foo._wrap(cloned));
  Foo._wrap(streamy.Entity entity) : super.wrap(entity, (cloned) => new Foo._wrap(cloned));
  Foo.wrap(streamy.Entity entity, streamy.EntityWrapperCloneFn cloneWrapper) :
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
  String get qux => this["qux"];
  set qux(String value) {
    this["qux"] = value;
  }
  String removeQux() => this.remove("qux");
  List<double> get quux => this["quux"];
  set quux(List<double> value) {
    this["quux"] = value;
  }
  List<double> removeQuux() => this.remove("quux");
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
      ..qux = json.remove("qux")
      ..quux = streamy.nullSafeMapToList(json.remove("quux"), (val) => streamy.nullSafeOperation(val, double.parse))
;
    streamy.addUnknownProperties(result, json, TYPE_REGISTRY);
    return result;
  }
  Map toJson() {
    Map map = super.toJson();
    if (map.containsKey("quux")) {
      map["quux"] = streamy.nullSafeMapToList(map["quux"], (o) => o.toString());
    }
;
    return map;
  }
  Foo clone() => new Foo._wrap(super.clone());
  Type get streamyType => Foo;
}

class Bar extends streamy.EntityWrapper {
  static final List<String> KNOWN_PROPERTIES = [
    "foos",
  ];
  Bar() : super.wrap(new streamy.RawEntity(), (cloned) => new Bar._wrap(cloned));
  Bar._wrap(streamy.Entity entity) : super.wrap(entity, (cloned) => new Bar._wrap(cloned));
  Bar.wrap(streamy.Entity entity, streamy.EntityWrapperCloneFn cloneWrapper) :
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
      ..foos = streamy.nullSafeMapToList(json.remove("foos"), (val) => new Foo.fromJson(val))
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
class SchemaObjectTest extends streamy.Root {
  final streamy.RequestHandler requestHandler;
  final String servicePath;
  SchemaObjectTest(this.requestHandler, {this.servicePath: "schemaObjectTest/v1/"}) {
  }
  Stream send(streamy.Request request) => requestHandler.handle(request);
}
