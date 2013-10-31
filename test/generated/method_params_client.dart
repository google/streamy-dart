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
  String get apiType => 'FoosGetRequest';
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
  Stream send() =>
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
  String get apiType => 'FoosResource';
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

abstract class MethodParamsTestResourcesMixin {
  FoosResource _foos;
  FoosResource get foos {
    if (_foos == null) {
      _foos = new FoosResource(this);
    }
    return _foos;
  }
}

class MethodParamsTest
    extends streamy.Root
    with MethodParamsTestResourcesMixin {
  String get apiType => 'MethodParamsTest';
  final streamy.TransactionStrategy _txStrategy;
  final streamy.RequestHandler requestHandler;
  final streamy.Tracer _tracer;
  MethodParamsTest(
      this.requestHandler,
      {String servicePath: 'paramsTest/v1/',
      streamy.TypeRegistry typeRegistry: streamy.EMPTY_REGISTRY,
      streamy.TransactionStrategy txStrategy: null,
      streamy.Tracer tracer: const streamy.NoopTracer()}) :
          super(typeRegistry, servicePath),
          this._txStrategy = txStrategy,
          this._tracer = tracer;
  Stream send(streamy.Request request) =>
      requestHandler.handle(request, _tracer.trace(request));
  MethodParamsTestTransaction beginTransaction() =>
      new MethodParamsTestTransaction(typeRegistry, servicePath,
          _txStrategy.beginTransaction());
}

/// Provides the same API as [MethodParamsTest] but runs all requests as
/// part of the same transaction.
class MethodParamsTestTransaction
    extends streamy.TransactionRoot
    with MethodParamsTestResourcesMixin {
  String get apiType => 'MethodParamsTestTransaction';
  MethodParamsTestTransaction(
      streamy.TypeRegistry typeRegistry,
      String servicePath,
      streamy.Transaction tx) : super(typeRegistry, servicePath, tx);
}
