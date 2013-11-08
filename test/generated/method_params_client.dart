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

class FoosResource {
  final streamy.Root _root;
  static final List<String> KNOWN_METHODS = [
    r'get',
  ];
  String get apiType => r'FoosResource';
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
      _foos = new FoosResource(this as streamy.Root);
    }
    return _foos;
  }
}

class MethodParamsTest
    extends streamy.Root
    with MethodParamsTestResourcesMixin {
  String get apiType => r'MethodParamsTest';
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
  String get apiType => r'MethodParamsTestTransaction';
  MethodParamsTestTransaction(
      streamy.TypeRegistry typeRegistry,
      String servicePath,
      streamy.Transaction tx) : super(typeRegistry, servicePath, tx);
}
