library MethodParamsTest.resources;

import 'package:streamy/streamy.dart' as streamy;
import 'package:fixnum/fixnum.dart' as fixnum;
import 'method_params_client_requests.dart' as requests;
import 'method_params_client_objects.dart' as objects;
import 'package:streamy/base.dart' as base;

class FoosResource {

  final streamy.Root _root;

  static final List<String> KNOWN_METHODS = const [
    r'get',
  ];

  String get apiType => r'FoosResource';

  FoosResource(streamy.Root this._root);

  requests.FoosGetRequest get(String barId, int fooId) => new requests.FoosGetRequest(_root)
    ..parameters[r'barId'] = barId
    ..parameters[r'fooId'] = fooId;
}
