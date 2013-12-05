/**
 * WARNING: GENERATED CODE. DO NOT EDIT BY HAND.
 * 
 */
library addendumapi.requests;
import 'dart:async';
import 'package:fixnum/fixnum.dart' as fixnum;
import 'package:streamy/streamy.dart' as streamy;
import 'addendum_client_objects.dart' as obj;

/// Gets a foo
class FoosGetRequest extends streamy.Request {
  static final List<String> KNOWN_PARAMETERS = [
    r'fooId',
  ];
  String get apiType => r'FoosGetRequest';
  String get httpMethod => 'GET';
  String get pathFormat => 'foos/{fooId}';
  bool get hasPayload => false;
  FoosGetRequest(streamy.Root root) : super(root) {
  }
  List<String> get pathParameters => const [r'fooId',];
  List<String> get queryParameters => const [];

  /// Primary key of foo
  int get fooId => parameters[r'fooId'];
  set fooId(int value) {
    parameters[r'fooId'] = value;
  }
  int removeFooId() => parameters.remove(r'fooId');
  Stream<streamy.Response<obj.Foo>> _sendDirect() => this.root.send(this);
  Stream<streamy.Response<obj.Foo>> sendRaw({
      bool dedup: true,
      int ttl: 800,
      String foo: 'Bar' }) { 
    this.local[r'dedup'] = dedup;
    this.local[r'ttl'] = ttl;
    this.local[r'foo'] = foo;
    return _sendDirect();
  }
  Stream<obj.Foo> send({
      bool dedup: true,
      int ttl: 800,
      String foo: 'Bar' }) { 
    this.local[r'dedup'] = dedup;
    this.local[r'ttl'] = ttl;
    this.local[r'foo'] = foo;
    return _sendDirect().map((response) => response.entity);
  }
  StreamSubscription<obj.Foo> listen(void onData(obj.Foo event), {
      bool dedup: true,
      int ttl: 800,
      String foo: 'Bar' }) { 
    this.local[r'dedup'] = dedup;
    this.local[r'ttl'] = ttl;
    this.local[r'foo'] = foo;
    return _sendDirect().map((response) => response.entity).listen(onData);
  }
  FoosGetRequest clone() => streamy.internalCloneFrom(new FoosGetRequest(root), this);
  streamy.Deserializer get responseDeserializer => (String str, streamy.Trace trace) =>
      new obj.Foo.fromJsonString(str, trace, typeRegistry: root.typeRegistry);
}
