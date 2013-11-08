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

/// An EntityGlobalFn for Foo entities.
typedef dynamic FooGlobalFn(Foo entity);

class Foo extends streamy.EntityWrapper {
  static final Map<String, streamy.GlobalRegistration> _globals = <String, streamy.GlobalRegistration>{};
  static final Set<String> KNOWN_PROPERTIES = new Set<String>.from([
    r'id',
    r'bar',
    r'baz',
    r'qux',
    r'quux',
    r'corge',
  ]);
  String get apiType => r'Foo';

  /// Add a global computed synthetic property to this entity type, optionally memoized.
  static void addGlobal(String name, FooGlobalFn computeFn,
      {bool memoize: false, List dependencies: null}) {
    if (memoize) {
      if (dependencies != null) {
        throw new ArgumentError('Memoized function should not have dependencies.');
      }
      _globals[name] = new streamy.GlobalRegistration(streamy.memoizeGlobalFn(computeFn));
    } else {
      _globals[name] = new streamy.GlobalRegistration(computeFn, dependencies);
    }
  }
  Foo() : super.wrap(new streamy.RawEntity(), (cloned) => new Foo._wrap(cloned), globals: _globals);
  Foo.fromMap(Map map) : super.wrap(new streamy.RawEntity.fromMap(map), (cloned) => new Foo._wrap(cloned), globals: _globals);
  Foo.wrapMap(obs.ObservableMap map) : super.wrap(new streamy.RawEntity.wrapMap(map), (cloned) => new Foo._wrap(cloned), globals: _globals);
  Foo._wrap(streamy.Entity entity) : super.wrap(entity, (cloned) => new Foo._wrap(cloned), globals: _globals);
  Foo.wrap(streamy.Entity entity, streamy.EntityWrapperCloneFn cloneWrapper) :
      super.wrap(entity, (cloned) => cloneWrapper(cloned), globals: _globals);

  /// Primary key.
  int get id => this[r'id'];
  set id(int value) {
    this[r'id'] = value;
  }
  int removeId() => this.remove(r'id');

  /// Foo's favorite bar.
  Bar get bar => this[r'bar'];
  set bar(Bar value) {
    this[r'bar'] = value;
  }
  Bar removeBar() => this.remove(r'bar');

  /// It's spelled buzz.
  int get baz => this[r'baz'];
  set baz(int value) {
    this[r'baz'] = value;
  }
  int removeBaz() => this.remove(r'baz');

  /// Not what it seems.
  fixnum.Int64 get qux => this[r'qux'];
  set qux(fixnum.Int64 value) {
    this[r'qux'] = value;
  }
  fixnum.Int64 removeQux() => this.remove(r'qux');

  /// The plural of qux
  List<double> get quux => this[r'quux'];
  set quux(List<double> value) {
    if (value is! obs.ObservableList) {
      value = new obs.ObservableList.from(value);
    }
    this[r'quux'] = value;
  }
  List<double> removeQuux() => this.remove(r'quux');

  /// A double field that's serialized as a number.
  List<int> get corge => this[r'corge'];
  set corge(List<int> value) {
    if (value is! obs.ObservableList) {
      value = new obs.ObservableList.from(value);
    }
    this[r'corge'] = value;
  }
  List<int> removeCorge() => this.remove(r'corge');
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
      json = new obs.ObservableMap.from(json);
    }
    var list;
    var len;
    var result = new Foo.wrapMap(json);
    var fields = result.fieldNames.toList();
    fields.remove(r'id');
    result.bar = new Bar.fromJson(result[r'bar']);
    fields.remove(r'bar');
    fields.remove(r'baz');
    result.qux = (result[r'qux'] != null) ? fixnum.Int64.parseInt(result[r'qux']) : null;
    fields.remove(r'qux');
    list = result[r'quux'];
    if (list != null) {
      list = result[r'quux'];
      len = list.length;
      for (var i = 0; i < len; i++) {
        list[i] = double.parse(list[i]);
      }
    }
    fields.remove(r'quux');
    list = result[r'corge'];
    if (list != null) {
    }
    fields.remove(r'corge');
