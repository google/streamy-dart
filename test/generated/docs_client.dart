/**
 * WARNING: This code was generated from templates in
 * folder templates. Do not edit by hand.
 */
library docs;
import 'dart:async';
import 'dart:json';
import 'package:streamy/streamy.dart' as streamy;
import 'package:streamy/collections.dart';

/// This is a foo.
class Foo extends streamy.EntityWrapper {
  static final List<String> KNOWN_PROPERTIES = [
    'id',
  ];
  Foo() : super.wrap(new streamy.RawEntity(), (cloned) => new Foo._wrap(cloned));
  Foo._wrap(streamy.Entity entity) : super.wrap(entity, (cloned) => new Foo._wrap(cloned));
  Foo.wrap(streamy.Entity entity, streamy.EntityWrapperCloneFn cloneWrapper) :
      super.wrap(entity, (cloned) => cloneWrapper(cloned));

  /// Primary key.
  int get id => this['id'];
  set id(int value) {
    this['id'] = value;
  }
  int removeId() => this.remove('id');
  factory Foo.fromJsonString(String strJson,
      {streamy.TypeRegistry typeRegistry: streamy.EMPTY_REGISTRY}) =>
          new Foo.fromJson(parse(strJson), typeRegistry: typeRegistry);
  static Foo entityFactory(Map json, streamy.TypeRegistry reg) =>
      new Foo.fromJson(json, typeRegistry: reg);
  factory Foo.fromJson(Map json,
      {streamy.TypeRegistry typeRegistry: streamy.EMPTY_REGISTRY}) {
    if (json == null) {
      return null;
    }
    json = new Map.from(json);
    var result = new Foo()
      ..id = json.remove('id')
;
    streamy.addUnknownProperties(result, json, typeRegistry);
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
  String get httpMethod => 'GET';
  String get pathFormat => 'foos/{fooId}';
  bool get hasPayload => false;
  FoosGetRequest(DocsTest root) : super(root) {
  }
  List<String> get pathParameters => const ['fooId',];
  List<String> get queryParameters => const [];

  /// Primary key of foo
  int get fooId => parameters['fooId'];
  set fooId(int value) {
    parameters['fooId'] = value;
  }
  int removeFooId() => parameters.remove('fooId');
  Stream<Foo> send() =>
      this.root.send(this);
  StreamSubscription<Foo> listen(void onData(Foo event)) =>
      this.root.send(this).listen(onData);
  FoosGetRequest clone() => streamy.internalCloneFrom(new FoosGetRequest(root), this);
  streamy.Deserializer get responseDeserializer => (String str) =>
      new Foo.fromJsonString(str, typeRegistry: root.typeRegistry);
}

class FoosResource {
  final DocsTest _root;
  static final List<String> KNOWN_METHODS = [
    'get',
  ];
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

/// API definitions with documentation
class DocsTest extends streamy.Root {
  FoosResource _foos;
  FoosResource get foos => _foos;
  final streamy.RequestHandler requestHandler;
  final String servicePath;
  DocsTest(this.requestHandler, {this.servicePath: 'docsTest/v1/',
      streamy.TypeRegistry typeRegistry: streamy.EMPTY_REGISTRY}) : super(typeRegistry) {
    this._foos = new FoosResource(this);
  }
  Stream send(streamy.Request request) => requestHandler.handle(request);
}
