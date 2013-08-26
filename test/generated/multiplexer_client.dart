/**
 * WARNING: This code was generated from templates in
 * folder templates. Do not edit by hand.
 */
library multiplexer;
import 'dart:async';
import 'dart:json';
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

/// Gets a foo
class FoosGetRequest extends streamy.Request {
  static final List<String> KNOWN_PARAMETERS = [
    'id',
  ];
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
  Stream<Foo> send() =>
      this.root.send(this);
  StreamSubscription<Foo> listen(void onData(Foo event)) =>
      this.root.send(this).listen(onData);
  FoosGetRequest clone() => streamy.internalCloneFrom(new FoosGetRequest(root), this);
  streamy.Deserializer get responseDeserializer => (String str) =>
      new Foo.fromJsonString(str, typeRegistry: root.typeRegistry);
}

/// Updates a foo
class FoosUpdateRequest extends streamy.Request {
  static final List<String> KNOWN_PARAMETERS = [
    'id',
  ];
  Foo get payload => streamy.internalGetPayload(this);
  String get httpMethod => 'PUT';
  String get pathFormat => 'foos/{id}';
  bool get hasPayload => true;
  FoosUpdateRequest(MultiplexerTest root, Foo payloadEntity) : super(root, payloadEntity) {
  }
  List<String> get pathParameters => const ['id',];
  List<String> get queryParameters => const [];

  /// Primary key of foo
  int get id => parameters['id'];
  set id(int value) {
    parameters['id'] = value;
  }
  int removeId() => parameters.remove('id');
  Stream<Foo> send() =>
      this.root.send(this);
  StreamSubscription<Foo> listen(void onData(Foo event)) =>
      this.root.send(this).listen(onData);
  FoosUpdateRequest clone() => streamy.internalCloneFrom(new FoosUpdateRequest(root, payload.clone()), this);
  streamy.Deserializer get responseDeserializer => (String str) =>
      new Foo.fromJsonString(str, typeRegistry: root.typeRegistry);
}

/// Deletes a foo
class FoosDeleteRequest extends streamy.Request {
  static final List<String> KNOWN_PARAMETERS = [
    'id',
  ];
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
  Stream send() =>
      this.root.send(this);
  StreamSubscription listen(void onData(event)) =>
      this.root.send(this).listen(onData);
  FoosDeleteRequest clone() => streamy.internalCloneFrom(new FoosDeleteRequest(root), this);
  streamy.Deserializer get responseDeserializer => (String str) =>
      new streamy.EmptyEntity();
}

/// A method to test request cancellation
class FoosCancelRequest extends streamy.Request {
  static final List<String> KNOWN_PARAMETERS = [
    'id',
  ];
  String get httpMethod => 'DELETE';
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
  Stream send() =>
      this.root.send(this);
  StreamSubscription listen(void onData(event)) =>
      this.root.send(this).listen(onData);
  FoosCancelRequest clone() => streamy.internalCloneFrom(new FoosCancelRequest(root), this);
  streamy.Deserializer get responseDeserializer => (String str) =>
      new streamy.EmptyEntity();
}

class FoosResource {
  final MultiplexerTest _root;
  static final List<String> KNOWN_METHODS = [
    'get',
    'update',
    'delete',
    'cancel',
  ];
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

class MultiplexerTest extends streamy.Root {
  FoosResource _foos;
  FoosResource get foos => _foos;
  final streamy.RequestHandler requestHandler;
  final String servicePath;
  MultiplexerTest(this.requestHandler, {this.servicePath: 'multiplexerTest/v1/',
      streamy.TypeRegistry typeRegistry: streamy.EMPTY_REGISTRY}) : super(typeRegistry) {
    this._foos = new FoosResource(this);
  }
  Stream send(streamy.Request request) => requestHandler.handle(request);
}
