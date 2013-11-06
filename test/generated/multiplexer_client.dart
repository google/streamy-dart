/**
 * WARNING: This code was generated from templates in
 * folder templates. Do not edit by hand.
 */
library multiplexer;
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
    'id',
    'bar',
  ]);
  String get apiType => 'Foo';

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
    fields.remove('id');
    fields.remove('bar');
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

/// Gets a foo
class FoosGetRequest extends streamy.Request {
  static final List<String> KNOWN_PARAMETERS = [
    'id',
  ];
  String get apiType => 'FoosGetRequest';
  String get httpMethod => 'GET';
  String get pathFormat => 'foos/{id}';
  bool get hasPayload => false;
  FoosGetRequest(MultiplexerTest root) : super(root) {
  }
  List<String> get pathParameters => const ['id',];
  List<String> get queryParameters => const [];

  /// Primary key of foo
  int get id => parameters['id'];
  set id(int value) {
    parameters['id'] = value;
  }
  int removeId() => parameters.remove('id');
  Stream<streamy.Response<Foo>> _sendDirect() => this.root.send(this);
  Stream<streamy.Response<Foo>> sendRaw() =>
      _sendDirect();
  Stream<Foo> send() =>
      _sendDirect().map((response) => response.entity);
  StreamSubscription<Foo> listen(void onData(Foo event)) =>
      _sendDirect().map((response) => response.entity).listen(onData);
  FoosGetRequest clone() => streamy.internalCloneFrom(new FoosGetRequest(root), this);
  streamy.Deserializer get responseDeserializer => (String str, streamy.Trace trace) =>
      new Foo.fromJsonString(str, trace, typeRegistry: root.typeRegistry);
}

/// Updates a foo
class FoosUpdateRequest extends streamy.Request {
  static final List<String> KNOWN_PARAMETERS = [
    'id',
  ];
  String get apiType => 'FoosUpdateRequest';
  Foo get payload => streamy.internalGetPayload(this);
  final patch;
  String get httpMethod => patch ? 'PATCH' : 'PUT';
  String get pathFormat => 'foos/{id}';
  bool get hasPayload => true;
  FoosUpdateRequest(MultiplexerTest root, Foo payloadEntity, {bool this.patch: false}) : super(root, payloadEntity) {
  }
  List<String> get pathParameters => const ['id',];
  List<String> get queryParameters => const [];

  /// Primary key of foo
  int get id => parameters['id'];
  set id(int value) {
    parameters['id'] = value;
  }
  int removeId() => parameters.remove('id');
  Stream<streamy.Response<Foo>> _sendDirect() => this.root.send(this);
  Stream<streamy.Response<Foo>> sendRaw() =>
      _sendDirect();
  Stream<Foo> send() =>
      _sendDirect().map((response) => response.entity);
  StreamSubscription<Foo> listen(void onData(Foo event)) =>
      _sendDirect().map((response) => response.entity).listen(onData);
  FoosUpdateRequest clone() => streamy.internalCloneFrom(new FoosUpdateRequest(root, payload.clone()), this);
  streamy.Deserializer get responseDeserializer => (String str, streamy.Trace trace) =>
      new Foo.fromJsonString(str, trace, typeRegistry: root.typeRegistry);
}

/// Deletes a foo
class FoosDeleteRequest extends streamy.Request {
  static final List<String> KNOWN_PARAMETERS = [
    'id',
  ];
  String get apiType => 'FoosDeleteRequest';
  String get httpMethod => 'DELETE';
  String get pathFormat => 'foos/{id}';
  bool get hasPayload => false;
  FoosDeleteRequest(MultiplexerTest root) : super(root) {
  }
  List<String> get pathParameters => const ['id',];
  List<String> get queryParameters => const [];

  /// Primary key of foo
  int get id => parameters['id'];
  set id(int value) {
    parameters['id'] = value;
  }
  int removeId() => parameters.remove('id');
  Stream<streamy.Response> _sendDirect() => this.root.send(this);
  Stream<streamy.Response> sendRaw() =>
      _sendDirect();
  Stream send() =>
      _sendDirect().map((response) => response.entity);
  StreamSubscription listen(void onData(event)) =>
      _sendDirect().map((response) => response.entity).listen(onData);
  FoosDeleteRequest clone() => streamy.internalCloneFrom(new FoosDeleteRequest(root), this);
  streamy.Deserializer get responseDeserializer => (String str, streamy.Trace trace) =>
      new streamy.EmptyEntity();
}

