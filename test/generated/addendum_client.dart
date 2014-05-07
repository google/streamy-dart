library AddendumTest;

import 'package:streamy/streamy.dart' as streamy;
import 'package:fixnum/fixnum.dart' as fixnum;
import 'dart:async';
import 'addendum_client_resources.dart' as resources;
import 'package:streamy/base.dart' as base;

/// Test client for addendum documents.
class AddendumTestResourceMixin {

  resources.FoosResource _foos;

  resources.FoosResource get foos {
    if (_foos == null) {
      _foos = new resources.FoosResource(this);
    }
    return _foos;
  }
}

class AddendumTest extends streamy.HttpRoot with AddendumTestResourceMixin {

  final streamy.RequestHandler requestHandler;

  final streamy.TransactionStrategy txStrategy;

  final streamy.Tracer tracer;

  String get apiType => r'AddendumTest';

  AddendumTest(streamy.RequestHandler this.requestHandler, {String servicePath: r'addendum/v1/', streamy.TransactionStrategy this.txStrategy, streamy.Tracer this.tracer: const streamy.NoopTracer()}) : super(r'addendum/v1/');

  Stream send(streamy.Request request) => requestHandler.handle(request, tracer.trace(request));
}

class AddendumTestTransaction extends streamy.HttpTransactionRoot with AddendumTestResourceMixin {
}
