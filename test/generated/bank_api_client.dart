/**
 * WARNING: This code was generated from templates in
 * folder templates. Do not edit by hand.
 */
library bank_api;
import 'dart:async';
import 'package:fixnum/fixnum.dart' as fixnum;
import 'package:streamy/streamy.dart' as streamy;
import 'package:quiver/collection.dart' as collect;
import 'package:observe/observe.dart' as obs;

/// An EntityGlobalFn for Address entities.
typedef dynamic AddressGlobalFn(Address entity);

class Address extends streamy.EntityWrapper {
  static final Map<String, streamy.GlobalRegistration> _globals = <String, streamy.GlobalRegistration>{};
  static final Set<String> KNOWN_PROPERTIES = new Set<String>.from([
  ]);
  String get apiType => 'Address';

  /// Add a global computed synthetic property to this entity type, optionally memoized.
  static void addGlobal(String name, AddressGlobalFn computeFn,
      {bool memoize: false, List dependencies: null}) {
    if (memoize) {
      if (dependencies != null) {
        throw new ArgumentError('Memoized function should not have dependencies.');
      }
      _globals[name] = new streamy.GlobalRegistration(streamy.memoizeGlobalFn(computeFn));
    } else {
      _globals[name] = new streamy.GlobalRegistration(computeFn, dependencies);
    }
  }
  Address() : super.wrap(new streamy.RawEntity(), (cloned) => new Address._wrap(cloned), globals: _globals);
  Address.fromMap(Map map) : super.wrap(new streamy.RawEntity.fromMap(map), (cloned) => new Address._wrap(cloned), globals: _globals);
  Address.wrapMap(obs.ObservableMap map) : super.wrap(new streamy.RawEntity.wrapMap(map), (cloned) => new Address._wrap(cloned), globals: _globals);
  Address._wrap(streamy.Entity entity) : super.wrap(entity, (cloned) => new Address._wrap(cloned), globals: _globals);
  Address.wrap(streamy.Entity entity, streamy.EntityWrapperCloneFn cloneWrapper) :
      super.wrap(entity, (cloned) => cloneWrapper(cloned), globals: _globals);
  factory Address.fromJsonString(String strJson, streamy.Trace trace,
      {streamy.TypeRegistry typeRegistry: streamy.EMPTY_REGISTRY}) =>
          new Address.fromJson(streamy.jsonParse(strJson), typeRegistry: typeRegistry);
  static Address entityFactory(Map json, streamy.TypeRegistry reg) =>
      new Address.fromJson(json, typeRegistry: reg);
  factory Address.fromJson(Map json,
      {streamy.TypeRegistry typeRegistry: streamy.EMPTY_REGISTRY, bool copy: false}) {
    if (json == null) {
      return null;
    }
    if (copy) {
      json = new obs.ObservableMap.from(json);
    }
    var list;
    var len;
    var result = new Address.wrapMap(json);
    var fields = result.fieldNames.toList();
;
    for (var i = 0; i < fields.length; i++) {
      result[fields[i]] = streamy.deserialize(result[fields[i]], typeRegistry);
    }
    return result;
  }
  Map toJson() {
    Map map = super.toJson();
;
    return map;
  }
  Address clone() => new Address._wrap(super.clone());
  Type get streamyType => Address;
}

/// An EntityGlobalFn for Branch entities.
typedef dynamic BranchGlobalFn(Branch entity);

class Branch extends streamy.EntityWrapper {
  static final Map<String, streamy.GlobalRegistration> _globals = <String, streamy.GlobalRegistration>{};
  static final Set<String> KNOWN_PROPERTIES = new Set<String>.from([
    'id',
    'name',
    'location',
  ]);
  String get apiType => 'Branch';

