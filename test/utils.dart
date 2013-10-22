/// Test utilities for Streamy itself
library streamy.test.utils;

import 'dart:async';
import 'package:unittest/unittest.dart';

List<Function> _asyncQueue = [];
List _asyncErrors = [];
bool _wrappedAsync = false;

/**
 * Run the async callbacks in the queue. If [runUntilEmpty] is true, then
 * run through the whole queue and if new items were added to the queue as the
 * result of the callback execution the new callbacks will be automatically
 * executed as well.
 */
nextTurn([bool runUntilEmpty = false]) {
  if (!_wrappedAsync) {
    throw 'You must wrap your test with async(() { ... })';
  }
  // copy the queue as it may change.
  do {
    var toRun = _asyncQueue;
    _asyncQueue = [];
    toRun.forEach((fn) => fn());
  } while (runUntilEmpty && !_asyncQueue.isEmpty);
}

/**
 * An alias for nextTurn(true).
 */
fastForward() => nextTurn(true);

/**
 * Makes sure there are no outstanding tasks in the queue
 */
expectAsyncQueueIsEmpty() {
  expect(_asyncQueue, isEmpty,
      reason: 'Async queue must be empty by the end of the test. '
              'Use nextTurn() or fastForward()');
}

/**
 * Queues microtasks so they can be run synchronously using [nextTurn] or
 * [fastForward].
 */
async(Function fn) =>
    () {
  if (_wrappedAsync) {
    throw 'Cannot double-wrap with async.';
  }
  _asyncQueue = [];
  _asyncErrors = [];

  _wrappedAsync = true;
  try {
    _asyncErrors = [];
    runZoned(fn,
        onError: (e) => _asyncErrors.add(e),
        zoneSpecification: new ZoneSpecification(scheduleMicrotask:
          (_0, _1, _2, asyncFn) => _asyncQueue.add(asyncFn)));

    _asyncErrors.forEach((e) {
      if (e is TestFailure) {
        throw e;
      }
      throw "During runZoned: $e.  Stack:\n${getAttachedStackTrace(e)}";
    });
  } finally {
    _wrappedAsync = false;
  }
};
