library MethodParamsTest.requests;

import 'package:streamy/streamy.dart' as streamy;
import 'package:fixnum/fixnum.dart' as fixnum;
import 'method_params_client_objects.dart' as objects;
import 'method_params_client_dispatch.dart' as dispatch;
import 'dart:async';
import 'package:streamy/base.dart' as base;

class FoosGetRequest extends streamy.HttpRequest {

  static final List<String> KNOWN_PARAMETERS = const [
    r'barId',
    r'fooId',
    r'param1',
    r'param2',
    r'param3',
  ];

  String get barId => parameters[r'barId'];
  void set barId(String value) {
    parameters[r'barId'] = value;
  }

  int get fooId => parameters[r'fooId'];
  void set fooId(int value) {
    parameters[r'fooId'] = value;
  }

  bool get param1 => parameters[r'param1'];
  void set param1(bool value) {
    parameters[r'param1'] = value;
  }

  bool get param2 => parameters[r'param2'];
  void set param2(bool value) {
    parameters[r'param2'] = value;
  }

  List<String> get param3 => parameters[r'param3'];
  void set param3(List<String> value) {
    parameters[r'param3'] = value;
  }

  String get apiType => r'FoosGetRequest';

  bool get hasPayload => false;

  String get httpMethod => r'GET';

  String get pathFormat => r'foos/{barId}/{fooId}';

  List<String> get pathParameters => const [
    r'barId',
    r'fooId',
  ];

  List<String> get queryParameters => const [
    r'param1',
    r'param2',
    r'param3',
  ];

  FoosGetRequest(streamy.Root root) : super(root) {
    parameters
      ..[r'param3'] = <String>[];
  }

  String removeBarId() => parameters.remove(r'barId');

  int removeFooId() => parameters.remove(r'fooId');

  bool removeParam1() => parameters.remove(r'param1');

  bool removeParam2() => parameters.remove(r'param2');

  List<String> removeParam3() => parameters.remove(r'param3');

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

  FoosGetRequest clone() => streamy.internalCloneFrom(new FoosGetRequest(root), this);
}
