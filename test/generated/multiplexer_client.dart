library MultiplexerTest;

import 'package:streamy/streamy.dart' as streamy;
import 'package:fixnum/fixnum.dart' as fixnum;
import 'dart:async';
import 'multiplexer_client_resources.dart' as resources;
import 'package:streamy/base.dart' as base;

class MultiplexerTestResourceMixin {

  resources.FoosResource _foos;

  resources.FoosResource get foos {
    if (_foos == null) {
      _foos = new resources.FoosResource(this);
    }
    return _foos;
  }
}

class MultiplexerTest extends streamy.HttpRoot with MultiplexerTestResourceMixin {

  final streamy.RequestHandler requestHandler;

  final streamy.TransactionStrategy txStrategy;

  final streamy.Tracer tracer;

  String get apiType => r'MultiplexerTest';

  MultiplexerTest(streamy.RequestHandler this.requestHandler, {String servicePath: r'multiplexerTest/v1/', streamy.TransactionStrategy this.txStrategy, streamy.Tracer this.tracer: const streamy.NoopTracer()}) : super(r'multiplexerTest/v1/');

  Stream send(streamy.Request request) => requestHandler.handle(request, tracer.trace(request));
}

class MultiplexerTestTransaction extends streamy.HttpTransactionRoot with MultiplexerTestResourceMixin {
}
