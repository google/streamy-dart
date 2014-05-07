library MethodPostTest;

import 'package:streamy/streamy.dart' as streamy;
import 'package:fixnum/fixnum.dart' as fixnum;
import 'dart:async';
import 'method_post_client_resources.dart' as resources;
import 'package:streamy/base.dart' as base;

class MethodPostTestResourceMixin {

  resources.FoosResource _foos;

  resources.FoosResource get foos {
    if (_foos == null) {
      _foos = new resources.FoosResource(this);
    }
    return _foos;
  }
}

class MethodPostTest extends streamy.HttpRoot with MethodPostTestResourceMixin {

  final streamy.RequestHandler requestHandler;

  final streamy.TransactionStrategy txStrategy;

  final streamy.Tracer tracer;

  String get apiType => r'MethodPostTest';

  MethodPostTest(streamy.RequestHandler this.requestHandler, {String servicePath: r'postTest/v1/', streamy.TransactionStrategy this.txStrategy, streamy.Tracer this.tracer: const streamy.NoopTracer()}) : super(r'postTest/v1/');

  Stream send(streamy.Request request) => requestHandler.handle(request, tracer.trace(request));
}

class MethodPostTestTransaction extends streamy.HttpTransactionRoot with MethodPostTestResourceMixin {
}
