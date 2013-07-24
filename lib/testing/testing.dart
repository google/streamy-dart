// Testing utilities for Streamy
library streamy.testing;

import 'dart:async';
import 'package:unittest/unittest.dart';
import 'package:streamy/streamy.dart';

/**
 * Use this method to build test request handlers that return pre-defined
 * value or error responses.
 *
 * Example:
 *
 * var handler = testRequestHandler()
 *   ..value(testResponse, times: 2)  // returns testResponse 2 times
 *   ..proxyError('Not found', 404, times: 4)  // returns 404 error 4 times
 *   ..value(testResponse)  // returns testResponse once
 *   ..error(new ArgumentError("test"))  // return custom error once
 *   .build();  // returns the test handler
 */
TestRequestHandlerBuilder testRequestHandler() =>
  new TestRequestHandlerBuilder._private();

class _TestRequestHandler extends RequestHandler {
  int _index = 0;
  final _responses = <_TestResponse>[];

  _TestRequestHandler._private();

  Stream handle(Request request) {
    if (_index >= _responses.length) {
      fail("Too many requests. Expected: ${_responses.length} requests but " +
          "got ${_index + 1} requests");
    }
    var resp = _responses[_index];
    _index++;
    if (resp is _TestValueResponse) {
      return new Stream.fromIterable([resp.value]);
    } else if (resp is _TestErrorResponse) {
      return new Stream.fromFuture(new Future.error(resp.error));
    } else {
      throw new StateError("Unexpected type: ${resp.runtimeType}");
    }
  }
}

abstract class _TestResponse {
}

class _TestValueResponse extends _TestResponse {
  final value;
  _TestValueResponse(this.value);
}

class _TestErrorResponse extends _TestResponse {
  final error;
  _TestErrorResponse(this.error);
}

class TestRequestHandlerBuilder {
  final _handler = new _TestRequestHandler._private();

  TestRequestHandlerBuilder._private();

  void value(value, {int times: 1}) {
    for (int i = 0; i < times; i++) {
      _handler._responses.add(new _TestValueResponse(value));
    }
  }

  void error(error, {int times: 1}) {
    for (int i = 0; i < times; i++) {
      _handler._responses.add(new _TestErrorResponse(error));
    }
  }

  void proxyError(String statusMessage, int statusCode,
                                       {Map jsonError, int times: 1}) {
    for (int i = 0; i < times; i++) {
      error(new ProxyException(statusMessage, statusCode, jsonError));
    }
  }

  RequestHandler build() => _handler;
}

/// Use these requests when request contents don't matter.
final Request TEST_GET_REQUEST = new _TestRequest("GET");
final Request TEST_DELETE_REQUEST = new _TestRequest("DELETE");
// TODO(yjbanov): add POST and PUT test requests

class _TestRequest extends Request {
  final String _httpMethod;

  _TestRequest(this._httpMethod) : super(null);

  Request clone() => this;  // it's a const, so there's nothing to clone

  bool get hasPayload => false;

  String get httpMethod => _httpMethod;

  String get pathFormat => "/test${_httpMethod}";

  List<String> get pathParameters => [];

  List<String> get queryParameters => [];

  /// [TestGetRequest] is designed to be used along with a test request handler
  /// (see [testRequestHandler]), which returns canned responses and therefore
  /// we shouldn't ever reach this method.
  Deserializer get responseDeserializer {
    throw new StateError("Not supported");
  }
}
