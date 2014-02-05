/**
 * WARNING: GENERATED CODE. DO NOT EDIT BY HAND.
 * 
 */
library schemaobjecttest.objects;
import 'package:fixnum/fixnum.dart' as fixnum;
import 'package:streamy/streamy.dart' as streamy;
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
    _globals[name] = new streamy.GlobalRegistration(computeFn, dependencies, memoize);
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
  int removeId() => remove(r'id');

  /// Foo's favorite bar.
  String get bar => this[r'bar'];
  set bar(String value) {
    this[r'bar'] = value;
  }
  String removeBar() => remove(r'bar');

  /// It's spelled buzz.
  int get baz => this[r'baz'];
  set baz(int value) {
    this[r'baz'] = value;
  }
  int removeBaz() => remove(r'baz');

  /// Not what it seems.
  fixnum.Int64 get qux => this[r'qux'];
  set qux(fixnum.Int64 value) {
    this[r'qux'] = value;
  }
  fixnum.Int64 removeQux() => remove(r'qux');

  /// The plural of qux
  List<double> get quux => this[r'quux'];
  set quux(List<double> value) {
    if (value is! obs.ObservableList) {
      value = new obs.ObservableList.from(value);
    }
    this[r'quux'] = value;
  }
  List<double> removeQuux() => remove(r'quux');

  /// A double field that's serialized as a number.
  double get corge => this[r'corge'];
  set corge(double value) {
    this[r'corge'] = value;
  }
  double removeCorge() => remove(r'corge');
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
    json[r'qux'] = streamy.atoi64(json[r'qux']);
    json[r'quux'] = streamy.mapInline(streamy.atod)(json[r'quux']);
    streamy.deserializeUnknown(json, KNOWN_PROPERTIES, typeRegistry);
    return new Foo.wrapMap(json);
  }
  Map toJson() {
    Map json = super.toJson();
    streamy.serialize(json, r'qux', streamy.str);
    streamy.serialize(json, r'quux', streamy.mapCopy(streamy.str));
    return json;
  }
  Foo clone() => super.clone();
  Foo patch() => super.patch();
  Type get streamyType => Foo;
}

/// An EntityGlobalFn for Bar entities.
typedef dynamic BarGlobalFn(Bar entity);

class Bar extends streamy.EntityWrapper {
  static final Map<String, streamy.GlobalRegistration> _globals = <String, streamy.GlobalRegistration>{};
  static final Set<String> KNOWN_PROPERTIES = new Set<String>.from([
    r'primary',
    r'foos',
  ]);
  String get apiType => r'Bar';

  /// Add a global computed synthetic property to this entity type, optionally memoized.
  static void addGlobal(String name, BarGlobalFn computeFn,
      {bool memoize: false, List dependencies: null}) {
    _globals[name] = new streamy.GlobalRegistration(computeFn, dependencies, memoize);
  }
  Bar() : super.wrap(new streamy.RawEntity(), (cloned) => new Bar._wrap(cloned), globals: _globals);
  Bar.fromMap(Map map) : super.wrap(new streamy.RawEntity.fromMap(map), (cloned) => new Bar._wrap(cloned), globals: _globals);
  Bar.wrapMap(obs.ObservableMap map) : super.wrap(new streamy.RawEntity.wrapMap(map), (cloned) => new Bar._wrap(cloned), globals: _globals);
  Bar._wrap(streamy.Entity entity) : super.wrap(entity, (cloned) => new Bar._wrap(cloned), globals: _globals);
  Bar.wrap(streamy.Entity entity, streamy.EntityWrapperCloneFn cloneWrapper) :
      super.wrap(entity, (cloned) => cloneWrapper(cloned), globals: _globals);

  /// The primary foo.
  Foo get primary => this[r'primary'];
  set primary(Foo value) {
    this[r'primary'] = value;
  }
  Foo removePrimary() => remove(r'primary');

  /// A bunch of foos.
  List<Foo> get foos => this[r'foos'];
  set foos(List<Foo> value) {
    if (value is! obs.ObservableList) {
      value = new obs.ObservableList.from(value);
    }
    this[r'foos'] = value;
  }
  List<Foo> removeFoos() => remove(r'foos');
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
    json[r'primary'] = ((v) => new Foo.fromJson(v))(json[r'primary']);
    json[r'foos'] = streamy.mapInline(((v) => new Foo.fromJson(v)))(json[r'foos']);
    streamy.deserializeUnknown(json, KNOWN_PROPERTIES, typeRegistry);
    return new Bar.wrapMap(json);
  }
  Bar clone() => super.clone();
  Bar patch() => super.patch();
  Type get streamyType => Bar;
}

