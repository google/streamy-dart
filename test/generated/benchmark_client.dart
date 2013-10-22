/**
 * WARNING: This code was generated from templates in
 * folder templates. Do not edit by hand.
 */
library benchmark;
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
  Bar get bar => this['bar'];
  set bar(Bar value) {
    this['bar'] = value;
  }
  Bar removeBar() => this.remove('bar');

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
  List<int> get corge => this['corge'];
  set corge(List<int> value) {
    if (value is! obs.ObservableList) {
      value = new obs.ObservableList.from(value);
    }
    this['corge'] = value;
  }
  List<int> removeCorge() => this.remove('corge');
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
    result.bar = new Bar.fromJson(result['bar']);
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
    list = result['corge'];
    if (list != null) {
    }
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
  Foo clone() => new Foo._wrap(super.clone());
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
  Bar clone() => new Bar._wrap(super.clone());
  Type get streamyType => Bar;
}

abstract class SchemaObjectTestResourcesMixin {
}

class SchemaObjectTest
    extends streamy.Root
    with SchemaObjectTestResourcesMixin {
  final streamy.TransactionStrategy _txStrategy;
  final streamy.RequestHandler requestHandler;
  SchemaObjectTest(
      this.requestHandler,
      {String servicePath: 'schemaObjectTest/v1/',
      streamy.TypeRegistry typeRegistry: streamy.EMPTY_REGISTRY,
      streamy.TransactionStrategy txStrategy: null}) :
          super(typeRegistry, servicePath),
          this._txStrategy = txStrategy;
  Stream send(streamy.Request request) => requestHandler.handle(request);
  SchemaObjectTestTransaction beginTransaction() =>
      new SchemaObjectTestTransaction(typeRegistry, servicePath,
          _txStrategy.beginTransaction());
}

/// Provides the same API as [SchemaObjectTest] but runs all requests as
/// part of the same transaction.
class SchemaObjectTestTransaction
    extends streamy.TransactionRoot
    with SchemaObjectTestResourcesMixin {
  SchemaObjectTestTransaction(
      streamy.TypeRegistry typeRegistry,
      String servicePath,
      streamy.Transaction tx) : super(typeRegistry, servicePath, tx);
}
