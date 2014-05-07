library SchemaObjectTest.resources;

import 'package:streamy/streamy.dart' as streamy;
import 'package:fixnum/fixnum.dart' as fixnum;
import 'schema_object_client_requests.dart' as requests;
import 'schema_object_client_objects.dart' as objects;
import 'package:streamy/base.dart' as base;

class -some-resource-Resource {

  final streamy.Root _root;

  static final List<String> KNOWN_METHODS = const [
    r'-some-method-',
  ];

  String get apiType => r'-some-resource-Resource';

  -some-resource-Resource(streamy.Root this._root);

  requests.-some-resource--some-method-Request -some-method-() => new requests.-some-resource--some-method-Request(_root);
}