/// An EntityGlobalFn for Context_Facets entities.
typedef dynamic Context_FacetsGlobalFn(Context_Facets entity);

class Context_Facets extends streamy.EntityWrapper {
  static final Map<String, streamy.GlobalRegistration> _globals = <String, streamy.GlobalRegistration>{};
  static final Set<String> KNOWN_PROPERTIES = new Set<String>.from([
    r'anchor',
  ]);
  String get apiType => r'Context_Facets';

  /// Add a global computed synthetic property to this entity type, optionally memoized.
  static void addGlobal(String name, Context_FacetsGlobalFn computeFn,
      {bool memoize: false, List dependencies: null}) {
    _globals[name] = new streamy.GlobalRegistration(computeFn, dependencies, memoize);
  }
  Context_Facets() : super.wrap(new streamy.RawEntity(), (cloned) => new Context_Facets._wrap(cloned), globals: _globals);
  Context_Facets.fromMap(Map map) : super.wrap(new streamy.RawEntity.fromMap(map), (cloned) => new Context_Facets._wrap(cloned), globals: _globals);
  Context_Facets.wrapMap(obs.ObservableMap map) : super.wrap(new streamy.RawEntity.wrapMap(map), (cloned) => new Context_Facets._wrap(cloned), globals: _globals);
  Context_Facets._wrap(streamy.Entity entity) : super.wrap(entity, (cloned) => new Context_Facets._wrap(cloned), globals: _globals);
  Context_Facets.wrap(streamy.Entity entity, streamy.EntityWrapperCloneFn cloneWrapper) :
      super.wrap(entity, (cloned) => cloneWrapper(cloned), globals: _globals);
  String get anchor => this[r'anchor'];
  set anchor(String value) {
    this[r'anchor'] = value;
  }
  String removeAnchor() => remove(r'anchor');
  factory Context_Facets.fromJsonString(String strJson, streamy.Trace trace,
      {streamy.TypeRegistry typeRegistry: streamy.EMPTY_REGISTRY}) =>
          new Context_Facets.fromJson(streamy.jsonParse(strJson), typeRegistry: typeRegistry);
  static Context_Facets entityFactory(Map json, streamy.TypeRegistry reg) =>
      new Context_Facets.fromJson(json, typeRegistry: reg);
  factory Context_Facets.fromJson(Map json,
      {streamy.TypeRegistry typeRegistry: streamy.EMPTY_REGISTRY, bool copy: false}) {
    if (json == null) {
      return null;
    }
    if (copy) {
      json = new obs.ObservableMap.from(json);
    }
    streamy.deserializeUnknown(json, KNOWN_PROPERTIES, typeRegistry);
    return new Context_Facets.wrapMap(json);
  }
  Context_Facets clone() => super.clone();
  Context_Facets patch() => super.patch();
  Type get streamyType => Context_Facets;
}

/// An EntityGlobalFn for Context entities.
typedef dynamic ContextGlobalFn(Context entity);

class Context extends streamy.EntityWrapper {
  static final Map<String, streamy.GlobalRegistration> _globals = <String, streamy.GlobalRegistration>{};
  static final Set<String> KNOWN_PROPERTIES = new Set<String>.from([
    r'facets',
  ]);
  String get apiType => r'Context';

  /// Add a global computed synthetic property to this entity type, optionally memoized.
  static void addGlobal(String name, ContextGlobalFn computeFn,
      {bool memoize: false, List dependencies: null}) {
    _globals[name] = new streamy.GlobalRegistration(computeFn, dependencies, memoize);
  }
  Context() : super.wrap(new streamy.RawEntity(), (cloned) => new Context._wrap(cloned), globals: _globals);
  Context.fromMap(Map map) : super.wrap(new streamy.RawEntity.fromMap(map), (cloned) => new Context._wrap(cloned), globals: _globals);
  Context.wrapMap(obs.ObservableMap map) : super.wrap(new streamy.RawEntity.wrapMap(map), (cloned) => new Context._wrap(cloned), globals: _globals);
  Context._wrap(streamy.Entity entity) : super.wrap(entity, (cloned) => new Context._wrap(cloned), globals: _globals);
  Context.wrap(streamy.Entity entity, streamy.EntityWrapperCloneFn cloneWrapper) :
      super.wrap(entity, (cloned) => cloneWrapper(cloned), globals: _globals);
  List<List<Context_Facets>> get facets => this[r'facets'];
  set facets(List<List<Context_Facets>> value) {
    if (value is! obs.ObservableList) {
      value = new obs.ObservableList.from(value);
    }
    this[r'facets'] = value;
  }
  List<List<Context_Facets>> removeFacets() => remove(r'facets');
  factory Context.fromJsonString(String strJson, streamy.Trace trace,
      {streamy.TypeRegistry typeRegistry: streamy.EMPTY_REGISTRY}) =>
          new Context.fromJson(streamy.jsonParse(strJson), typeRegistry: typeRegistry);
  static Context entityFactory(Map json, streamy.TypeRegistry reg) =>
      new Context.fromJson(json, typeRegistry: reg);
  factory Context.fromJson(Map json,
      {streamy.TypeRegistry typeRegistry: streamy.EMPTY_REGISTRY, bool copy: false}) {
    if (json == null) {
      return null;
    }
    if (copy) {
      json = new obs.ObservableMap.from(json);
    }
    json[r'facets'] = streamy.mapInline(streamy.mapInline(((v) => new Context_Facets.fromJson(v))))(json[r'facets']);
    streamy.deserializeUnknown(json, KNOWN_PROPERTIES, typeRegistry);
    return new Context.wrapMap(json);
  }
  Context clone() => super.clone();
  Context patch() => super.patch();
  Type get streamyType => Context;
}

