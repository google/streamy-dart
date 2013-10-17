/**
 * WARNING: This code was generated from templates in
 * folder templates. Do not edit by hand.
 */
library schema_object;
import 'dart:async';
import 'package:fixnum/fixnum.dart' as fixnum;
import 'package:streamy/streamy.dart' as streamy;
import 'package:quiver/collection.dart' as collect;
import 'package:observe/observe.dart' as obs;

class Foo extends streamy.EntityWrapper {
  static final Set<String> KNOWN_PROPERTIES = new Set<String>.from([
    'id',
    'bar',
    'baz',
    'qux',
    'quux',
    'corge',
  ]);
  Foo() : super.wrap(new streamy.RawEntity(), (cloned) => new Foo._wrap(cloned));
  Foo.fromMap(Map map) : super.wrap(new streamy.RawEntity.fromMap(map), (cloned) => new Foo._wrap(cloned));
  Foo.wrapMap(obs.ObservableMap map) : super.wrap(new streamy.RawEntity.wrapMap(map), (cloned) => new Foo._wrap(cloned));
  Foo._wrap(streamy.Entity entity) : super.wrap(entity, (cloned) => new Foo._wrap(cloned));
  Foo.wrap(streamy.Entity entity, streamy.EntityWrapperCloneFn cloneWrapper) :
      super.wrap(entity, (cloned) => cloneWrapper(cloned));

  /// Primary key.
  int get id => this['id'];
  set id(int value) {
    this['id'] = value;
  }
  int removeId() => this.remove('id');

  /// Foo's favorite bar.
  String get bar => this['bar'];
  set bar(String value) {
    this['bar'] = value;
  }
  String removeBar() => this.remove('bar');

  /// It's spelled buzz.
  int get baz => this['baz'];
  set baz(int value) {
    this['baz'] = value;
  }
  int removeBaz() => this.remove('baz');

  /// Not what it seems.
  fixnum.Int64 get qux => this['qux'];
  set qux(fixnum.Int64 value) {
    this['qux'] = value;
  }
  fixnum.Int64 removeQux() => this.remove('qux');

  /// The plural of qux
  List<double> get quux => this['quux'];
  set quux(List<double> value) {
    if (value is! obs.ObservableList) {
      value = new obs.ObservableList.from(value);
    }
    this['quux'] = value;
  }
  List<double> removeQuux() => this.remove('quux');

  /// A double field that's serialized as a number.
  double get corge => this['corge'];
  set corge(double value) {
    this['corge'] = value;
  }
  double removeCorge() => this.remove('corge');
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
    fields.remove('id');
    fields.remove('bar');
    fields.remove('baz');
    result.qux = (result['qux'] != null) ? fixnum.Int64.parseInt(result['qux']) : null;
    fields.remove('qux');
    list = result['quux'];
    if (list != null) {
      list = result['quux'];
      len = list.length;
      for (var i = 0; i < len; i++) {
        list[i] = double.parse(list[i]);
      }
    }
    fields.remove('quux');
    fields.remove('corge');
;
    for (var i = 0; i < fields.length; i++) {
      result[fields[i]] = streamy.deserialize(result[fields[i]], typeRegistry);
    }
    return result;
  }
  Map toJson() {
    Map map = super.toJson();
    if (map.containsKey('qux')) {
      map['qux'] = map['qux'].toString();
    }
    if (map.containsKey('quux')) {
      map['quux'] = streamy.nullSafeMapToList(map['quux'], (o) => o.toString());
    }
;
    return map;
  }
  Foo clone({bool mutable: true}) => new Foo._wrap(super.clone(mutable: mutable));
  Type get streamyType => Foo;
}

class Bar extends streamy.EntityWrapper {
  static final Set<String> KNOWN_PROPERTIES = new Set<String>.from([
    'foos',
  ]);
  Bar() : super.wrap(new streamy.RawEntity(), (cloned) => new Bar._wrap(cloned));
  Bar.fromMap(Map map) : super.wrap(new streamy.RawEntity.fromMap(map), (cloned) => new Bar._wrap(cloned));
  Bar.wrapMap(obs.ObservableMap map) : super.wrap(new streamy.RawEntity.wrapMap(map), (cloned) => new Bar._wrap(cloned));
  Bar._wrap(streamy.Entity entity) : super.wrap(entity, (cloned) => new Bar._wrap(cloned));
  Bar.wrap(streamy.Entity entity, streamy.EntityWrapperCloneFn cloneWrapper) :
      super.wrap(entity, (cloned) => cloneWrapper(cloned));

  /// A bunch of foos.
  List<Foo> get foos => this['foos'];
  set foos(List<Foo> value) {
    if (value is! obs.ObservableList) {
      value = new obs.ObservableList.from(value);
    }
    this['foos'] = value;
  }
  List<Foo> removeFoos() => this.remove('foos');
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
    list = result['foos'];
    if (list != null) {
      len = list.length;
      for (var i = 0; i < len; i++) {
        list[i] = new Foo.fromJson(list[i]);
      }
    }
    fields.remove('foos');
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
  Bar clone({bool mutable: true}) => new Bar._wrap(super.clone(mutable: mutable));
  Type get streamyType => Bar;
}

class SchemaObjectTest extends streamy.Root {
  final streamy.RequestHandler requestHandler;
  final String servicePath;
  SchemaObjectTest(this.requestHandler, {this.servicePath: 'schemaObjectTest/v1/',
      streamy.TypeRegistry typeRegistry: streamy.EMPTY_REGISTRY}) : super(typeRegistry);
  Stream send(streamy.Request request) => requestHandler.handle(request);
}
