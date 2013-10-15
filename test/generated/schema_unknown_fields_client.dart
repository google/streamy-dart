/**
 * WARNING: This code was generated from templates in
 * folder templates. Do not edit by hand.
 */
library schema_unknown_fields;
import 'dart:async';
import 'package:fixnum/fixnum.dart' as fixnum;
import 'package:streamy/streamy.dart' as streamy;
import 'package:observe/observe.dart' as obs;

class Foo extends streamy.EntityWrapper {
  static Foo _cloneFn(cloned, {bool copyOnWrite: false}) =>
    new Foo._wrap(cloned, copyOnWrite: copyOnWrite);
  static final Set<String> KNOWN_PROPERTIES = new Set<String>.from([
    'baz',
  ]);
  static final String KIND = """type#foo""";
  Foo() : super.wrap(new streamy.RawEntity(), _cloneFn);
  Foo.fromMap(Map map) : super.wrap(new streamy.RawEntity.fromMap(map), _cloneFn);
  Foo.wrapMap(obs.ObservableMap map) : super.wrap(new streamy.RawEntity.wrapMap(map), _cloneFn);
  Foo._wrap(streamy.Entity entity, {bool copyOnWrite: false}) :
      super.wrap(entity, _cloneFn, copyOnWrite: copyOnWrite);
  Foo.wrap(streamy.Entity entity, streamy.EntityWrapperCloneFn cloneWrapper) :
      super.wrap(entity, _cloneFn);

  /// Foo's favorite baz.
  String get baz => this['baz'];
  set baz(String value) {
    this['baz'] = value;
  }
  String removeBaz() => this.remove('baz');
  factory Foo.fromJsonString(String strJson,
      {streamy.TypeRegistry typeRegistry: streamy.EMPTY_REGISTRY}) =>
          new Foo.fromJson(streamy.jsonParse(strJson), typeRegistry: typeRegistry);
  static Foo entityFactory(Map json, streamy.TypeRegistry reg) =>
      new Foo.fromJson(json, typeRegistry: reg);
  factory Foo.fromJson(Map json,
      {streamy.TypeRegistry typeRegistry: streamy.EMPTY_REGISTRY, bool copy: false}) {
    if (json == null) {
      return null;
    }
    if (copy) {
      json = new obs.ObservableMap.from(json);
    }
    var list;
    var len;
    var result = new Foo.wrapMap(json);
    var fields = result.fieldNames.toList();
    fields.remove('baz');
;
    for (var i = 0; i < fields.length; i++) {
      result[fields[i]] = streamy.deserialize(result[fields[i]], typeRegistry);
    }
    return result;
  }
  Map toJson() {
    Map map = super.toJson();
;
    return map;
  }
  Foo clone({bool mutable: true, bool copyOnWrite: false}) => super.clone(mutable: mutable, copyOnWrite: copyOnWrite);
  Type get streamyType => Foo;
}

class Bar extends streamy.EntityWrapper {
  static Bar _cloneFn(cloned, {bool copyOnWrite: false}) =>
    new Bar._wrap(cloned, copyOnWrite: copyOnWrite);
  static final Set<String> KNOWN_PROPERTIES = new Set<String>.from([
  ]);
  static final String KIND = """type#bar""";
  Bar() : super.wrap(new streamy.RawEntity(), _cloneFn);
  Bar.fromMap(Map map) : super.wrap(new streamy.RawEntity.fromMap(map), _cloneFn);
  Bar.wrapMap(obs.ObservableMap map) : super.wrap(new streamy.RawEntity.wrapMap(map), _cloneFn);
  Bar._wrap(streamy.Entity entity, {bool copyOnWrite: false}) :
      super.wrap(entity, _cloneFn, copyOnWrite: copyOnWrite);
  Bar.wrap(streamy.Entity entity, streamy.EntityWrapperCloneFn cloneWrapper) :
      super.wrap(entity, _cloneFn);
  factory Bar.fromJsonString(String strJson,
      {streamy.TypeRegistry typeRegistry: streamy.EMPTY_REGISTRY}) =>
          new Bar.fromJson(streamy.jsonParse(strJson), typeRegistry: typeRegistry);
  static Bar entityFactory(Map json, streamy.TypeRegistry reg) =>
      new Bar.fromJson(json, typeRegistry: reg);
  factory Bar.fromJson(Map json,
      {streamy.TypeRegistry typeRegistry: streamy.EMPTY_REGISTRY, bool copy: false}) {
    if (json == null) {
      return null;
    }
    if (copy) {
      json = new obs.ObservableMap.from(json);
    }
    var list;
    var len;
    var result = new Bar.wrapMap(json);
    var fields = result.fieldNames.toList();
;
    for (var i = 0; i < fields.length; i++) {
      result[fields[i]] = streamy.deserialize(result[fields[i]], typeRegistry);
    }
    return result;
  }
  Map toJson() {
    Map map = super.toJson();
;
    return map;
  }
  Bar clone({bool mutable: true, bool copyOnWrite: false}) => super.clone(mutable: mutable, copyOnWrite: copyOnWrite);
  Type get streamyType => Bar;
}

class SchemaUnknownFieldsTest extends streamy.Root {
  final streamy.RequestHandler requestHandler;
  final String servicePath;
  SchemaUnknownFieldsTest(this.requestHandler, {this.servicePath: 'schemaUnknownFieldsTest/v1/',
      streamy.TypeRegistry typeRegistry: streamy.EMPTY_REGISTRY}) : super(typeRegistry);
  Stream send(streamy.Request request) => requestHandler.handle(request);
}
