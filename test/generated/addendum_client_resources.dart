/**
 * WARNING: GENERATED CODE. DO NOT EDIT BY HAND.
 * 
 */
library addendumapi.resources;
import 'package:fixnum/fixnum.dart' as fixnum;
import 'package:streamy/streamy.dart' as streamy;
import 'addendum_client_requests.dart' as req;
import 'addendum_client_objects.dart' as obj;

class FoosResource {
  final streamy.Root _root;
  static final List<String> KNOWN_METHODS = [
    r'get',
  ];
  String get apiType => r'FoosResource';
  FoosResource(this._root);

  /// Gets a foo
  req.FoosGetRequest get(int fooId) {
    var request = new req.FoosGetRequest(_root);
    if (fooId != null) {
      request.fooId = fooId;
    }
    return request;
  }
}
