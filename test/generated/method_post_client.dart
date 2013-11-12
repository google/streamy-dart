/**
 * WARNING: This code was generated from templates in
 * folder templates. Do not edit by hand.
 */
library method_post;
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
  String get bar => this[r'bar'];
  set bar(String value) {
    this[r'bar'] = value;
  }
  String removeBar() => this.remove(r'bar');
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
    fields.remove(r'bar');
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
  Foo clone() => new Foo._wrap(super.clone());
  Type get streamyType => Foo;
}

/// Updates a foo
class FoosUpdateRequest extends streamy.Request {
  static final List<String> KNOWN_PARAMETERS = [
    r'id',
  ];
  String get apiType => r'FoosUpdateRequest';
  Foo get payload => streamy.internalGetPayload(this);
  final patch;
  String get httpMethod => patch ? 'PATCH' : 'POST';
  String get pathFormat => 'foos/{id}';
  bool get hasPayload => true;
  FoosUpdateRequest(streamy.Root root, Foo payloadEntity, {bool this.patch: false}) : super(root, payloadEntity) {
  }
  List<String> get pathParameters => const [r'id',];
  List<String> get queryParameters => const [];

  /// Primary key of foo
  int get id => parameters[r'id'];
  set id(int value) {
    parameters[r'id'] = value;
  }
  int removeId() => parameters.remove(r'id');
  Stream<streamy.Response> _sendDirect() => this.root.send(this);
  Stream<streamy.Response> sendRaw() =>
      _sendDirect();
  Stream send() =>
      _sendDirect().map((response) => response.entity);
  StreamSubscription listen(void onData(event)) =>
      _sendDirect().map((response) => response.entity).listen(onData);
  FoosUpdateRequest clone() => streamy.internalCloneFrom(new FoosUpdateRequest(root, payload.clone()), this);
  streamy.Deserializer get responseDeserializer => (String str, streamy.Trace trace) =>
      new streamy.EmptyEntity();
}

class FoosResource {
  final streamy.Root _root;
  static final List<String> KNOWN_METHODS = [
    r'update',
  ];
  String get apiType => r'FoosResource';
  FoosResource(this._root);

  /// Updates a foo
  FoosUpdateRequest update(Foo payload) {
    var request = new FoosUpdateRequest(_root, payload);
    return request;
  }
}

abstract class MethodPostTestResourcesMixin {
  FoosResource _foos;
  FoosResource get foos {
    if (_foos == null) {
      _foos = new FoosResource(this as streamy.Root);
    }
    return _foos;
  }
}

class MethodPostTest
    extends streamy.Root
    with MethodPostTestResourcesMixin {
  String get apiType => r'MethodPostTest';
  final streamy.TransactionStrategy _txStrategy;
  final streamy.RequestHandler requestHandler;
  final streamy.Tracer _tracer;
  MethodPostTest(
      this.requestHandler,
      {String servicePath: 'postTest/v1/',
      streamy.TypeRegistry typeRegistry: streamy.EMPTY_REGISTRY,
      streamy.TransactionStrategy txStrategy: null,
      streamy.Tracer tracer: const streamy.NoopTracer()}) :
          super(typeRegistry, servicePath),
          this._txStrategy = txStrategy,
          this._tracer = tracer;
  Stream send(streamy.Request request) =>
      requestHandler.handle(request, _tracer.trace(request));
  MethodPostTestTransaction beginTransaction() =>
      new MethodPostTestTransaction(typeRegistry, servicePath,
          _txStrategy.beginTransaction());
}

/// Provides the same API as [MethodPostTest] but runs all requests as
/// part of the same transaction.
class MethodPostTestTransaction
    extends streamy.TransactionRoot
    with MethodPostTestResourcesMixin {
  String get apiType => r'MethodPostTestTransaction';
  MethodPostTestTransaction(
      streamy.TypeRegistry typeRegistry,
      String servicePath,
      streamy.Transaction tx) : super(typeRegistry, servicePath, tx);
}
