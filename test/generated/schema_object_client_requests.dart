/**
 * WARNING: GENERATED CODE. DO NOT EDIT BY HAND.
 * 
 */
library schemaobjecttest.requests;
import 'dart:async';
import 'package:fixnum/fixnum.dart' as fixnum;
import 'package:streamy/streamy.dart' as streamy;
import 'schema_object_client_objects.dart' as obj;

class $some_resource__some_method_Request extends streamy.Request {
  static final List<String> KNOWN_PARAMETERS = [
    r'-path param-',
    r'-query param-',
  ];
  static final API_TYPE = r'$some_resource__some_method_Request';
  String get apiType => API_TYPE;
  String get httpMethod => 'GET';
  String get pathFormat => 'foos/{fooId}';
  bool get hasPayload => false;
  $some_resource__some_method_Request(streamy.Root root) : super(root) {
  }
  List<String> get pathParameters => const [r'-path param-',r'-query param-',];
  List<String> get queryParameters => const [];
  int get $path_param_ => parameters[r'-path param-'];
  set $path_param_(int value) {
    parameters[r'-path param-'] = value;
  }
  int remove$path_param_() => parameters.remove(r'-path param-');
  int get $query_param_ => parameters[r'-query param-'];
  set $query_param_(int value) {
    parameters[r'-query param-'] = value;
  }
  int remove$query_param_() => parameters.remove(r'-query param-');
  Stream<streamy.Response<obj.$some_entity_>> _sendDirect() => this.root.send(this);
  Stream<streamy.Response<obj.$some_entity_>> sendRaw() =>
      _sendDirect();
  Stream<obj.$some_entity_> send() =>
      _sendDirect().map((response) => response.entity);
  StreamSubscription<obj.$some_entity_> listen(void onData(obj.$some_entity_ event)) =>
      _sendDirect().map((response) => response.entity).listen(onData);
  $some_resource__some_method_Request clone() => streamy.internalCloneFrom(new $some_resource__some_method_Request(root), this);
  streamy.Deserializer get responseDeserializer => (String str, streamy.Trace trace) =>
      new obj.$some_entity_.fromJsonString(str, trace, typeRegistry: root.typeRegistry);
}
