library MultiplexerTest.null.requests;

import 'package:streamy/streamy.dart' as streamy;
import 'package:fixnum/fixnum.dart' as fixnum;
import 'multiplexer_client_objects.dart' as objects;
import 'multiplexer_client_dispatch.dart' as dispatch;
import 'dart:async';
import 'package:streamy/base.dart' as base;

class FoosGetRequest extends streamy.HttpRequest {

  static final List<String> KNOWN_PARAMETERS = const [
    r'id',
  ];

  int get id => parameters[r'id'];
  void set id(int value) {
    parameters[r'id'] = value;
  }

  static final String API_TYPE = r'FoosGetRequest';

  String get apiType => r'FoosGetRequest';

  bool get hasPayload => false;

  String get httpMethod => r'GET';

  String get pathFormat => r'foos/{id}';

  List<String> get pathParameters => const [
    r'id',
  ];

  List<String> get queryParameters => const [
  ];

  FoosGetRequest(streamy.Root root) : super(root);

  int removeId() => parameters.remove(r'id');

  Stream<streamy.Response<objects.Foo>> _sendDirect() => root.send(this);

  objects.Foo unmarshalResponse(dispatch.Marshaller marshaller, Map data) => marshaller.unmarshalFoo(data);

  Stream<objects.Foo> send() {
    return _sendDirect()
      .map((response) => response.entity);
  }

  Stream<streamy.Response<objects.Foo>> sendRaw() {
    return _sendDirect();
  }

  StreamSubscription<objects.Foo> listen() {
    return _sendDirect()
      .map((response) => response.entity)
      .listen(onData);
  }

  FoosGetRequest clone() => streamy.internalCloneFrom(new FoosGetRequest(root), this);
}

class FoosUpdateRequest extends streamy.HttpRequest {

  static final List<String> KNOWN_PARAMETERS = const [
    r'id',
  ];

  int get id => parameters[r'id'];
  void set id(int value) {
    parameters[r'id'] = value;
  }

  static final String API_TYPE = r'FoosUpdateRequest';

  String get apiType => r'FoosUpdateRequest';

  bool get hasPayload => true;

  String get httpMethod => r'PUT';

  String get pathFormat => r'foos/{id}';

  List<String> get pathParameters => const [
    r'id',
  ];

  List<String> get queryParameters => const [
  ];

  FoosUpdateRequest(streamy.Root root, objects.Foo payload) : super(root, payload);

  int removeId() => parameters.remove(r'id');

  Stream<streamy.Response<objects.Foo>> _sendDirect() => root.send(this);

  objects.Foo unmarshalResponse(dispatch.Marshaller marshaller, Map data) => marshaller.unmarshalFoo(data);

  Stream<objects.Foo> send() {
    return _sendDirect()
      .map((response) => response.entity);
  }

  Stream<streamy.Response<objects.Foo>> sendRaw() {
    return _sendDirect();
  }

  StreamSubscription<objects.Foo> listen() {
    return _sendDirect()
      .map((response) => response.entity)
      .listen(onData);
  }

  FoosUpdateRequest clone() => streamy.internalCloneFrom(new FoosUpdateRequest(root, payload.clone()), this);
}

class FoosDeleteRequest extends streamy.HttpRequest {

  static final List<String> KNOWN_PARAMETERS = const [
    r'id',
  ];

  int get id => parameters[r'id'];
  void set id(int value) {
    parameters[r'id'] = value;
  }

  static final String API_TYPE = r'FoosDeleteRequest';

  String get apiType => r'FoosDeleteRequest';

  bool get hasPayload => false;

  String get httpMethod => r'DELETE';

  String get pathFormat => r'foos/{id}';

  List<String> get pathParameters => const [
    r'id',
  ];

  List<String> get queryParameters => const [
  ];

  FoosDeleteRequest(streamy.Root root) : super(root);

  int removeId() => parameters.remove(r'id');

  Stream<streamy.Response> _sendDirect() => root.send(this);

  Stream send() {
    return _sendDirect()
      .map((response) => response.entity);
  }

  Stream<streamy.Response> sendRaw() {
    return _sendDirect();
  }

  StreamSubscription listen() {
    return _sendDirect()
      .map((response) => response.entity)
      .listen(onData);
  }

  FoosDeleteRequest clone() => streamy.internalCloneFrom(new FoosDeleteRequest(root), this);
}

class FoosCancelRequest extends streamy.HttpRequest {

  static final List<String> KNOWN_PARAMETERS = const [
    r'id',
  ];

  int get id => parameters[r'id'];
  void set id(int value) {
    parameters[r'id'] = value;
  }

  static final String API_TYPE = r'FoosCancelRequest';

  String get apiType => r'FoosCancelRequest';

  bool get hasPayload => false;

  String get httpMethod => r'GET';

  String get pathFormat => r'foos/cancel/{id}';

  List<String> get pathParameters => const [
    r'id',
  ];

  List<String> get queryParameters => const [
  ];

  FoosCancelRequest(streamy.Root root) : super(root);

  int removeId() => parameters.remove(r'id');

  Stream<streamy.Response> _sendDirect() => root.send(this);

  Stream send() {
    return _sendDirect()
      .map((response) => response.entity);
  }

  Stream<streamy.Response> sendRaw() {
    return _sendDirect();
  }

  StreamSubscription listen() {
    return _sendDirect()
      .map((response) => response.entity)
      .listen(onData);
  }

  FoosCancelRequest clone() => streamy.internalCloneFrom(new FoosCancelRequest(root), this);
}
