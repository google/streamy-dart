library streamy.runtime.request.test;

import 'package:unittest/unittest.dart';
import 'package:streamy/streamy.dart';

class RequestWithQueryParams extends Request {

  RequestWithQueryParams() : super(null);
  Request clone() => null;
  bool get hasPayload => false;
  String get httpMethod => null;
  get responseDeserializer => null;

  String get pathFormat => "/test";
  List<String> get pathParameters => [];
  List<String> get queryParameters => ["foo"];
}

class RequestWithPathParams extends Request {

  RequestWithPathParams() : super(null);
  Request clone() => null;
  bool get hasPayload => false;
  String get httpMethod => null;
  get responseDeserializer => null;

  String get pathFormat => "/test/{bar}";
  List<String> get pathParameters => ["bar"];
  List<String> get queryParameters => [];
}

main() {
  group("Request", () {
    test("should escape query parameters", () {
      var req = new RequestWithQueryParams()
        ..parameters["foo"] = "a@b c& d";
      expect(req.path, "/test?foo=a%40b+c%26+d");  // query component encoding
    });
    test("should escape path parameters", () {
      var req = new RequestWithPathParams()
        ..parameters["bar"] = "a@b c& d";
      expect(req.path, "/test/a%40b%20c%26%20d");  // component encoding
    });
  });
}
