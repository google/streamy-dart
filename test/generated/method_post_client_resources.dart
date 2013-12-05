/**
 * WARNING: GENERATED CODE. DO NOT EDIT BY HAND.
 * 
 */
library methodposttest.resources;
import 'package:fixnum/fixnum.dart' as fixnum;
import 'package:streamy/streamy.dart' as streamy;
import 'method_post_client_requests.dart' as req;
import 'method_post_client_objects.dart' as obj;

class FoosResource {
  final streamy.Root _root;
  static final List<String> KNOWN_METHODS = [
    r'update',
  ];
  String get apiType => r'FoosResource';
  FoosResource(this._root);

  /// Updates a foo
  req.FoosUpdateRequest update(obj.Foo payload) {
    var request = new req.FoosUpdateRequest(_root, payload);
    return request;
  }
}
