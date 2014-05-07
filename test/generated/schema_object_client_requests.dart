library SchemaObjectTest.requests;

import 'package:streamy/streamy.dart' as streamy;
import 'package:fixnum/fixnum.dart' as fixnum;
import 'schema_object_client_objects.dart' as objects;
import 'schema_object_client_dispatch.dart' as dispatch;
import 'dart:async';
import 'package:streamy/base.dart' as base;

class -some-resource--some-method-Request extends streamy.HttpRequest {

  static final List<String> KNOWN_PARAMETERS = const [
    r'-path param-',
    r'-query param-',
  ];

  int get -path param- => parameters[r'-path param-'];
  void set -path param-(int value) {
    parameters[r'-path param-'] = value;
  }

  int get -query param- => parameters[r'-query param-'];
  void set -query param-(int value) {
    parameters[r'-query param-'] = value;
  }

  String get apiType => r'-some-resource--some-method-Request';

  bool get hasPayload => false;

  String get httpMethod => r'GET';

  String get pathFormat => r'foos/{fooId}';

  List<String> get pathParameters => const [
    r'-path param-',
    r'-query param-',
  ];

  List<String> get queryParameters => const [
  ];

  -some-resource--some-method-Request(streamy.Root root) : super(root);

  int remove-path param-() => parameters.remove(r'-path param-');

  int remove-query param-() => parameters.remove(r'-query param-');

  Stream<streamy.Response<objects.-some-entity->> _sendDirect() => root.send(this);

  objects.-some-entity- unmarshalResponse(dispatch.Marshaller marshaller, Map data) => marshaller.unmarshal-some-entity-(data);

  Stream<objects.-some-entity-> send() {
    return _sendDirect()
      .map((response) => response.entity);
  }

  Stream<streamy.Response<objects.-some-entity->> sendRaw() {
    return _sendDirect();
  }

  StreamSubscription<objects.-some-entity-> listen() {
    return _sendDirect()
      .map((response) => response.entity)
      .listen(onData);
  }

  -some-resource--some-method-Request clone() => streamy.internalCloneFrom(new -some-resource--some-method-Request(root), this);
}
