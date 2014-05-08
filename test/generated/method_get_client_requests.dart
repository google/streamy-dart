/**
 * WARNING: GENERATED CODE. DO NOT EDIT BY HAND.
 * 
 */
library methodgettest.requests;
import 'dart:async';
import 'package:fixnum/fixnum.dart' as fixnum;
import 'package:streamy/streamy.dart' as streamy;
import 'method_get_client_objects.dart' as obj;

/// Gets a foo
class FoosGetRequest extends streamy.Request {
  static final List<String> KNOWN_PARAMETERS = [
    r'fooId',
  ];
  static final API_TYPE = r'FoosGetRequest';
  String get apiType => API_TYPE;
  String get httpMethod => 'GET';
  String get pathFormat => 'foos/{fooId}';
  bool get hasPayload => false;
  FoosGetRequest(streamy.Root root) : super(root) {
  }
  List<String> get pathParameters => const [r'fooId',];
  List<String> get queryParameters => const [];

  /// Primary key of foo
  int get fooId => parameters[r'fooId'];
  set fooId(int value) {
    parameters[r'fooId'] = value;
  }
  int removeFooId() => parameters.remove(r'fooId');
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
