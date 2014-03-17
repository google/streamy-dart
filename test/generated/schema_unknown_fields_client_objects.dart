/**
 * WARNING: GENERATED CODE. DO NOT EDIT BY HAND.
 * 
 */
library schemaunknownfieldstest.objects;
import 'package:fixnum/fixnum.dart' as fixnum;
import 'package:streamy/base.dart' as base;
import 'package:streamy/streamy.dart' as streamy;
import 'package:observe/observe.dart' as obs;

/// An EntityGlobalFn for Foo entities.
typedef dynamic FooGlobalFn(Foo entity);

class Foo extends base.EntityBase {
  static final Set<String> KNOWN_PROPERTIES = new Set<String>.from([
    r'baz',
  ]);
  static final String KIND = """type#foo""";
  String get apiType => r'Foo';

  /// Add a global computed synthetic property to this entity type, optionally memoized.
  static void addGlobal(String name, FooGlobalFn computeFn,
      {bool memoize: false, List dependencies: null}) {
    streamy.GlobalView.register(Foo, name, new streamy.GlobalRegistration(computeFn, dependencies, memoize));
  }
  Foo() : this.wrapMap(<String, dynamic>{});
  Foo.wrapMap(Map map) {
    base.setMap(this, map);
  }

  /// Foo's favorite baz.
  String get baz => this[r'baz'];
  set baz(String value) {
    this[r'baz'] = value;
  }
  String removeBaz() => remove(r'baz');
  factory Foo.fromJsonString(String strJson, streamy.Trace trace,
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
      json = new Map.from(json);
    }
    streamy.deserializeUnknown(json, KNOWN_PROPERTIES, typeRegistry);
    return new Foo.wrapMap(json);
  }
  Map toJson() {
    Map json = new Map.from(base.getMap(this));
    return json;
  }
  Foo clone() => copyInto(new Foo());
  Foo patch() => super.patch();
  Type get streamyType => Foo;
}

/// An EntityGlobalFn for Bar entities.
typedef dynamic BarGlobalFn(Bar entity);

class Bar extends base.EntityBase {
  static final Set<String> KNOWN_PROPERTIES = new Set<String>.from([
  ]);
  static final String KIND = """type#bar""";
  String get apiType => r'Bar';

  /// Add a global computed synthetic property to this entity type, optionally memoized.
  static void addGlobal(String name, BarGlobalFn computeFn,
      {bool memoize: false, List dependencies: null}) {
    streamy.GlobalView.register(Bar, name, new streamy.GlobalRegistration(computeFn, dependencies, memoize));
  }
  Bar() : this.wrapMap(<String, dynamic>{});
  Bar.wrapMap(Map map) {
    base.setMap(this, map);
  }
  factory Bar.fromJsonString(String strJson, streamy.Trace trace,
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
      json = new Map.from(json);
    }
    streamy.deserializeUnknown(json, KNOWN_PROPERTIES, typeRegistry);
    return new Bar.wrapMap(json);
  }
  Map toJson() {
    Map json = new Map.from(base.getMap(this));
    return json;
  }
  Bar clone() => copyInto(new Bar());
  Bar patch() => super.patch();
  Type get streamyType => Bar;
}
