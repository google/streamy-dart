/**
 * WARNING: GENERATED CODE. DO NOT EDIT BY HAND.
 * 
 */
library multiplexertest.requests;
import 'dart:async';
import 'package:fixnum/fixnum.dart' as fixnum;
import 'package:streamy/streamy.dart' as streamy;
import 'multiplexer_client_objects.dart' as obj;

/// Gets a foo
class FoosGetRequest extends streamy.Request {
  static final List<String> KNOWN_PARAMETERS = [
    r'id',
  ];
  static final API_TYPE = r'FoosGetRequest';
  String get apiType => API_TYPE;
  String get httpMethod => 'GET';
  String get pathFormat => 'foos/{id}';
  bool get hasPayload => false;
  FoosGetRequest(streamy.Root root) : super(root) {
  }
  List<String> get pathParameters => const [r'id',];
  List<String> get queryParameters => const [];

  /// Primary key of foo
  int get id => parameters[r'id'];
  set id(int value) {
    parameters[r'id'] = value;
  }
  int removeId() => parameters.remove(r'id');
  Stream<streamy.Response<obj.Foo>> _sendDirect() => this.root.send(this);
  Stream<streamy.Response<obj.Foo>> sendRaw() =>
      _sendDirect();
  Stream<obj.Foo> send() =>
      _sendDirect().map((response) => response.entity);
  StreamSubscription<obj.Foo> listen(void onData(obj.Foo event)) =>
      _sendDirect().map((response) => response.entity).listen(onData);
  FoosGetRequest clone() => streamy.internalCloneFrom(new FoosGetRequest(root), this);
  streamy.Deserializer get responseDeserializer => (String str, streamy.Trace trace) =>
      new obj.Foo.fromJsonString(str, trace, typeRegistry: root.typeRegistry);
}

/// Updates a foo
class FoosUpdateRequest extends streamy.Request {
  static final List<String> KNOWN_PARAMETERS = [
    r'id',
  ];
  static final API_TYPE = r'FoosUpdateRequest';
  String get apiType => API_TYPE;
  obj.Foo get payload => streamy.internalGetPayload(this);
  final patch;
  String get httpMethod => patch ? 'PATCH' : 'PUT';
  String get pathFormat => 'foos/{id}';
  bool get hasPayload => true;
  FoosUpdateRequest(streamy.Root root, obj.Foo payloadEntity, {bool this.patch: false}) : super(root, payloadEntity) {
  }
  List<String> get pathParameters => const [r'id',];
  List<String> get queryParameters => const [];

  /// Primary key of foo
  int get id => parameters[r'id'];
  set id(int value) {
    parameters[r'id'] = value;
  }
  int removeId() => parameters.remove(r'id');
  Stream<streamy.Response<obj.Foo>> _sendDirect() => this.root.send(this);
  Stream<streamy.Response<obj.Foo>> sendRaw() =>
      _sendDirect();
  Stream<obj.Foo> send() =>
      _sendDirect().map((response) => response.entity);
  StreamSubscription<obj.Foo> listen(void onData(obj.Foo event)) =>
      _sendDirect().map((response) => response.entity).listen(onData);
  FoosUpdateRequest clone() => streamy.internalCloneFrom(new FoosUpdateRequest(root, payload.clone()), this);
  streamy.Deserializer get responseDeserializer => (String str, streamy.Trace trace) =>
      new obj.Foo.fromJsonString(str, trace, typeRegistry: root.typeRegistry);
}

/// Deletes a foo
class FoosDeleteRequest extends streamy.Request {
  static final List<String> KNOWN_PARAMETERS = [
    r'id',
  ];
  static final API_TYPE = r'FoosDeleteRequest';
  String get apiType => API_TYPE;
  String get httpMethod => 'DELETE';
  String get pathFormat => 'foos/{id}';
  bool get hasPayload => false;
  FoosDeleteRequest(streamy.Root root) : super(root) {
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
  FoosDeleteRequest clone() => streamy.internalCloneFrom(new FoosDeleteRequest(root), this);
  streamy.Deserializer get responseDeserializer => (String str, streamy.Trace trace) =>
      new streamy.EmptyEntity();
}

/// A method to test request cancellation
class FoosCancelRequest extends streamy.Request {
  static final List<String> KNOWN_PARAMETERS = [
    r'id',
  ];
  static final API_TYPE = r'FoosCancelRequest';
  String get apiType => API_TYPE;
  String get httpMethod => 'GET';
  String get pathFormat => 'foos/cancel/{id}';
  bool get hasPayload => false;
  FoosCancelRequest(streamy.Root root) : super(root) {
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
  FoosCancelRequest clone() => streamy.internalCloneFrom(new FoosCancelRequest(root), this);
  streamy.Deserializer get responseDeserializer => (String str, streamy.Trace trace) =>
      new streamy.EmptyEntity();
}
