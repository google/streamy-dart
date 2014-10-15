library streamy.runtime.request.test;

import 'package:unittest/unittest.dart';
import 'package:streamy/streamy.dart';

class RequestWithQueryParams extends HttpRequest {

  RequestWithQueryParams() : super(null);
  Request clone() => null;
  bool get hasPayload => false;
  String get httpMethod => null;
  get responseDeserializer => null;

  String get pathFormat => "/test";
  List<String> get pathParameters => [];
  List<String> get queryParameters => ["foo"];
}

class RequestWithPathParams extends HttpRequest {

  RequestWithPathParams() : super(null);
  Request clone() => null;
  bool get hasPayload => false;
  String get httpMethod => null;
  get responseDeserializer => null;

  String get pathFormat => "/test/{bar}";
  List<String> get pathParameters => ["bar"];
  List<String> get queryParameters => [];
}

class RequestWithReservedExpansionPathParam extends HttpRequest {

  RequestWithReservedExpansionPathParam() : super(null);
  Request clone() => null;
  bool get hasPayload => false;
  String get httpMethod => null;
  get responseDeserializer => null;

  String get pathFormat => "/test/{+bar}";
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
    test("adds local parameters properly", () {
      var req = new RequestWithQueryParams()
        ..parameters["foo"] = "test1"
        ..localParameters["baz"] = 'test2';
      expect(req.path, "/test?foo=test1&baz=test2");
    });
    test("should allow slashes in Reserved Expansion path parameters", () {
      var req = new RequestWithReservedExpansionPathParam()
        ..parameters["bar"] = "a@b/c&d";
      expect(req.path, "/test/a%40b/c%26d"); // slashes allowed
    });
  });
}
