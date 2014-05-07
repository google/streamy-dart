library MethodPostTest.requests;

import 'package:streamy/streamy.dart' as streamy;
import 'package:fixnum/fixnum.dart' as fixnum;
import 'method_post_client_objects.dart' as objects;
import 'method_post_client_dispatch.dart' as dispatch;
import 'dart:async';
import 'package:streamy/base.dart' as base;

class FoosUpdateRequest extends streamy.HttpRequest {

  static final List<String> KNOWN_PARAMETERS = const [
    r'id',
  ];

  int get id => parameters[r'id'];
  void set id(int value) {
    parameters[r'id'] = value;
  }

  String get apiType => r'FoosUpdateRequest';

  bool get hasPayload => true;

  String get httpMethod => r'POST';

  String get pathFormat => r'foos/{id}';

  List<String> get pathParameters => const [
    r'id',
  ];

  List<String> get queryParameters => const [
  ];

  FoosUpdateRequest(streamy.Root root, objects.Foo payload) : super(root, payload);

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

  FoosUpdateRequest clone() => streamy.internalCloneFrom(new FoosUpdateRequest(root, payload.clone()), this);
}
