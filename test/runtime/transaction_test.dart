library streamy.runtime.transaction.test;

import 'dart:async';
import 'package:streamy/streamy.dart';
import 'package:streamy/testing/testing.dart';
import 'package:unittest/unittest.dart';
import '../generated/bank_api_client.dart';

main() {
  group('Transaction', () {
    TestTxnStrategy txStrategy;
    Bank root;

    setUp(() {
      txStrategy = new TestTxnStrategy();
      root = new Bank(null, txStrategy: txStrategy);
    });

    test('should be created by the root object', () {
      var tx = root.beginTransaction();
      expect(tx, isNotNull);
    });

    test('should receive requests from the transactional root', () {
      var tx = root.beginTransaction();
      TestTxn tximpl = txStrategy.lastTransaction;
      expect(tximpl.requests, hasLength(0));
      tx.send(TEST_GET_REQUEST);
      expect(tximpl.requests, hasLength(1));
      expect(tximpl.requests[0], same(TEST_GET_REQUEST));
    });

    test('should commit when root commits', () {
      var tx = root.beginTransaction();
      TestTxn tximpl = txStrategy.lastTransaction;
      tx.commit();
      expect(tximpl.committed, isTrue);
    });
  });
}

class TestTxnStrategy implements TransactionStrategy {
  TestTxn lastTransaction;
  Transaction beginTransaction() {
    return lastTransaction = new TestTxn();
  }
}

class TestTxn implements Transaction {
  bool committed = false;
  List<Request> requests = [];

  Future commit() {
    committed = true;
  }

  Stream send(Request request) {
    requests.add(request);
  }
}
