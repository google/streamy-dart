/**
 * WARNING: GENERATED CODE. DO NOT EDIT BY HAND.
 * 
 */
library multiplexertest.resources;
import 'package:fixnum/fixnum.dart' as fixnum;
import 'package:streamy/streamy.dart' as streamy;
import 'multiplexer_client_requests.dart' as req;
import 'multiplexer_client_objects.dart' as obj;

class FoosResource {
  final streamy.Root _root;
  static final List<String> KNOWN_METHODS = [
    r'get',
    r'update',
    r'delete',
    r'cancel',
  ];
  String get apiType => r'FoosResource';
  FoosResource(this._root);

  /// Gets a foo
  req.FoosGetRequest get(int id) {
    var request = new req.FoosGetRequest(_root);
    if (id != null) {
      request.id = id;
    }
    return request;
  }

  /// Updates a foo
  req.FoosUpdateRequest update(obj.Foo payload) {
    var request = new req.FoosUpdateRequest(_root, payload);
    return request;
  }

  /// Deletes a foo
  req.FoosDeleteRequest delete(int id) {
    var request = new req.FoosDeleteRequest(_root);
    if (id != null) {
      request.id = id;
    }
    return request;
  }

  /// A method to test request cancellation
  req.FoosCancelRequest cancel(int id) {
    var request = new req.FoosCancelRequest(_root);
    if (id != null) {
      request.id = id;
    }
    return request;
  }
}
