library Bank.null;

import 'package:streamy/streamy.dart' as streamy;
import 'package:fixnum/fixnum.dart' as fixnum;
import 'dart:async';
import 'bank_api_client_resources.dart' as resources;
import 'package:streamy/base.dart' as base;

class BankResourceMixin {

  resources.BranchesResource _branches;

  resources.BranchesResource get branches {
    if (_branches == null) {
      _branches = new resources.BranchesResource(this);
    }
    return _branches;
  }
}

class Bank extends streamy.HttpRoot with BankResourceMixin {

  final streamy.RequestHandler requestHandler;

  final streamy.TransactionStrategy txStrategy;

  final streamy.Tracer tracer;

  static final String API_TYPE = r'Bank';

  String get apiType => r'Bank';

  Bank(streamy.RequestHandler this.requestHandler, {streamy.TransactionStrategy this.txStrategy, streamy.Tracer this.tracer: const streamy.NoopTracer(), String servicePath: r'bank/v1/'}) : super(r'bank/v1/');

  Stream send(streamy.Request request) => requestHandler.handle(request, tracer.trace(request));
}

class BankTransaction extends streamy.HttpTransactionRoot with BankResourceMixin {
}
