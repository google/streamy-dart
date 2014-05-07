library SchemaUnknownFieldsTest;

import 'package:streamy/streamy.dart' as streamy;
import 'package:fixnum/fixnum.dart' as fixnum;
import 'dart:async';
import 'schema_unknown_fields_client_resources.dart' as resources;
import 'package:streamy/base.dart' as base;

class SchemaUnknownFieldsTestResourceMixin {
}

class SchemaUnknownFieldsTest extends streamy.HttpRoot with SchemaUnknownFieldsTestResourceMixin {

  final streamy.RequestHandler requestHandler;

  final streamy.TransactionStrategy txStrategy;

  final streamy.Tracer tracer;

  String get apiType => r'SchemaUnknownFieldsTest';

  SchemaUnknownFieldsTest(streamy.RequestHandler this.requestHandler, {String servicePath: r'schemaUnknownFieldsTest/v1/', streamy.TransactionStrategy this.txStrategy, streamy.Tracer this.tracer: const streamy.NoopTracer()}) : super(r'schemaUnknownFieldsTest/v1/');

  Stream send(streamy.Request request) => requestHandler.handle(request, tracer.trace(request));
}

class SchemaUnknownFieldsTestTransaction extends streamy.HttpTransactionRoot with SchemaUnknownFieldsTestResourceMixin {
}
