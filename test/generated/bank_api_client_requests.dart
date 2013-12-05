/**
 * WARNING: GENERATED CODE. DO NOT EDIT BY HAND.
 * 
 */
library bank.requests;
import 'dart:async';
import 'package:fixnum/fixnum.dart' as fixnum;
import 'package:streamy/streamy.dart' as streamy;
import 'bank_api_client_objects.dart' as obj;

/// Retrieves branch information
class BranchesGetRequest extends streamy.Request {
  static final List<String> KNOWN_PARAMETERS = [
    r'branchId',
  ];
  String get apiType => r'BranchesGetRequest';
  String get httpMethod => 'GET';
  String get pathFormat => 'branches/{branchId}';
  bool get hasPayload => false;
  BranchesGetRequest(streamy.Root root) : super(root) {
  }
  List<String> get pathParameters => const [r'branchId',];
  List<String> get queryParameters => const [];

  /// Primary key of a branch
  fixnum.Int64 get branchId => parameters[r'branchId'];
  set branchId(fixnum.Int64 value) {
    parameters[r'branchId'] = value;
  }
  fixnum.Int64 removeBranchId() => parameters.remove(r'branchId');
  Stream<streamy.Response<obj.Branch>> _sendDirect() => this.root.send(this);
  Stream<streamy.Response<obj.Branch>> sendRaw() =>
      _sendDirect();
  Stream<obj.Branch> send() =>
      _sendDirect().map((response) => response.entity);
  StreamSubscription<obj.Branch> listen(void onData(obj.Branch event)) =>
      _sendDirect().map((response) => response.entity).listen(onData);
  BranchesGetRequest clone() => streamy.internalCloneFrom(new BranchesGetRequest(root), this);
  streamy.Deserializer get responseDeserializer => (String str, streamy.Trace trace) =>
      new obj.Branch.fromJsonString(str, trace, typeRegistry: root.typeRegistry);
}

/// Inserts a branch
class BranchesInsertRequest extends streamy.Request {
  static final List<String> KNOWN_PARAMETERS = [
  ];
  String get apiType => r'BranchesInsertRequest';
  obj.Branch get payload => streamy.internalGetPayload(this);
  String get httpMethod => 'POST';
  String get pathFormat => 'branches';
  bool get hasPayload => true;
  BranchesInsertRequest(streamy.Root root, obj.Branch payloadEntity) : super(root, payloadEntity) {
  }
  List<String> get pathParameters => const [];
  List<String> get queryParameters => const [];
  Stream<streamy.Response> _sendDirect() => this.root.send(this);
  Stream<streamy.Response> sendRaw() =>
      _sendDirect();
  Stream send() =>
      _sendDirect().map((response) => response.entity);
  StreamSubscription listen(void onData(event)) =>
      _sendDirect().map((response) => response.entity).listen(onData);
  BranchesInsertRequest clone() => streamy.internalCloneFrom(new BranchesInsertRequest(root, payload.clone()), this);
  streamy.Deserializer get responseDeserializer => (String str, streamy.Trace trace) =>
      new streamy.EmptyEntity();
}
