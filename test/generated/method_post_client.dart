library MethodPostTest.null;

import 'package:streamy/streamy.dart' as streamy;
import 'package:fixnum/fixnum.dart' as fixnum;
import 'package:streamy/base.dart' as base;
import 'dart:async';

class MethodPostTestResourceMixin {

  FoosResource _foos;

  FoosResource get foos {
    if (_foos == null) {
      _foos = new FoosResource(this);
    }
    return _foos;
  }
}

class MethodPostTest extends streamy.HttpRoot with MethodPostTestResourceMixin {

  final streamy.RequestHandler requestHandler;

  final streamy.TransactionStrategy txStrategy;

  final streamy.Tracer tracer;

  static final String API_TYPE = r'MethodPostTest';

  String get apiType => r'MethodPostTest';

  MethodPostTest(streamy.RequestHandler this.requestHandler, {streamy.TransactionStrategy this.txStrategy, streamy.Tracer this.tracer: const streamy.NoopTracer(), String servicePath: r'postTest/v1/'}) : super(r'postTest/v1/');

  Stream send(streamy.Request request) => requestHandler.handle(request, tracer.trace(request));
}

class MethodPostTestTransaction extends streamy.HttpTransactionRoot with MethodPostTestResourceMixin {
}

class FoosResource {

  final streamy.Root _root;

  static final String API_TYPE = r'FoosResource';

  String get apiType => r'FoosResource';

  FoosResource(streamy.Root this._root);

  FoosUpdateRequest update(Foo payload) => new FoosUpdateRequest(_root, payload);
}

class FoosUpdateRequest extends streamy.HttpRequest {

  int get id => parameters[r'id'];
  void set id(int value) {
    parameters[r'id'] = value;
  }

  static final String API_TYPE = r'FoosUpdateRequest';

  String get apiType => r'FoosUpdateRequest';

  bool get hasPayload => true;

  String get httpMethod => r'POST';

  String get pathFormat => r'foos/{id}';

  List<String> get pathParameters => const [
    r'id',
  ];

  List<String> get queryParameters => const [
  ];

  FoosUpdateRequest(streamy.Root root, Foo payload) : super(root, payload);

  int removeId() => parameters.remove(r'id');

  Stream<streamy.Response> _sendDirect() => root.send(this);

  Stream send() {
    return _sendDirect()
      .map((response) => response.entity);
  }

  Stream<streamy.Response> sendRaw() {
    return _sendDirect();
  }

  StreamSubscription listen() {
    return _sendDirect()
      .map((response) => response.entity)
      .listen(onData);
  }

  FoosUpdateRequest clone() => streamy.internalCloneFrom(new FoosUpdateRequest(root, payload.clone()), this);
}

class Foo extends base.Entity {

  int get id => this[r'id'];
  void set id(int value) {
    this[r'id'] = value;
  }

  String get bar => this[r'bar'];
  void set bar(String value) {
    this[r'bar'] = value;
  }

  static final String API_TYPE = r'Foo';

  String get apiType => r'Foo';

  Foo() {
    base.setMap(this, {});
  }

  Foo.wrap(Map<String, dynamic> map) {
    base.setMap(this, map);
  }

  int removeId() => this.remove(r'id');

  String removeBar() => this.remove(r'bar');

  Foo clone() => copyInto(new Foo());
}

class Marshaller {

  Map<String, dynamic> marshalFoo(Foo entity) {
    var res = new Map()
      ..addAll(base.getMap(entity));
    return res;
  }

  Foo unmarshalFoo(Map<String, dynamic> data) { 
   return new Foo.wrap(data);
  }
}
