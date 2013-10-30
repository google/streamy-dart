/**
 * WARNING: This code was generated from templates in
 * folder templates. Do not edit by hand.
 */
library method_get;
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
    'fooId',
  ];
  String get apiType => 'FoosGetRequest';
  String get httpMethod => 'GET';
  String get pathFormat => 'foos/{fooId}';
  bool get hasPayload => false;
  FoosGetRequest(MethodGetTest root) : super(root) {
  }
  List<String> get pathParameters => const ['fooId',];
  List<String> get queryParameters => const [];

  /// Primary key of foo
  int get fooId => parameters['fooId'];
  set fooId(int value) {
    parameters['fooId'] = value;
  }
  int removeFooId() => parameters.remove('fooId');
  Stream<Response<Foo>> _sendDirect() => this.root.send(this);
  Stream<Response<Foo>> sendRaw() =>
      _sendDirect();
  Stream<Foo> send() =>
      _sendDirect().map((response) => response.entity);
  StreamSubscription<Foo> listen(void onData(Foo event)) =>
      _sendDirect().map((response) => response.entity).listen(onData);
  FoosGetRequest clone() => streamy.internalCloneFrom(new FoosGetRequest(root), this);
  streamy.Deserializer get responseDeserializer => (String str, streamy.Trace trace) =>
      new Foo.fromJsonString(str, trace, typeRegistry: root.typeRegistry);
}

class FoosResource {
  final MethodGetTest _root;
  static final List<String> KNOWN_METHODS = [
    'get',
  ];
  String get apiType => 'FoosResource';
  FoosResource(this._root);

  /// Gets a foo
  FoosGetRequest get(int fooId) {
    var request = new FoosGetRequest(_root);
    if (fooId != null) {
      request.fooId = fooId;
    }
    return request;
  }
}

class MethodGetTest extends streamy.Root {
  String get apiType => 'MethodGetTest';
  FoosResource _foos;
  FoosResource get foos {
    if (_foos == null) {
      _foos = new FoosResource(this);
    }
    return _foos;
  }
  final streamy.RequestHandler requestHandler;
  final streamy.Tracer tracer;
  final String servicePath;
  MethodGetTest(this.requestHandler, {this.servicePath: 'getTest/v1/',
      streamy.TypeRegistry typeRegistry: streamy.EMPTY_REGISTRY, this.tracer: const streamy.NoopTracer()}) : super(typeRegistry);
  Stream<streamy.Response> send(streamy.Request request) => requestHandler.handle(request, tracer.trace(request));
}
