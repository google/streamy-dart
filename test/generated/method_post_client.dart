/**
 * WARNING: This code was generated from templates in
 * folder templates. Do not edit by hand.
 */
library method_post;
import 'dart:async';
import 'dart:json';
import 'package:fixnum/fixnum.dart' as fixnum;
import 'package:streamy/streamy.dart' as streamy;
import 'package:streamy/collections.dart';

class Foo extends streamy.EntityWrapper {
  static final List<String> KNOWN_PROPERTIES = [
    'id',
    'bar',
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

  /// Foo's favorite bar.
  String get bar => this['bar'];
  set bar(String value) {
    this['bar'] = value;
  }
  String removeBar() => this.remove('bar');
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
      ..bar = json.remove('bar')
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

/// Updates a foo
class FoosUpdateRequest extends streamy.Request {
  static final List<String> KNOWN_PARAMETERS = [
    'id',
  ];
  Foo get payload => streamy.internalGetPayload(this);
  String get httpMethod => 'POST';
  String get pathFormat => 'foos/{id}';
  bool get hasPayload => true;
  FoosUpdateRequest(MethodPostTest root, Foo payloadEntity) : super(root, payloadEntity) {
  }
  List<String> get pathParameters => const ['id',];
  List<String> get queryParameters => const [];

  /// Primary key of foo
  int get id => parameters['id'];
  set id(int value) {
    parameters['id'] = value;
  }
  int removeId() => parameters.remove('id');
  Stream send() =>
      this.root.send(this);
  StreamSubscription listen(void onData(event)) =>
      this.root.send(this).listen(onData);
  FoosUpdateRequest clone() => streamy.internalCloneFrom(new FoosUpdateRequest(root, payload.clone()), this);
  streamy.Deserializer get responseDeserializer => (String str) =>
      new streamy.EmptyEntity();
}

class FoosResource {
  final MethodPostTest _root;
  static final List<String> KNOWN_METHODS = [
    'update',
  ];
  FoosResource(this._root);

  /// Updates a foo
  FoosUpdateRequest update(Foo payload) {
    var request = new FoosUpdateRequest(_root, payload);
    return request;
  }
}

class MethodPostTest extends streamy.Root {
  FoosResource _foos;
  FoosResource get foos => _foos;
  final streamy.RequestHandler requestHandler;
  final String servicePath;
  MethodPostTest(this.requestHandler, {this.servicePath: 'postTest/v1/',
      streamy.TypeRegistry typeRegistry: streamy.EMPTY_REGISTRY}) : super(typeRegistry) {
    this._foos = new FoosResource(this);
  }
  Stream send(streamy.Request request) => requestHandler.handle(request);
}
