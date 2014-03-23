/**
 * WARNING: GENERATED CODE. DO NOT EDIT BY HAND.
 * 
 */
library addendumapi;
import 'dart:async';
import 'package:streamy/streamy.dart' as streamy;
import 'addendum_client_resources.dart' as res;

abstract class AddendumApiResourcesMixin {
  res.FoosResource _foos;
  res.FoosResource get foos {
    if (_foos == null) {
      _foos = new res.FoosResource(this as streamy.Root);
    }
    return _foos;
  }
}

class AddendumApi
    extends streamy.Root
    with AddendumApiResourcesMixin {
  static final API_TYPE = r'AddendumTest';
  String get apiType => API_TYPE;
  final streamy.TransactionStrategy _txStrategy;
  final streamy.RequestHandler requestHandler;
  final streamy.Tracer _tracer;
  AddendumApi(
      this.requestHandler,
      {String servicePath: 'addendum/v1/',
      streamy.TypeRegistry typeRegistry: streamy.EMPTY_REGISTRY,
      streamy.TransactionStrategy txStrategy: null,
      streamy.Tracer tracer: const streamy.NoopTracer()}) :
          super(typeRegistry, servicePath),
          this._txStrategy = txStrategy,
          this._tracer = tracer;
  Stream send(streamy.Request request) =>
      requestHandler.handle(request, _tracer.trace(request));
  AddendumApiTransaction beginTransaction() =>
      new AddendumApiTransaction(typeRegistry, servicePath,
          _txStrategy.beginTransaction());
}

/// Provides the same API as [AddendumApi] but runs all requests as
/// part of the same transaction.
class AddendumApiTransaction
    extends streamy.TransactionRoot
    with AddendumApiResourcesMixin {
  static final API_TYPE = r'AddendumTestTransaction';
  String get apiType => API_TYPE;
  AddendumApiTransaction(
      streamy.TypeRegistry typeRegistry,
      String servicePath,
      streamy.Transaction tx) : super(typeRegistry, servicePath, tx);
}
