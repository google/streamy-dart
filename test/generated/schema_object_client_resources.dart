/**
 * WARNING: GENERATED CODE. DO NOT EDIT BY HAND.
 * 
 */
library schemaobjecttest.resources;
import 'package:fixnum/fixnum.dart' as fixnum;
import 'package:streamy/streamy.dart' as streamy;
import 'schema_object_client_requests.dart' as req;
import 'schema_object_client_objects.dart' as obj;

class $some_resource_Resource {
  final streamy.Root _root;
  static final List<String> KNOWN_METHODS = [
    r'$some_method_',
  ];
  static final API_TYPE = r'$some_resource_Resource';
  String get apiType => API_TYPE;
  $some_resource_Resource(this._root);
  req.$some_resource__some_method_Request $some_method_(int $path_param_, int $query_param_) {
    var request = new req.$some_resource__some_method_Request(_root);
    if ($path_param_ != null) {
      request.$path_param_ = $path_param_;
    }
    if ($query_param_ != null) {
      request.$query_param_ = $query_param_;
    }
    return request;
  }
}
