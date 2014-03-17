/**
 * WARNING: GENERATED CODE. DO NOT EDIT BY HAND.
 * 
 */
library schemaobjecttest.objects;
import 'package:fixnum/fixnum.dart' as fixnum;
import 'package:streamy/base.dart' as base;
import 'package:streamy/streamy.dart' as streamy;
import 'package:observe/observe.dart' as obs;

/// An EntityGlobalFn for Foo entities.
typedef dynamic FooGlobalFn(Foo entity);

class Foo extends base.EntityBase {
  static final Set<String> KNOWN_PROPERTIES = new Set<String>.from([
    r'id',
    r'bar',
    r'baz',
    r'cruft',
    r'qux',
    r'quux',
    r'corge',
  ]);
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

  /// Primary key.
  int get id => this[r'id'];
  set id(int value) {
    this[r'id'] = value;
  }
  int removeId() => remove(r'id');

  /// Foo's favorite bar.
  Bar get bar => this[r'bar'];
  set bar(Bar value) {
    this[r'bar'] = value;
  }
  Bar removeBar() => remove(r'bar');

  /// It's spelled buzz.
  int get baz => this[r'baz'];
  set baz(int value) {
    this[r'baz'] = value;
  }
  int removeBaz() => remove(r'baz');
  String get cruft => this[r'cruft'];
  set cruft(String value) {
    this[r'cruft'] = value;
  }
  String removeCruft() => remove(r'cruft');

  /// Not what it seems.
  fixnum.Int64 get qux => this[r'qux'];
  set qux(fixnum.Int64 value) {
    this[r'qux'] = value;
  }
  fixnum.Int64 removeQux() => remove(r'qux');

  /// The plural of qux
  List<double> get quux => this[r'quux'];
  set quux(List<double> value) {
/*
    if (value != null && value is! obs.ObservableList) {
      value = new obs.ObservableList.from(value);
    }
*/
    this[r'quux'] = value;
  }
  List<double> removeQuux() => remove(r'quux');

  /// A double field that's serialized as a number.
  List<int> get corge => this[r'corge'];
  set corge(List<int> value) {
/*
    if (value != null && value is! obs.ObservableList) {
      value = new obs.ObservableList.from(value);
    }
*/
    this[r'corge'] = value;
  }
  List<int> removeCorge() => remove(r'corge');
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
    if (json.containsKey(r'bar')) {
      json[r'bar'] = ((v) => new Bar.fromJson(v))(json[r'bar']);
    }
    if (json.containsKey(r'qux')) {
      json[r'qux'] = streamy.atoi64(json[r'qux']);
    }
    if (json.containsKey(r'quux')) {
      json[r'quux'] = streamy.mapInline(streamy.atod)(json[r'quux']);
    }
    streamy.deserializeUnknown(json, KNOWN_PROPERTIES, typeRegistry);
    return new Foo.wrapMap(json);
  }
  Map toJson() {
    Map json = new Map.from(base.getMap(this));
    streamy.serialize(json, r'qux', streamy.str);
    streamy.serialize(json, r'quux', streamy.mapCopy(streamy.str));
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
    r'foos',
    r'foo',
  ]);
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

  /// A bunch of foos.
  List<Foo> get foos => this[r'foos'];
  set foos(List<Foo> value) {
/*
    if (value != null && value is! obs.ObservableList) {
      value = new obs.ObservableList.from(value);
    }
*/
    this[r'foos'] = value;
  }
  List<Foo> removeFoos() => remove(r'foos');
  Foo get foo => this[r'foo'];
  set foo(Foo value) {
    this[r'foo'] = value;
  }
  Foo removeFoo() => remove(r'foo');
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
    if (json.containsKey(r'foos')) {
      json[r'foos'] = streamy.mapInline(((v) => new Foo.fromJson(v)))(json[r'foos']);
    }
    if (json.containsKey(r'foo')) {
      json[r'foo'] = ((v) => new Foo.fromJson(v))(json[r'foo']);
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