  /// Add a global computed synthetic property to this entity type, optionally memoized.
  static void addGlobal(String name, BranchGlobalFn computeFn,
      {bool memoize: false, List dependencies: null}) {
    if (memoize) {
      if (dependencies != null) {
        throw new ArgumentError('Memoized function should not have dependencies.');
      }
      _globals[name] = new streamy.GlobalRegistration(streamy.memoizeGlobalFn(computeFn));
    } else {
      _globals[name] = new streamy.GlobalRegistration(computeFn, dependencies);
    }
  }
  Branch() : super.wrap(new streamy.RawEntity(), (cloned) => new Branch._wrap(cloned), globals: _globals);
  Branch.fromMap(Map map) : super.wrap(new streamy.RawEntity.fromMap(map), (cloned) => new Branch._wrap(cloned), globals: _globals);
  Branch.wrapMap(obs.ObservableMap map) : super.wrap(new streamy.RawEntity.wrapMap(map), (cloned) => new Branch._wrap(cloned), globals: _globals);
  Branch._wrap(streamy.Entity entity) : super.wrap(entity, (cloned) => new Branch._wrap(cloned), globals: _globals);
  Branch.wrap(streamy.Entity entity, streamy.EntityWrapperCloneFn cloneWrapper) :
      super.wrap(entity, (cloned) => cloneWrapper(cloned), globals: _globals);

  /// Primary key.
  fixnum.Int64 get id => this['id'];
  set id(fixnum.Int64 value) {
    this['id'] = value;
  }
  fixnum.Int64 removeId() => this.remove('id');

  /// Branch name.
  String get name => this['name'];
  set name(String value) {
    this['name'] = value;
  }
  String removeName() => this.remove('name');
  Address get location => this['location'];
  set location(Address value) {
    this['location'] = value;
  }
  Address removeLocation() => this.remove('location');
  factory Branch.fromJsonString(String strJson, streamy.Trace trace,
      {streamy.TypeRegistry typeRegistry: streamy.EMPTY_REGISTRY}) =>
          new Branch.fromJson(streamy.jsonParse(strJson), typeRegistry: typeRegistry);
  static Branch entityFactory(Map json, streamy.TypeRegistry reg) =>
      new Branch.fromJson(json, typeRegistry: reg);
  factory Branch.fromJson(Map json,
      {streamy.TypeRegistry typeRegistry: streamy.EMPTY_REGISTRY, bool copy: false}) {
    if (json == null) {
      return null;
    }
    if (copy) {
      json = new obs.ObservableMap.from(json);
    }
    var list;
    var len;
    var result = new Branch.wrapMap(json);
    var fields = result.fieldNames.toList();
    result.id = (result['id'] != null) ? fixnum.Int64.parseInt(result['id']) : null;
    fields.remove('id');
    fields.remove('name');
    result.location = new Address.fromJson(result['location']);
    fields.remove('location');
;
    for (var i = 0; i < fields.length; i++) {
      result[fields[i]] = streamy.deserialize(result[fields[i]], typeRegistry);
    }
    return result;
  }
  Map toJson() {
    Map map = super.toJson();
    if (map.containsKey('id')) {
      map['id'] = map['id'].toString();
    }
;
    return map;
  }
  Branch clone() => new Branch._wrap(super.clone());
  Type get streamyType => Branch;
}

/// An EntityGlobalFn for Account entities.
typedef dynamic AccountGlobalFn(Account entity);

class Account extends streamy.EntityWrapper {
  static final Map<String, streamy.GlobalRegistration> _globals = <String, streamy.GlobalRegistration>{};
  static final Set<String> KNOWN_PROPERTIES = new Set<String>.from([
    'account_number',
    'branch_id',
    'account_type',
    'currency_type',
    'balance',
  ]);
  String get apiType => 'Account';

