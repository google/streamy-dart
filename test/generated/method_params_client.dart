library MethodParamsTest;

import 'package:streamy/streamy.dart' as streamy;
import 'package:fixnum/fixnum.dart' as fixnum;
import 'dart:async';
import 'method_params_client_resources.dart' as resources;
import 'package:streamy/base.dart' as base;

class MethodParamsTestResourceMixin {

  resources.FoosResource _foos;

  resources.FoosResource get foos {
    if (_foos == null) {
      _foos = new resources.FoosResource(this);
    }
    return _foos;
  }
}

class MethodParamsTest extends streamy.HttpRoot with MethodParamsTestResourceMixin {

  final streamy.RequestHandler requestHandler;

  final streamy.TransactionStrategy txStrategy;

  final streamy.Tracer tracer;

  String get apiType => r'MethodParamsTest';

  MethodParamsTest(streamy.RequestHandler this.requestHandler, {String servicePath: r'paramsTest/v1/', streamy.TransactionStrategy this.txStrategy, streamy.Tracer this.tracer: const streamy.NoopTracer()}) : super(r'paramsTest/v1/');

  Stream send(streamy.Request request) => requestHandler.handle(request, tracer.trace(request));
}

class MethodParamsTestTransaction extends streamy.HttpTransactionRoot with MethodParamsTestResourceMixin {
}
