/**
 * WARNING: GENERATED CODE. DO NOT EDIT BY HAND.
 * 
 */
library methodposttest.requests;
import 'dart:async';
import 'package:fixnum/fixnum.dart' as fixnum;
import 'package:streamy/streamy.dart' as streamy;
import 'method_post_client_objects.dart' as obj;

/// Updates a foo
class FoosUpdateRequest extends streamy.Request {
  static final List<String> KNOWN_PARAMETERS = [
    r'id',
  ];
  static final API_TYPE = r'FoosUpdateRequest';
  String get apiType => API_TYPE;
  obj.Foo get payload => streamy.internalGetPayload(this);
  final patch;
  String get httpMethod => patch ? 'PATCH' : 'POST';
  String get pathFormat => 'foos/{id}';
  bool get hasPayload => true;
  FoosUpdateRequest(streamy.Root root, obj.Foo payloadEntity, {bool this.patch: false}) : super(root, payloadEntity) {
  }
  List<String> get pathParameters => const [r'id',];
  List<String> get queryParameters => const [];

  /// Primary key of foo
  int get id => parameters[r'id'];
  set id(int value) {
    parameters[r'id'] = value;
  }
  int removeId() => parameters.remove(r'id');
  Stream<streamy.Response> _sendDirect() => this.root.send(this);
  Stream<streamy.Response> sendRaw() =>
      _sendDirect();
  Stream send() =>
      _sendDirect().map((response) => response.entity);
  StreamSubscription listen(void onData(event)) =>
      _sendDirect().map((response) => response.entity).listen(onData);
  FoosUpdateRequest clone() => streamy.internalCloneFrom(new FoosUpdateRequest(root, payload.clone()), this);
  streamy.Deserializer get responseDeserializer => (String str, streamy.Trace trace) =>
      new streamy.EmptyEntity();
}