  /// Add a global computed synthetic property to this entity type, optionally memoized.
  static void addGlobal(String name, AccountGlobalFn computeFn,
      {bool memoize: false, List dependencies: null}) {
    if (memoize) {
      if (dependencies != null) {
        throw new ArgumentError('Memoized function should not have dependencies.');
      }
      _globals[name] = new streamy.GlobalRegistration(streamy.memoizeGlobalFn(computeFn));
    } else {
      _globals[name] = new streamy.GlobalRegistration(computeFn, dependencies);
    }
  }
  Account() : super.wrap(new streamy.RawEntity(), (cloned) => new Account._wrap(cloned), globals: _globals);
  Account.fromMap(Map map) : super.wrap(new streamy.RawEntity.fromMap(map), (cloned) => new Account._wrap(cloned), globals: _globals);
  Account.wrapMap(obs.ObservableMap map) : super.wrap(new streamy.RawEntity.wrapMap(map), (cloned) => new Account._wrap(cloned), globals: _globals);
  Account._wrap(streamy.Entity entity) : super.wrap(entity, (cloned) => new Account._wrap(cloned), globals: _globals);
  Account.wrap(streamy.Entity entity, streamy.EntityWrapperCloneFn cloneWrapper) :
      super.wrap(entity, (cloned) => cloneWrapper(cloned), globals: _globals);

  /// Account number.
  fixnum.Int64 get account_number => this['account_number'];
  set account_number(fixnum.Int64 value) {
    this['account_number'] = value;
  }
  fixnum.Int64 removeAccount_number() => this.remove('account_number');

  /// Branch managing the account.
  fixnum.Int64 get branch_id => this['branch_id'];
  set branch_id(fixnum.Int64 value) {
    this['branch_id'] = value;
  }
  fixnum.Int64 removeBranch_id() => this.remove('branch_id');

  /// Account type: CHECKING or SAVINGS
  String get account_type => this['account_type'];
  set account_type(String value) {
    this['account_type'] = value;
  }
  String removeAccount_type() => this.remove('account_type');

  /// Currency code: USD or CDN
  String get currency_type => this['currency_type'];
  set currency_type(String value) {
    this['currency_type'] = value;
  }
  String removeCurrency_type() => this.remove('currency_type');

  /// Balance on the account.
  fixnum.Int64 get balance => this['balance'];
  set balance(fixnum.Int64 value) {
    this['balance'] = value;
  }
  fixnum.Int64 removeBalance() => this.remove('balance');
  factory Account.fromJsonString(String strJson, streamy.Trace trace,
      {streamy.TypeRegistry typeRegistry: streamy.EMPTY_REGISTRY}) =>
          new Account.fromJson(streamy.jsonParse(strJson), typeRegistry: typeRegistry);
  static Account entityFactory(Map json, streamy.TypeRegistry reg) =>
      new Account.fromJson(json, typeRegistry: reg);
  factory Account.fromJson(Map json,
      {streamy.TypeRegistry typeRegistry: streamy.EMPTY_REGISTRY, bool copy: false}) {
    if (json == null) {
      return null;
    }
    if (copy) {
      json = new obs.ObservableMap.from(json);
    }
    var list;
    var len;
    var result = new Account.wrapMap(json);
    var fields = result.fieldNames.toList();
    result.account_number = (result['account_number'] != null) ? fixnum.Int64.parseInt(result['account_number']) : null;
    fields.remove('account_number');
    fields.remove('branch_id');
    fields.remove('account_type');
    fields.remove('currency_type');
    result.balance = (result['balance'] != null) ? fixnum.Int64.parseInt(result['balance']) : null;
    fields.remove('balance');
;
    for (var i = 0; i < fields.length; i++) {
      result[fields[i]] = streamy.deserialize(result[fields[i]], typeRegistry);
    }
    return result;
  }
  Map toJson() {
    Map map = super.toJson();
    if (map.containsKey('account_number')) {
      map['account_number'] = map['account_number'].toString();
    }
    if (map.containsKey('balance')) {
      map['balance'] = map['balance'].toString();
    }
;
    return map;
  }
  Account clone() => new Account._wrap(super.clone());
  Type get streamyType => Account;
}

/// An EntityGlobalFn for Customer entities.
typedef dynamic CustomerGlobalFn(Customer entity);

