/**
 * WARNING: GENERATED CODE. DO NOT EDIT BY HAND.
 * 
 */
library methodgettest;
import 'dart:async';
import 'package:streamy/streamy.dart' as streamy;
import 'method_get_client_resources.dart' as res;

abstract class MethodGetTestResourcesMixin {
  res.FoosResource _foos;
  res.FoosResource get foos {
    if (_foos == null) {
      _foos = new res.FoosResource(this as streamy.Root);
    }
    return _foos;
  }
}

class MethodGetTest
    extends streamy.Root
    with MethodGetTestResourcesMixin {
  static final API_TYPE = r'MethodGetTest';
  String get apiType => API_TYPE;
  final streamy.TransactionStrategy _txStrategy;
  final streamy.RequestHandler requestHandler;
  final streamy.Tracer _tracer;
  MethodGetTest(
      this.requestHandler,
      {String servicePath: 'getTest/v1/',
      streamy.TypeRegistry typeRegistry: streamy.EMPTY_REGISTRY,
      streamy.TransactionStrategy txStrategy: null,
      streamy.Tracer tracer: const streamy.NoopTracer()}) :
          super(typeRegistry, servicePath),
          this._txStrategy = txStrategy,
          this._tracer = tracer;
  Stream send(streamy.Request request) =>
      requestHandler.handle(request, _tracer.trace(request));
  MethodGetTestTransaction beginTransaction() =>
      new MethodGetTestTransaction(typeRegistry, servicePath,
          _txStrategy.beginTransaction());
}

/// Provides the same API as [MethodGetTest] but runs all requests as
/// part of the same transaction.
class MethodGetTestTransaction
    extends streamy.TransactionRoot
    with MethodGetTestResourcesMixin {
  static final API_TYPE = r'MethodGetTestTransaction';
  String get apiType => API_TYPE;
  MethodGetTestTransaction(
      streamy.TypeRegistry typeRegistry,
      String servicePath,
      streamy.Transaction tx) : super(typeRegistry, servicePath, tx);
}
