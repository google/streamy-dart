library MultiplexerTest.null.resources;

import 'package:streamy/streamy.dart' as streamy;
import 'package:fixnum/fixnum.dart' as fixnum;
import 'multiplexer_client_requests.dart' as requests;
import 'multiplexer_client_objects.dart' as objects;
import 'package:streamy/base.dart' as base;

class FoosResource {

  final streamy.Root _root;

  static final List<String> KNOWN_METHODS = const [
    r'get',
    r'update',
    r'delete',
    r'cancel',
  ];

  static final String API_TYPE = r'FoosResource';

  String get apiType => r'FoosResource';

  FoosResource(streamy.Root this._root);

  requests.FoosGetRequest get(int id) => new requests.FoosGetRequest(_root)
    ..parameters[r'id'] = id;

  requests.FoosUpdateRequest update(objects.Foo payload) => new requests.FoosUpdateRequest(_root, payload);

  requests.FoosDeleteRequest delete(int id) => new requests.FoosDeleteRequest(_root)
    ..parameters[r'id'] = id;

  requests.FoosCancelRequest cancel(int id) => new requests.FoosCancelRequest(_root)
    ..parameters[r'id'] = id;
}