class Customer extends streamy.EntityWrapper {
  static final Map<String, streamy.GlobalRegistration> _globals = <String, streamy.GlobalRegistration>{};
  static final Set<String> KNOWN_PROPERTIES = new Set<String>.from([
    'accounts',
    'name',
  ]);
  String get apiType => 'Customer';

  /// Add a global computed synthetic property to this entity type, optionally memoized.
  static void addGlobal(String name, CustomerGlobalFn computeFn,
      {bool memoize: false, List dependencies: null}) {
    if (memoize) {
      if (dependencies != null) {
        throw new ArgumentError('Memoized function should not have dependencies.');
      }
      _globals[name] = new streamy.GlobalRegistration(streamy.memoizeGlobalFn(computeFn));
    } else {
      _globals[name] = new streamy.GlobalRegistration(computeFn, dependencies);
    }
  }
  Customer() : super.wrap(new streamy.RawEntity(), (cloned) => new Customer._wrap(cloned), globals: _globals);
  Customer.fromMap(Map map) : super.wrap(new streamy.RawEntity.fromMap(map), (cloned) => new Customer._wrap(cloned), globals: _globals);
  Customer.wrapMap(obs.ObservableMap map) : super.wrap(new streamy.RawEntity.wrapMap(map), (cloned) => new Customer._wrap(cloned), globals: _globals);
  Customer._wrap(streamy.Entity entity) : super.wrap(entity, (cloned) => new Customer._wrap(cloned), globals: _globals);
  Customer.wrap(streamy.Entity entity, streamy.EntityWrapperCloneFn cloneWrapper) :
      super.wrap(entity, (cloned) => cloneWrapper(cloned), globals: _globals);

  /// Customer's account numbers.
  List<fixnum.Int64> get accounts => this['accounts'];
  set accounts(List<fixnum.Int64> value) {
    if (value is! obs.ObservableList) {
      value = new obs.ObservableList.from(value);
    }
    this['accounts'] = value;
  }
  List<fixnum.Int64> removeAccounts() => this.remove('accounts');

  /// Customer's full name.
  String get name => this['name'];
  set name(String value) {
    this['name'] = value;
  }
  String removeName() => this.remove('name');
  factory Customer.fromJsonString(String strJson, streamy.Trace trace,
      {streamy.TypeRegistry typeRegistry: streamy.EMPTY_REGISTRY}) =>
          new Customer.fromJson(streamy.jsonParse(strJson), typeRegistry: typeRegistry);
  static Customer entityFactory(Map json, streamy.TypeRegistry reg) =>
      new Customer.fromJson(json, typeRegistry: reg);
  factory Customer.fromJson(Map json,
      {streamy.TypeRegistry typeRegistry: streamy.EMPTY_REGISTRY, bool copy: false}) {
    if (json == null) {
      return null;
    }
    if (copy) {
      json = new obs.ObservableMap.from(json);
    }
    var list;
    var len;
    var result = new Customer.wrapMap(json);
    var fields = result.fieldNames.toList();
    list = result['accounts'];
    if (list != null) {
      list = result['accounts'];
      len = list.length;
      for (var i = 0; i < len; i++) {
        list[i] = fixnum.Int64.parseInt(list[i]);
      }
    }
    fields.remove('accounts');
    fields.remove('name');
;
    for (var i = 0; i < fields.length; i++) {
      result[fields[i]] = streamy.deserialize(result[fields[i]], typeRegistry);
    }
    return result;
  }
  Map toJson() {
    Map map = super.toJson();
    if (map.containsKey('accounts')) {
      map['accounts'] = streamy.nullSafeMapToList(map['accounts'], (o) => o.toString());
    }
;
    return map;
  }
  Customer clone() => new Customer._wrap(super.clone());
  Type get streamyType => Customer;
}

