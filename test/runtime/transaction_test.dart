library streamy.runtime.transaction.test;

import 'dart:async';
import 'package:fixnum/fixnum.dart';
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

    test('should pass end-to-end test', () {
      var tx = root.beginTransaction();
      TestTxn tximpl = txStrategy.lastTransaction;
      expect(tximpl.requests, hasLength(0));
      var req = tx.branches.insert(new Branch()..id = new Int64(123));
      var resp = new Response(null, 'RPC', 0);
      fakeResponse[req] = resp;

      Response actual;
      req.sendRaw().listen((r) { actual = r; });

      // Before we commit we expect requests to be accumulated
      expect(tximpl.requests, hasLength(1));
      expect(tximpl.requests[0], same(req));

      // After we commit the requests should be flushed and response received
      tx.commit();
      expect(tximpl.requests, hasLength(0));
      expect(actual, isNotNull);
      expect(actual, same(resp));
    });
  });
}

class TestTxnStrategy implements TransactionStrategy {
  TestTxn lastTransaction;
  Transaction beginTransaction() {
    return lastTransaction = new TestTxn();
  }
}

final fakeResponse = new Expando<Response>();
final committer = new Expando<Function>();

class TestTxn implements Transaction {
  bool committed = false;
  List<Request> requests = [];

  Future commit() {
    for (var request in requests) {
      committer[request]();
    }
    requests = [];
    committed = true;
  }

  Stream send(Request request) {
    requests.add(request);
    var response = new StreamController(sync: true);
    committer[request] = () {
      response.add(fakeResponse[request]);
    };
    return response.stream;
  }
}
