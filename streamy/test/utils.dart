/// Test utilities for Streamy itself
library streamy.test.utils;

import 'dart:async';
import 'package:unittest/unittest.dart';
import 'package:streamy/mixins/base_map.dart';
import 'package:streamy/streamy.dart';

final Matcher isType = new isAssignableTo<Type>();

/// A safer [isInstanceOf].
class isAssignableTo<T> extends Matcher {

  String _name;
  final _delegate = new isInstanceOf<T>();

  isAssignableTo([name = 'specified type']) {
    _name = name;
    try {
      expect(new Object(), isNot(_delegate));
    } on TestFailure catch(f) {
      throw new ArgumentError(
          'Seems like an unsupported type was passed to '
          'isAssignableTo. Three known possibilities:\n'
          ' - You are trying to check Object/dynamic\n'
          ' - The type does not exist\n'
          ' - The type exists but you forgot to import it');
    }
  }

  Description describe(Description description) =>
      description.add('assignable to ${_name}');

  bool matches(item, Map matchState) =>
      _delegate.matches(item, matchState);
}

/**
 * Makes an empty map-backed entity. Useful for testing.
 */
DynamicAccess makeEntity() {
  var entity = new MapBase();
  setMap(entity, {});
  return entity;
}

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
        onError: (e, s) {
          _asyncErrors.add([e, s]);
        },
        zoneSpecification: new ZoneSpecification(
            scheduleMicrotask: (_0, _1, _2, fn) {
              _asyncQueue.add(fn);
            },
            handleUncaughtError: (_, __, ___, e, s) {
              _asyncErrors.add([e, s]);
            }));

    _asyncErrors.forEach((e) {
      if (e[0] is TestFailure) {
        print('Stacktrace: ${e[1]}');
        throw e;
      }
      throw "During runZoned: $e. Stack:\n${e[1]}";
    });
  } finally {
    _wrappedAsync = false;
  }
};
