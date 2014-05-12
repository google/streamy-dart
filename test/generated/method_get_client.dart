library MethodGetTest.null;

import 'package:streamy/streamy.dart' as streamy;
import 'package:fixnum/fixnum.dart' as fixnum;
import 'package:streamy/base.dart' as base;
import 'dart:async';
import 'method_get_client_resources.dart' as resources;

class MethodGetTestResourceMixin {

  resources.FoosResource _foos;

  resources.FoosResource get foos {
    if (_foos == null) {
      _foos = new resources.FoosResource(this);
    }
    return _foos;
  }
}

class MethodGetTest extends streamy.HttpRoot with MethodGetTestResourceMixin {

  final streamy.RequestHandler requestHandler;

  final streamy.TransactionStrategy txStrategy;

  final streamy.Tracer tracer;

  static final String API_TYPE = r'MethodGetTest';

  String get apiType => r'MethodGetTest';

  MethodGetTest(streamy.RequestHandler this.requestHandler, {streamy.TransactionStrategy this.txStrategy, streamy.Tracer this.tracer: const streamy.NoopTracer(), String servicePath: r'getTest/v1/'}) : super(r'getTest/v1/');

  Stream send(streamy.Request request) => requestHandler.handle(request, tracer.trace(request));
}

class MethodGetTestTransaction extends streamy.HttpTransactionRoot with MethodGetTestResourceMixin {
}
