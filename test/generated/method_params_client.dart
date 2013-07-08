/**
 * WARNING: This code was generated from templates in
 * folder templates. Do not edit by hand.
 */
library method_params;
import "dart:async";
import "dart:json";
import "package:streamy/streamy.dart" as streamy;
import "package:streamy/collections.dart";
Map<String, streamy.TypeInfo> TYPE_REGISTRY = {
};

class FoosGetRequest extends streamy.Request {
  static final List<String> KNOWN_PARAMETERS = [
    "barId",
    "fooId",
    "param1",
    "param2",
    "param3",
  ];
  String get httpMethod => "GET";
  String get pathFormat => "foos/{barId}/{fooId}";
  bool get hasPayload => false;
  FoosGetRequest(MethodParamsTest root) : super(root) {
    param3 = new ComparableList<String>();
  }
  List<String> get pathParameters => const ["barId","fooId",];
  List<String> get queryParameters => const ["param1","param2","param3",];
  String get barId => parameters["barId"];
  set barId(String value) {
    parameters["barId"] = value;
  }
  String removeBarId() => parameters.remove("barId");
  int get fooId => parameters["fooId"];
  set fooId(int value) {
    parameters["fooId"] = value;
  }
  int removeFooId() => parameters.remove("fooId");
  bool get param1 => parameters["param1"];
  set param1(bool value) {
    parameters["param1"] = value;
  }
  bool removeParam1() => parameters.remove("param1");
  bool get param2 => parameters["param2"];
  set param2(bool value) {
    parameters["param2"] = value;
  }
  bool removeParam2() => parameters.remove("param2");
  ComparableList<String> get param3 => parameters["param3"];
  set param3(ComparableList<String> value) {
    parameters["param3"] = value;
  }
  ComparableList<String> removeParam3() => parameters.remove("param3");
  Stream send() =>
      this.root.send(this);
  FoosGetRequest clone() => streamy.internalCloneFrom(new FoosGetRequest(root), this);
  streamy.Deserializer get responseDeserializer => streamy.identityFn;
}

class FoosResource {
  final MethodParamsTest _root;
  static final List<String> KNOWN_METHODS = [
    "get",
  ];
  FoosResource(this._root);
  FoosGetRequest get() {
    return new FoosGetRequest(_root);
  }
}

/// Entry point to all API services for the application.
class MethodParamsTest extends streamy.Root {
  FoosResource _foos;
  FoosResource get foos => _foos;
  final streamy.RequestHandler requestHandler;
  final String servicePath;
  MethodParamsTest(this.requestHandler, {this.servicePath: "paramsTest/v1/"}) {
    this._foos = new FoosResource(this);
  }
  Stream send(streamy.Request request) => requestHandler.handle(request);
}
