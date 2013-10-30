/**
 * WARNING: This code was generated from templates in
 * folder templates. Do not edit by hand.
 */
library method_params;
import 'dart:async';
import 'package:fixnum/fixnum.dart' as fixnum;
import 'package:streamy/streamy.dart' as streamy;
import 'package:quiver/collection.dart' as collect;
import 'package:observe/observe.dart' as obs;

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
    param3 = new List<String>();
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
  List<String> get param3 => parameters['param3'];
  set param3(List<String> value) {
    parameters['param3'] = value;
  }
  List<String> removeParam3() => parameters.remove('param3');
  Stream<Response> _sendDirect() => this.root.send(this);
  Stream<Response> sendRaw() =>
      _sendDirect();
  Stream<Response> send() =>
      _sendDirect().map((response) => response.entity);
  StreamSubscription listen(void onData(event)) =>
      _sendDirect().map((response) => response.entity).listen(onData);
  FoosGetRequest clone() => streamy.internalCloneFrom(new FoosGetRequest(root), this);
  streamy.Deserializer get responseDeserializer => (String str, streamy.Trace trace) =>
      new streamy.EmptyEntity();
}

class FoosResource {
  final MethodParamsTest _root;
  static final List<String> KNOWN_METHODS = [
    'get',
  ];
  FoosResource(this._root);

  /// Gets a foo
  FoosGetRequest get(String barId, int fooId) {
    var request = new FoosGetRequest(_root);
    if (barId != null) {
      request.barId = barId;
    }
    if (fooId != null) {
      request.fooId = fooId;
    }
    return request;
  }
}

class MethodParamsTest extends streamy.Root {
  FoosResource _foos;
  FoosResource get foos {
    if (_foos == null) {
      _foos = new FoosResource(this);
    }
    return _foos;
  }
  final streamy.RequestHandler requestHandler;
  final streamy.Tracer tracer;
  final String servicePath;
  MethodParamsTest(this.requestHandler, {this.servicePath: 'paramsTest/v1/',
      streamy.TypeRegistry typeRegistry: streamy.EMPTY_REGISTRY, this.tracer: const streamy.NoopTracer()}) : super(typeRegistry);
  Stream<streamy.Response> send(streamy.Request request) => requestHandler.handle(request, tracer.trace(request));
}
