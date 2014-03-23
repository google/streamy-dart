/**
 * WARNING: GENERATED CODE. DO NOT EDIT BY HAND.
 * 
 */
library bank.resources;
import 'package:fixnum/fixnum.dart' as fixnum;
import 'package:streamy/streamy.dart' as streamy;
import 'bank_api_client_requests.dart' as req;
import 'bank_api_client_objects.dart' as obj;

class BranchesResource {
  final streamy.Root _root;
  static final List<String> KNOWN_METHODS = [
    r'get',
    r'insert',
  ];
  static final API_TYPE = r'BranchesResource';
  String get apiType => API_TYPE;
  BranchesResource(this._root);

  /// Retrieves branch information
  req.BranchesGetRequest get(fixnum.Int64 branchId) {
    var request = new req.BranchesGetRequest(_root);
    if (branchId != null) {
      request.branchId = branchId;
    }
    return request;
  }

  /// Inserts a branch
  req.BranchesInsertRequest insert(obj.Branch payload) {
    var request = new req.BranchesInsertRequest(_root, payload);
    return request;
  }
}
