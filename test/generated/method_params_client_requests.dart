/**
 * WARNING: GENERATED CODE. DO NOT EDIT BY HAND.
 * 
 */
library methodparamstest.requests;
import 'dart:async';
import 'package:fixnum/fixnum.dart' as fixnum;
import 'package:streamy/streamy.dart' as streamy;
import 'method_params_client_objects.dart' as obj;

/// Gets a foo
class FoosGetRequest extends streamy.Request {
  static final List<String> KNOWN_PARAMETERS = [
    r'barId',
    r'fooId',
    r'param1',
    r'param2',
    r'param3',
  ];
  String get apiType => r'FoosGetRequest';
  String get httpMethod => 'GET';
  String get pathFormat => 'foos/{barId}/{fooId}';
  bool get hasPayload => false;
  FoosGetRequest(streamy.Root root) : super(root) {
    param3 = new List<String>();
  }
  List<String> get pathParameters => const [r'barId',r'fooId',];
  List<String> get queryParameters => const [r'param1',r'param2',r'param3',];

  /// Primary key of bar
  String get barId => parameters[r'barId'];
  set barId(String value) {
    parameters[r'barId'] = value;
  }
  String removeBarId() => parameters.remove(r'barId');

  /// Primary key of foo
  int get fooId => parameters[r'fooId'];
  set fooId(int value) {
    parameters[r'fooId'] = value;
  }
  int removeFooId() => parameters.remove(r'fooId');

  /// A parameter
  bool get param1 => parameters[r'param1'];
  set param1(bool value) {
    parameters[r'param1'] = value;
  }
  bool removeParam1() => parameters.remove(r'param1');

  /// Another parameter
  bool get param2 => parameters[r'param2'];
  set param2(bool value) {
    parameters[r'param2'] = value;
  }
  bool removeParam2() => parameters.remove(r'param2');

  /// A repeated parameter
  List<String> get param3 => parameters[r'param3'];
  set param3(List<String> value) {
    parameters[r'param3'] = value;
  }
  List<String> removeParam3() => parameters.remove(r'param3');
  Stream<streamy.Response> _sendDirect() => this.root.send(this);
  Stream<streamy.Response> sendRaw() =>
      _sendDirect();
  Stream send() =>
      _sendDirect().map((response) => response.entity);
  StreamSubscription listen(void onData(event)) =>
      _sendDirect().map((response) => response.entity).listen(onData);
  FoosGetRequest clone() => streamy.internalCloneFrom(new FoosGetRequest(root), this);
  streamy.Deserializer get responseDeserializer => (String str, streamy.Trace trace) =>
      new streamy.EmptyEntity();
}
