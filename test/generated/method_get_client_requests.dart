library MethodGetTest.null.requests;

import 'package:streamy/streamy.dart' as streamy;
import 'package:fixnum/fixnum.dart' as fixnum;
import 'package:streamy/base.dart' as base;
import 'method_get_client_objects.dart' as objects;
import 'method_get_client_dispatch.dart' as dispatch;
import 'dart:async';

class FoosGetRequest extends streamy.HttpRequest {

  int get fooId => parameters[r'fooId'];
  void set fooId(int value) {
    parameters[r'fooId'] = value;
  }

  static final String API_TYPE = r'FoosGetRequest';

  String get apiType => r'FoosGetRequest';

  bool get hasPayload => false;

  String get httpMethod => r'GET';

  String get pathFormat => r'foos/{fooId}';

  List<String> get pathParameters => const [
    r'fooId',
  ];

  List<String> get queryParameters => const [
  ];

  FoosGetRequest(streamy.Root root) : super(root);

  int removeFooId() => parameters.remove(r'fooId');

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