/// A method to test request cancellation
class FoosCancelRequest extends streamy.Request {
  static final List<String> KNOWN_PARAMETERS = [
    'id',
  ];
  String get apiType => 'FoosCancelRequest';
  String get httpMethod => 'GET';
  String get pathFormat => 'foos/cancel/{id}';
  bool get hasPayload => false;
  FoosCancelRequest(MultiplexerTest root) : super(root) {
  }
  List<String> get pathParameters => const ['id',];
  List<String> get queryParameters => const [];

  /// Primary key of foo
  int get id => parameters['id'];
  set id(int value) {
    parameters['id'] = value;
  }
  int removeId() => parameters.remove('id');
  Stream<streamy.Response> _sendDirect() => this.root.send(this);
  Stream<streamy.Response> sendRaw() =>
      _sendDirect();
  Stream send() =>
      _sendDirect().map((response) => response.entity);
  StreamSubscription listen(void onData(event)) =>
      _sendDirect().map((response) => response.entity).listen(onData);
  FoosCancelRequest clone() => streamy.internalCloneFrom(new FoosCancelRequest(root), this);
  streamy.Deserializer get responseDeserializer => (String str, streamy.Trace trace) =>
      new streamy.EmptyEntity();
}

class FoosResource {
  final MultiplexerTest _root;
  static final List<String> KNOWN_METHODS = [
    'get',
    'update',
    'patch',
    'delete',
    'cancel',
  ];
  String get apiType => 'FoosResource';
  FoosResource(this._root);

  /// Gets a foo
  FoosGetRequest get(int id) {
    var request = new FoosGetRequest(_root);
    if (id != null) {
      request.id = id;
    }
    return request;
  }

  /// Updates a foo
  FoosUpdateRequest update(Foo payload) {
    var request = new FoosUpdateRequest(_root, payload);
    return request;
  }

  /// Updates a foo
  FoosUpdateRequest patch(Foo payload) {
    var request = new FoosUpdateRequest(_root, payload.patch(), patch: true);
    return request;
  }

  /// Deletes a foo
  FoosDeleteRequest delete(int id) {
    var request = new FoosDeleteRequest(_root);
    if (id != null) {
      request.id = id;
    }
    return request;
  }

  /// A method to test request cancellation
  FoosCancelRequest cancel(int id) {
    var request = new FoosCancelRequest(_root);
    if (id != null) {
      request.id = id;
    }
    return request;
  }
}

abstract class MultiplexerTestResourcesMixin {
  FoosResource _foos;
  FoosResource get foos {
    if (_foos == null) {
      _foos = new FoosResource(this);
    }
    return _foos;
  }
}

class MultiplexerTest
    extends streamy.Root
    with MultiplexerTestResourcesMixin {
  String get apiType => 'MultiplexerTest';
  final streamy.TransactionStrategy _txStrategy;
  final streamy.RequestHandler requestHandler;
  final streamy.Tracer _tracer;
  MultiplexerTest(
      this.requestHandler,
      {String servicePath: 'multiplexerTest/v1/',
      streamy.TypeRegistry typeRegistry: streamy.EMPTY_REGISTRY,
      streamy.TransactionStrategy txStrategy: null,
      streamy.Tracer tracer: const streamy.NoopTracer()}) :
          super(typeRegistry, servicePath),
          this._txStrategy = txStrategy,
          this._tracer = tracer;
  Stream send(streamy.Request request) =>
      requestHandler.handle(request, _tracer.trace(request));
  MultiplexerTestTransaction beginTransaction() =>
      new MultiplexerTestTransaction(typeRegistry, servicePath,
          _txStrategy.beginTransaction());
}

/// Provides the same API as [MultiplexerTest] but runs all requests as
/// part of the same transaction.
class MultiplexerTestTransaction
    extends streamy.TransactionRoot
    with MultiplexerTestResourcesMixin {
  String get apiType => 'MultiplexerTestTransaction';
  MultiplexerTestTransaction(
      streamy.TypeRegistry typeRegistry,
      String servicePath,
      streamy.Transaction tx) : super(typeRegistry, servicePath, tx);
}
