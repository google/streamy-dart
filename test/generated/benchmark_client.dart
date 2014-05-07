library SchemaObjectTest;

import 'package:streamy/streamy.dart' as streamy;
import 'package:fixnum/fixnum.dart' as fixnum;
import 'dart:async';
import 'benchmark_client_resources.dart' as resources;
import 'package:streamy/base.dart' as base;

class SchemaObjectTestResourceMixin {
}

class SchemaObjectTest extends streamy.HttpRoot with SchemaObjectTestResourceMixin {

  final streamy.RequestHandler requestHandler;

  final streamy.TransactionStrategy txStrategy;

  final streamy.Tracer tracer;

  String get apiType => r'SchemaObjectTest';

  SchemaObjectTest(streamy.RequestHandler this.requestHandler, {String servicePath: r'schemaObjectTest/v1/', streamy.TransactionStrategy this.txStrategy, streamy.Tracer this.tracer: const streamy.NoopTracer()}) : super(r'schemaObjectTest/v1/');

  Stream send(streamy.Request request) => requestHandler.handle(request, tracer.trace(request));
}

class SchemaObjectTestTransaction extends streamy.HttpTransactionRoot with SchemaObjectTestResourceMixin {
}
