/**
 * WARNING: This code was generated from templates in
 * folder templates. Do not edit by hand.
 */
library multiplexer;
import "dart:async";
import "dart:json";
import "package:streamy/streamy.dart" as streamy;
import "package:streamy/collections.dart";
Map<String, streamy.TypeInfo> TYPE_REGISTRY = {
};

class Foo extends streamy.EntityWrapper {
  static final List<String> KNOWN_PROPERTIES = [
    "id",
    "bar",
  ];
  Foo() : super.wrap(new streamy.RawEntity(), (cloned) => new Foo._wrap(cloned));
  Foo._wrap(streamy.Entity entity) : super.wrap(entity, (cloned) => new Foo._wrap(cloned));
  Foo.wrap(streamy.Entity entity, streamy.EntityWrapperCloneFn cloneWrapper) :
      super.wrap(entity, (cloned) => cloneWrapper(cloned));
  int get id => this["id"];
  set id(int value) {
    this["id"] = value;
  }
  int removeId() => this.remove("id");
  String get bar => this["bar"];
  set bar(String value) {
    this["bar"] = value;
  }
  String removeBar() => this.remove("bar");
  factory Foo.fromJsonString(String strJson) => new Foo.fromJson(parse(strJson));
  factory Foo.fromJson(Map json) {
    if (json == null) {
      return null;
    }
    json = new Map.from(json);
    var result = new Foo()
      ..id = json.remove("id")
      ..bar = json.remove("bar")
;
    streamy.addUnknownProperties(result, json, TYPE_REGISTRY);
    return result;
  }
  Map toJson() {
    Map map = super.toJson();
;
    return map;
  }
  Foo clone() => new Foo._wrap(super.clone());
  Type get streamyType => Foo;
}

class FoosGetRequest extends streamy.Request {
  static final List<String> KNOWN_PARAMETERS = [
    "fooId",
  ];
  String get httpMethod => "GET";
  String get pathFormat => "foos/{fooId}";
  bool get hasPayload => false;
  FoosGetRequest(MultiplexerTest root) : super(root) {
  }
  List<String> get pathParameters => const ["fooId",];
  List<String> get queryParameters => const [];
  int get fooId => parameters["fooId"];
  set fooId(int value) {
    parameters["fooId"] = value;
  }
  int removeFooId() => parameters.remove("fooId");
  Stream<Foo> send() =>
      this.root.send(this);
  FoosGetRequest clone() => streamy.internalCloneFrom(new FoosGetRequest(root), this);
  streamy.Deserializer get responseDeserializer => (String str) => new Foo.fromJsonString(str);
}

class FoosResource {
  final MultiplexerTest _root;
  static final List<String> KNOWN_METHODS = [
    "get",
  ];
  FoosResource(this._root);
  FoosGetRequest get() {
    return new FoosGetRequest(_root);
  }
}

/// Entry point to all API services for the application.
class MultiplexerTest extends streamy.Root {
  FoosResource _foos;
  FoosResource get foos => _foos;
  final streamy.RequestHandler requestHandler;
  final String servicePath;
  MultiplexerTest(this.requestHandler, {this.servicePath: "multiplexerTest/v1/"}) {
    this._foos = new FoosResource(this);
  }
  Stream send(streamy.Request request) => requestHandler.handle(request);
}
