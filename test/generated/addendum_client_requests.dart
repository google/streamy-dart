library AddendumTest.null.requests;

import 'package:streamy/streamy.dart' as streamy;
import 'package:fixnum/fixnum.dart' as fixnum;
import 'addendum_client_objects.dart' as objects;
import 'addendum_client_dispatch.dart' as dispatch;
import 'dart:async';
import 'package:streamy/base.dart' as base;

class FoosGetRequest extends streamy.HttpRequest {

  static final List<String> KNOWN_PARAMETERS = const [
    r'fooId',
  ];

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

  Stream<objects.Foo> send(bool dedup: r'true', int ttl: 800, String foo: r'Bar') {
    local[r'dedup'] = dedup;
    local[r'ttl'] = ttl;
    local[r'foo'] = foo;
    return _sendDirect()
      .map((response) => response.entity);
  }

  Stream<streamy.Response<objects.Foo>> sendRaw(bool dedup: r'true', int ttl: 800, String foo: r'Bar') {
    local[r'dedup'] = dedup;
    local[r'ttl'] = ttl;
    local[r'foo'] = foo;
    return _sendDirect();
  }

  StreamSubscription<objects.Foo> listen(bool dedup: r'true', int ttl: 800, String foo: r'Bar') {
    local[r'dedup'] = dedup;
    local[r'ttl'] = ttl;
    local[r'foo'] = foo;
    return _sendDirect()
      .map((response) => response.entity)
      .listen(onData);
  }

  FoosGetRequest clone() => streamy.internalCloneFrom(new FoosGetRequest(root), this);
}