;
    for (var i = 0; i < fields.length; i++) {
      result[fields[i]] = streamy.deserialize(result[fields[i]], typeRegistry);
    }
    return result;
  }
  Map toJson() {
    Map map = super.toJson();
    if (map.containsKey(r'qux')) {
      map[r'qux'] = map[r'qux'].toString();
    }
    if (map.containsKey(r'quux')) {
      map[r'quux'] = streamy.nullSafeMapToList(map[r'quux'], (o) => o.toString());
    }
;
    return map;
  }
  Foo clone() => new Foo._wrap(super.clone());
  Type get streamyType => Foo;
}

/// An EntityGlobalFn for Bar entities.
typedef dynamic BarGlobalFn(Bar entity);

class Bar extends streamy.EntityWrapper {
  static final Map<String, streamy.GlobalRegistration> _globals = <String, streamy.GlobalRegistration>{};
  static final Set<String> KNOWN_PROPERTIES = new Set<String>.from([
    r'foos',
  ]);
  String get apiType => r'Bar';

  /// Add a global computed synthetic property to this entity type, optionally memoized.
  static void addGlobal(String name, BarGlobalFn computeFn,
      {bool memoize: false, List dependencies: null}) {
    if (memoize) {
      if (dependencies != null) {
        throw new ArgumentError('Memoized function should not have dependencies.');
      }
      _globals[name] = new streamy.GlobalRegistration(streamy.memoizeGlobalFn(computeFn));
    } else {
      _globals[name] = new streamy.GlobalRegistration(computeFn, dependencies);
    }
  }
  Bar() : super.wrap(new streamy.RawEntity(), (cloned) => new Bar._wrap(cloned), globals: _globals);
  Bar.fromMap(Map map) : super.wrap(new streamy.RawEntity.fromMap(map), (cloned) => new Bar._wrap(cloned), globals: _globals);
  Bar.wrapMap(obs.ObservableMap map) : super.wrap(new streamy.RawEntity.wrapMap(map), (cloned) => new Bar._wrap(cloned), globals: _globals);
  Bar._wrap(streamy.Entity entity) : super.wrap(entity, (cloned) => new Bar._wrap(cloned), globals: _globals);
  Bar.wrap(streamy.Entity entity, streamy.EntityWrapperCloneFn cloneWrapper) :
      super.wrap(entity, (cloned) => cloneWrapper(cloned), globals: _globals);

  /// A bunch of foos.
  List<Foo> get foos => this[r'foos'];
  set foos(List<Foo> value) {
    if (value is! obs.ObservableList) {
      value = new obs.ObservableList.from(value);
    }
    this[r'foos'] = value;
  }
  List<Foo> removeFoos() => this.remove(r'foos');
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
      json = new obs.ObservableMap.from(json);
    }
    var list;
    var len;
    var result = new Bar.wrapMap(json);
    var fields = result.fieldNames.toList();
    list = result[r'foos'];
    if (list != null) {
      len = list.length;
      for (var i = 0; i < len; i++) {
        list[i] = new Foo.fromJson(list[i]);
      }
    }
    fields.remove(r'foos');
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
  String get apiType => r'SchemaObjectTest';
  final streamy.TransactionStrategy _txStrategy;
  final streamy.RequestHandler requestHandler;
  final streamy.Tracer _tracer;
  SchemaObjectTest(
      this.requestHandler,
      {String servicePath: 'schemaObjectTest/v1/',
      streamy.TypeRegistry typeRegistry: streamy.EMPTY_REGISTRY,
      streamy.TransactionStrategy txStrategy: null,
      streamy.Tracer tracer: const streamy.NoopTracer()}) :
          super(typeRegistry, servicePath),
          this._txStrategy = txStrategy,
          this._tracer = tracer;
  Stream send(streamy.Request request) =>
      requestHandler.handle(request, _tracer.trace(request));
  SchemaObjectTestTransaction beginTransaction() =>
      new SchemaObjectTestTransaction(typeRegistry, servicePath,
          _txStrategy.beginTransaction());
}

/// Provides the same API as [SchemaObjectTest] but runs all requests as
/// part of the same transaction.
class SchemaObjectTestTransaction
    extends streamy.TransactionRoot
    with SchemaObjectTestResourcesMixin {
  String get apiType => r'SchemaObjectTestTransaction';
  SchemaObjectTestTransaction(
      streamy.TypeRegistry typeRegistry,
      String servicePath,
      streamy.Transaction tx) : super(typeRegistry, servicePath, tx);
}
