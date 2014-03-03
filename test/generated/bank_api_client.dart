/**
 * WARNING: GENERATED CODE. DO NOT EDIT BY HAND.
 * 
 */
library bank;
import 'dart:async';
import 'package:streamy/streamy.dart' as streamy;
import 'bank_api_client_resources.dart' as res;

abstract class BankResourcesMixin {
  res.BranchesResource _branches;
  res.BranchesResource get branches {
    if (_branches == null) {
      _branches = new res.BranchesResource(this as streamy.Root);
    }
    return _branches;
  }
}

class Bank
    extends streamy.Root
    with BankResourcesMixin {
  static final API_TYPE = r'Bank';
  String get apiType => API_TYPE;
  final streamy.TransactionStrategy _txStrategy;
  final streamy.RequestHandler requestHandler;
  final streamy.Tracer _tracer;
  Bank(
      this.requestHandler,
      {String servicePath: 'bank/v1/',
      streamy.TypeRegistry typeRegistry: streamy.EMPTY_REGISTRY,
      streamy.TransactionStrategy txStrategy: null,
      streamy.Tracer tracer: const streamy.NoopTracer()}) :
          super(typeRegistry, servicePath),
          this._txStrategy = txStrategy,
          this._tracer = tracer;
  Stream send(streamy.Request request) =>
      requestHandler.handle(request, _tracer.trace(request));
  BankTransaction beginTransaction() =>
      new BankTransaction(typeRegistry, servicePath,
          _txStrategy.beginTransaction());
}

/// Provides the same API as [Bank] but runs all requests as
/// part of the same transaction.
class BankTransaction
    extends streamy.TransactionRoot
    with BankResourcesMixin {
  static final API_TYPE = r'BankTransaction';
  String get apiType => API_TYPE;
  BankTransaction(
      streamy.TypeRegistry typeRegistry,
      String servicePath,
      streamy.Transaction tx) : super(typeRegistry, servicePath, tx);
}
