/**
 * WARNING: GENERATED CODE. DO NOT EDIT BY HAND.
 * 
 */
library schemaobjecttest;
import 'dart:async';
import 'package:streamy/streamy.dart' as streamy;
import 'schema_object_client_resources.dart' as res;

abstract class SchemaObjectTestResourcesMixin {
  res.$some_resource_Resource _$some_resource_;
  res.$some_resource_Resource get $some_resource_ {
    if (_$some_resource_ == null) {
      _$some_resource_ = new res.$some_resource_Resource(this as streamy.Root);
    }
    return _$some_resource_;
  }
}

class SchemaObjectTest
    extends streamy.Root
    with SchemaObjectTestResourcesMixin {
  String get apiType => r'SchemaObjectTest';
  final streamy.TransactionStrategy _txStrategy;
  final streamy.RequestHandler requestHandler;
  final streamy.Tracer _tracer;
  SchemaObjectTest(
      this.requestHandler,
      {String servicePath: 'schemaObjectTest/v1/',
      streamy.TypeRegistry typeRegistry: streamy.EMPTY_REGISTRY,
      streamy.TransactionStrategy txStrategy: null,
      streamy.Tracer tracer: const streamy.NoopTracer()}) :
          super(typeRegistry, servicePath),
          this._txStrategy = txStrategy,
          this._tracer = tracer;
  Stream send(streamy.Request request) =>
      requestHandler.handle(request, _tracer.trace(request));
  SchemaObjectTestTransaction beginTransaction() =>
      new SchemaObjectTestTransaction(typeRegistry, servicePath,
          _txStrategy.beginTransaction());
}

/// Provides the same API as [SchemaObjectTest] but runs all requests as
/// part of the same transaction.
class SchemaObjectTestTransaction
    extends streamy.TransactionRoot
    with SchemaObjectTestResourcesMixin {
  String get apiType => r'SchemaObjectTestTransaction';
  SchemaObjectTestTransaction(
      streamy.TypeRegistry typeRegistry,
      String servicePath,
      streamy.Transaction tx) : super(typeRegistry, servicePath, tx);
}
