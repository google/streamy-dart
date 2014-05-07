library Bank.requests;

import 'package:streamy/streamy.dart' as streamy;
import 'package:fixnum/fixnum.dart' as fixnum;
import 'bank_api_client_objects.dart' as objects;
import 'bank_api_client_dispatch.dart' as dispatch;
import 'dart:async';
import 'package:streamy/base.dart' as base;

class BranchesGetRequest extends streamy.HttpRequest {

  static final List<String> KNOWN_PARAMETERS = const [
    r'branchId',
  ];

  fixnum.Int64 get branchId => parameters[r'branchId'];
  void set branchId(fixnum.Int64 value) {
    parameters[r'branchId'] = value;
  }

  String get apiType => r'BranchesGetRequest';

  bool get hasPayload => false;

  String get httpMethod => r'GET';

  String get pathFormat => r'branches/{branchId}';

  List<String> get pathParameters => const [
    r'branchId',
  ];

  List<String> get queryParameters => const [
  ];

  BranchesGetRequest(streamy.Root root) : super(root);

  fixnum.Int64 removeBranchId() => parameters.remove(r'branchId');

  Stream<streamy.Response<objects.Branch>> _sendDirect() => root.send(this);

  objects.Branch unmarshalResponse(dispatch.Marshaller marshaller, Map data) => marshaller.unmarshalBranch(data);

  Stream<objects.Branch> send() {
    return _sendDirect()
      .map((response) => response.entity);
  }

  Stream<streamy.Response<objects.Branch>> sendRaw() {
    return _sendDirect();
  }

  StreamSubscription<objects.Branch> listen() {
    return _sendDirect()
      .map((response) => response.entity)
      .listen(onData);
  }

  BranchesGetRequest clone() => streamy.internalCloneFrom(new BranchesGetRequest(root), this);
}

class BranchesInsertRequest extends streamy.HttpRequest {

  static final List<String> KNOWN_PARAMETERS = const [
  ];

  String get apiType => r'BranchesInsertRequest';

  bool get hasPayload => true;

  String get httpMethod => r'POST';

  String get pathFormat => r'branches';

  List<String> get pathParameters => const [
  ];

  List<String> get queryParameters => const [
  ];

  BranchesInsertRequest(streamy.Root root, objects.Branch payload) : super(root, payload);

  Stream<streamy.Response> _sendDirect() => root.send(this);

  Stream send() {
    return _sendDirect()
      .map((response) => response.entity);
  }

  Stream<streamy.Response> sendRaw() {
    return _sendDirect();
  }

  StreamSubscription listen() {
    return _sendDirect()
      .map((response) => response.entity)
      .listen(onData);
  }

  BranchesInsertRequest clone() => streamy.internalCloneFrom(new BranchesInsertRequest(root, payload.clone()), this);
}