/// Retrieves branch information
class BranchesGetRequest extends streamy.Request {
  static final List<String> KNOWN_PARAMETERS = [
    'branchId',
  ];
  String get apiType => 'BranchesGetRequest';
  String get httpMethod => 'GET';
  String get pathFormat => 'branches/{branchId}';
  bool get hasPayload => false;
  BranchesGetRequest(streamy.Root root) : super(root) {
  }
  List<String> get pathParameters => const ['branchId',];
  List<String> get queryParameters => const [];

  /// Primary key of a branch
  fixnum.Int64 get branchId => parameters['branchId'];
  set branchId(fixnum.Int64 value) {
    parameters['branchId'] = value;
  }
  fixnum.Int64 removeBranchId() => parameters.remove('branchId');
  Stream<streamy.Response<Branch>> _sendDirect() => this.root.send(this);
  Stream<streamy.Response<Branch>> sendRaw() =>
      _sendDirect();
  Stream<Branch> send() =>
      _sendDirect().map((response) => response.entity);
  StreamSubscription<Branch> listen(void onData(Branch event)) =>
      _sendDirect().map((response) => response.entity).listen(onData);
  BranchesGetRequest clone() => streamy.internalCloneFrom(new BranchesGetRequest(root), this);
  streamy.Deserializer get responseDeserializer => (String str, streamy.Trace trace) =>
      new Branch.fromJsonString(str, trace, typeRegistry: root.typeRegistry);
}

/// Inserts a branch
class BranchesInsertRequest extends streamy.Request {
  static final List<String> KNOWN_PARAMETERS = [
  ];
  String get apiType => 'BranchesInsertRequest';
  Branch get payload => streamy.internalGetPayload(this);
  String get httpMethod => 'POST';
  String get pathFormat => 'branches';
  bool get hasPayload => true;
  BranchesInsertRequest(streamy.Root root, Branch payloadEntity) : super(root, payloadEntity) {
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

class BranchesResource {
  final streamy.Root _root;
  static final List<String> KNOWN_METHODS = [
    'get',
    'insert',
  ];
  String get apiType => 'BranchesResource';
  BranchesResource(this._root);

  /// Retrieves branch information
  BranchesGetRequest get(fixnum.Int64 branchId) {
    var request = new BranchesGetRequest(_root);
    if (branchId != null) {
      request.branchId = branchId;
    }
    return request;
  }

  /// Inserts a branch
  BranchesInsertRequest insert(Branch payload) {
    var request = new BranchesInsertRequest(_root, payload);
    return request;
  }
}

abstract class BankResourcesMixin {
  BranchesResource _branches;
  BranchesResource get branches {
    if (_branches == null) {
      _branches = new BranchesResource(this as streamy.Root);
    }
    return _branches;
  }
}

class Bank
    extends streamy.Root
    with BankResourcesMixin {
  String get apiType => 'Bank';
  final streamy.TransactionStrategy _txStrategy;
  final streamy.RequestHandler requestHandler;
  final streamy.Tracer _tracer;
  Bank(
      this.requestHandler,
      {String servicePath: 'bank/v1/',
      streamy.TypeRegistry typeRegistry: streamy.EMPTY_REGISTRY,
      streamy.TransactionStrategy txStrategy: null,
      streamy.Tracer tracer: const streamy.NoopTracer()}) :
          super(typeRegistry, servicePath),
          this._txStrategy = txStrategy,
          this._tracer = tracer;
  Stream send(streamy.Request request) =>
      requestHandler.handle(request, _tracer.trace(request));
  BankTransaction beginTransaction() =>
      new BankTransaction(typeRegistry, servicePath,
          _txStrategy.beginTransaction());
}

/// Provides the same API as [Bank] but runs all requests as
/// part of the same transaction.
class BankTransaction
    extends streamy.TransactionRoot
    with BankResourcesMixin {
  String get apiType => 'BankTransaction';
  BankTransaction(
      streamy.TypeRegistry typeRegistry,
      String servicePath,
      streamy.Transaction tx) : super(typeRegistry, servicePath, tx);
}
