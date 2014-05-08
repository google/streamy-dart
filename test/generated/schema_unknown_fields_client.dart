/**
 * WARNING: GENERATED CODE. DO NOT EDIT BY HAND.
 * 
 */
library schemaunknownfieldstest;
import 'dart:async';
import 'package:streamy/streamy.dart' as streamy;
import 'schema_unknown_fields_client_resources.dart' as res;

abstract class SchemaUnknownFieldsTestResourcesMixin {
}

class SchemaUnknownFieldsTest
    extends streamy.Root
    with SchemaUnknownFieldsTestResourcesMixin {
  static final API_TYPE = r'SchemaUnknownFieldsTest';
  String get apiType => API_TYPE;
  final streamy.TransactionStrategy _txStrategy;
  final streamy.RequestHandler requestHandler;
  final streamy.Tracer _tracer;
  SchemaUnknownFieldsTest(
      this.requestHandler,
      {String servicePath: 'schemaUnknownFieldsTest/v1/',
      streamy.TypeRegistry typeRegistry: streamy.EMPTY_REGISTRY,
      streamy.TransactionStrategy txStrategy: null,
      streamy.Tracer tracer: const streamy.NoopTracer()}) :
          super(typeRegistry, servicePath),
          this._txStrategy = txStrategy,
          this._tracer = tracer;
  Stream send(streamy.Request request) =>
      requestHandler.handle(request, _tracer.trace(request));
  SchemaUnknownFieldsTestTransaction beginTransaction() =>
      new SchemaUnknownFieldsTestTransaction(typeRegistry, servicePath,
          _txStrategy.beginTransaction());
}

/// Provides the same API as [SchemaUnknownFieldsTest] but runs all requests as
/// part of the same transaction.
class SchemaUnknownFieldsTestTransaction
    extends streamy.TransactionRoot
    with SchemaUnknownFieldsTestResourcesMixin {
  static final API_TYPE = r'SchemaUnknownFieldsTestTransaction';
  String get apiType => API_TYPE;
  SchemaUnknownFieldsTestTransaction(
      streamy.TypeRegistry typeRegistry,
      String servicePath,
      streamy.Transaction tx) : super(typeRegistry, servicePath, tx);
}