/// An EntityGlobalFn for $some_entity_ entities.
typedef dynamic $some_entity_GlobalFn($some_entity_ entity);

class $some_entity_ extends streamy.EntityWrapper {
  static final Map<String, streamy.GlobalRegistration> _globals = <String, streamy.GlobalRegistration>{};
  static final Set<String> KNOWN_PROPERTIES = new Set<String>.from([
    r'%badly#named property~!@#$%^&*()?',
  ]);
  String get apiType => r'$some_entity_';

  /// Add a global computed synthetic property to this entity type, optionally memoized.
  static void addGlobal(String name, $some_entity_GlobalFn computeFn,
      {bool memoize: false, List dependencies: null}) {
    _globals[name] = new streamy.GlobalRegistration(computeFn, dependencies, memoize);
  }
  $some_entity_() : super.wrap(new streamy.RawEntity(), (cloned) => new $some_entity_._wrap(cloned), globals: _globals);
  $some_entity_.fromMap(Map map) : super.wrap(new streamy.RawEntity.fromMap(map), (cloned) => new $some_entity_._wrap(cloned), globals: _globals);
  $some_entity_.wrapMap(obs.ObservableMap map) : super.wrap(new streamy.RawEntity.wrapMap(map), (cloned) => new $some_entity_._wrap(cloned), globals: _globals);
  $some_entity_._wrap(streamy.Entity entity) : super.wrap(entity, (cloned) => new $some_entity_._wrap(cloned), globals: _globals);
  $some_entity_.wrap(streamy.Entity entity, streamy.EntityWrapperCloneFn cloneWrapper) :
      super.wrap(entity, (cloned) => cloneWrapper(cloned), globals: _globals);
  fixnum.Int64 get $badly_named_property____$_______ => this[r'%badly#named property~!@#$%^&*()?'];
  set $badly_named_property____$_______(fixnum.Int64 value) {
    this[r'%badly#named property~!@#$%^&*()?'] = value;
  }
  fixnum.Int64 remove$badly_named_property____$_______() => remove(r'%badly#named property~!@#$%^&*()?');
  factory $some_entity_.fromJsonString(String strJson, streamy.Trace trace,
      {streamy.TypeRegistry typeRegistry: streamy.EMPTY_REGISTRY}) =>
          new $some_entity_.fromJson(streamy.jsonParse(strJson), typeRegistry: typeRegistry);
  static $some_entity_ entityFactory(Map json, streamy.TypeRegistry reg) =>
      new $some_entity_.fromJson(json, typeRegistry: reg);
  factory $some_entity_.fromJson(Map json,
      {streamy.TypeRegistry typeRegistry: streamy.EMPTY_REGISTRY, bool copy: false}) {
    if (json == null) {
      return null;
    }
    if (copy) {
      json = new obs.ObservableMap.from(json);
    }
    json[r'%badly#named property~!@#$%^&*()?'] = streamy.atoi64(json[r'%badly#named property~!@#$%^&*()?']);
    streamy.deserializeUnknown(json, KNOWN_PROPERTIES, typeRegistry);
    return new $some_entity_.wrapMap(json);
  }
  Map toJson() {
    Map json = super.toJson();
    streamy.serialize(json, r'%badly#named property~!@#$%^&*()?', streamy.str);
    return json;
  }
  $some_entity_ clone() => super.clone();
  $some_entity_ patch() => super.patch();
  Type get streamyType => $some_entity_;
}
