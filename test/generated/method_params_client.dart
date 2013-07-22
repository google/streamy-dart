/**
 * WARNING: This code was generated from templates in
 * folder templates. Do not edit by hand.
 */
library method_params;
import 'dart:async';
import 'dart:json';
import 'package:streamy/streamy.dart' as streamy;
import 'package:streamy/collections.dart';
Map<String, streamy.TypeInfo> TYPE_REGISTRY = {
};

/// Gets a foo
class FoosGetRequest extends streamy.Request {
  static final List<String> KNOWN_PARAMETERS = [
    'barId',
    'fooId',
    'param1',
    'param2',
    'param3',
  ];
  String get httpMethod => 'GET';
  String get pathFormat => 'foos/{barId}/{fooId}';
  bool get hasPayload => false;
  FoosGetRequest(MethodParamsTest root) : super(root) {
    param3 = new ComparableList<String>();
  }
  List<String> get pathParameters => const ['barId','fooId',];
  List<String> get queryParameters => const ['param1','param2','param3',];

  /// Primary key of bar
  String get barId => parameters['barId'];
  set barId(String value) {
    parameters['barId'] = value;
  }
  String removeBarId() => parameters.remove('barId');

  /// Primary key of foo
  int get fooId => parameters['fooId'];
  set fooId(int value) {
    parameters['fooId'] = value;
  }
  int removeFooId() => parameters.remove('fooId');

  /// A parameter
  bool get param1 => parameters['param1'];
  set param1(bool value) {
    parameters['param1'] = value;
  }
  bool removeParam1() => parameters.remove('param1');

  /// Another parameter
  bool get param2 => parameters['param2'];
  set param2(bool value) {
    parameters['param2'] = value;
  }
  bool removeParam2() => parameters.remove('param2');

  /// A repeated parameter
  ComparableList<String> get param3 => parameters['param3'];
  set param3(ComparableList<String> value) {
    parameters['param3'] = value;
  }
  ComparableList<String> removeParam3() => parameters.remove('param3');
  Stream send() =>
      this.root.send(this);
  StreamSubscription listen(void onData(event)) =>
      this.root.send(this).listen(onData);
  FoosGetRequest clone() => streamy.internalCloneFrom(new FoosGetRequest(root), this);
  streamy.Deserializer get responseDeserializer => (String str) => new streamy.EmptyEntity();
}

class FoosResource {
  final MethodParamsTest _root;
  static final List<String> KNOWN_METHODS = [
    'get',
  ];
  FoosResource(this._root);

  /// Gets a foo
  FoosGetRequest get(String barId, int fooId,
      { bool param1, bool param2, List<String> param3 } ) {
    var request = new FoosGetRequest(_root);
    request.param1 = (param1 != null ? param1 : request.param1);
    request.param2 = (param2 != null ? param2 : request.param2);
    if (param3 != null) {
      request.param3.addAll(param3);
    }
    request.barId = (barId != null ? barId : request.barId);
    request.fooId = (fooId != null ? fooId : request.fooId);
    return request;
  }
}

class MethodParamsTest extends streamy.Root {
  FoosResource _foos;
  FoosResource get foos => _foos;
  final streamy.RequestHandler requestHandler;
  final String servicePath;
  MethodParamsTest(this.requestHandler, {this.servicePath: 'paramsTest/v1/'}) {
    this._foos = new FoosResource(this);
  }
  Stream send(streamy.Request request) => requestHandler.handle(request);
}
