library Bank.null.resources;

import 'package:streamy/streamy.dart' as streamy;
import 'package:fixnum/fixnum.dart' as fixnum;
import 'bank_api_client_requests.dart' as requests;
import 'bank_api_client_objects.dart' as objects;
import 'package:streamy/base.dart' as base;

class BranchesResource {

  final streamy.Root _root;

  static final List<String> KNOWN_METHODS = const [
    r'get',
    r'insert',
  ];

  static final String API_TYPE = r'BranchesResource';

  String get apiType => r'BranchesResource';

  BranchesResource(streamy.Root this._root);

  requests.BranchesGetRequest get(fixnum.Int64 branchId) => new requests.BranchesGetRequest(_root)
    ..parameters[r'branchId'] = branchId;

  requests.BranchesInsertRequest insert(objects.Branch payload) => new requests.BranchesInsertRequest(_root, payload);
}
