library MethodPostTest.null.resources;

import 'package:streamy/streamy.dart' as streamy;
import 'package:fixnum/fixnum.dart' as fixnum;
import 'method_post_client_requests.dart' as requests;
import 'method_post_client_objects.dart' as objects;
import 'package:streamy/base.dart' as base;

class FoosResource {

  final streamy.Root _root;

  static final List<String> KNOWN_METHODS = const [
    r'update',
  ];

  static final String API_TYPE = r'FoosResource';

  String get apiType => r'FoosResource';

  FoosResource(streamy.Root this._root);

  requests.FoosUpdateRequest update(objects.Foo payload) => new requests.FoosUpdateRequest(_root, payload);
}
