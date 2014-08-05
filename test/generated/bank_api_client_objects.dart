/**
 * WARNING: GENERATED CODE. DO NOT EDIT BY HAND.
 * 
 */
library bank.objects;
import 'package:fixnum/fixnum.dart' as fixnum;
import 'package:streamy/streamy.dart' as streamy;
import 'package:observe/observe.dart' as obs;

/// An EntityGlobalFn for Branch entities.
typedef dynamic BranchGlobalFn(Branch entity);

class Branch extends streamy.EntityWrapper {
  static final Map<String, streamy.GlobalRegistration> _globals = <String, streamy.GlobalRegistration>{};
  static final Set<String> KNOWN_PROPERTIES = new Set<String>.from([
    r'id',
    r'name',
    r'location',
  ]);
  static final API_TYPE = r'Branch';
  String get apiType => API_TYPE;

  /// Add a global computed synthetic property to this entity type, optionally memoized.
  static void addGlobal(String name, BranchGlobalFn computeFn,
      {bool memoize: false, List dependencies: null}) {
    _globals[name] = new streamy.GlobalRegistration(computeFn, dependencies, memoize);
  }
  Branch() : super.wrap(new streamy.RawEntity(), (cloned) => new Branch._wrap(cloned), globals: _globals);
  Branch.fromMap(Map map) : super.wrap(new streamy.RawEntity.fromMap(map), (cloned) => new Branch._wrap(cloned), globals: _globals);
  Branch.wrapMap(obs.ObservableMap map) : super.wrap(new streamy.RawEntity.wrapMap(map), (cloned) => new Branch._wrap(cloned), globals: _globals);
  Branch._wrap(streamy.Entity entity) : super.wrap(entity, (cloned) => new Branch._wrap(cloned), globals: _globals);
  Branch.wrap(streamy.Entity entity, streamy.EntityWrapperCloneFn cloneWrapper) :
      super.wrap(entity, (cloned) => cloneWrapper(cloned), globals: _globals);

  /// Primary key.
  fixnum.Int64 get id => this[r'id'];
  set id(fixnum.Int64 value) {
    this[r'id'] = value;
  }
  fixnum.Int64 removeId() => remove(r'id');

  /// Branch name.
  String get name => this[r'name'];
  set name(String value) {
    this[r'name'] = value;
  }
  String removeName() => remove(r'name');
  Address get location => this[r'location'];
  set location(Address value) {
    this[r'location'] = value;
  }
  Address removeLocation() => remove(r'location');
  factory Branch.fromJsonString(String strJson, streamy.Trace trace,
      {streamy.TypeRegistry typeRegistry: streamy.EMPTY_REGISTRY}) =>
          new Branch.fromJson(streamy.jsonParse(strJson, trace), typeRegistry: typeRegistry);
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
    if (json.containsKey(r'id')) {
      json[r'id'] = streamy.atoi64(json[r'id']);
    }
    if (json.containsKey(r'location')) {
      json[r'location'] = ((v) => new Address.fromJson(v))(json[r'location']);
    }
    streamy.deserializeUnknown(json, KNOWN_PROPERTIES, typeRegistry);
    return new Branch.wrapMap(json);
  }
  Map toJson() {
    Map json = super.toJson();
    streamy.serialize(json, r'id', streamy.str);
    return json;
  }
  Branch clone() => super.clone();
  Branch patch() => super.patch();
  Type get streamyType => Branch;
}

/// An EntityGlobalFn for Address entities.
typedef dynamic AddressGlobalFn(Address entity);

class Address extends streamy.EntityWrapper {
  static final Map<String, streamy.GlobalRegistration> _globals = <String, streamy.GlobalRegistration>{};
  static final Set<String> KNOWN_PROPERTIES = new Set<String>.from([
  ]);
  static final API_TYPE = r'Address';
  String get apiType => API_TYPE;

  /// Add a global computed synthetic property to this entity type, optionally memoized.
  static void addGlobal(String name, AddressGlobalFn computeFn,
      {bool memoize: false, List dependencies: null}) {
    _globals[name] = new streamy.GlobalRegistration(computeFn, dependencies, memoize);
  }
  Address() : super.wrap(new streamy.RawEntity(), (cloned) => new Address._wrap(cloned), globals: _globals);
  Address.fromMap(Map map) : super.wrap(new streamy.RawEntity.fromMap(map), (cloned) => new Address._wrap(cloned), globals: _globals);
  Address.wrapMap(obs.ObservableMap map) : super.wrap(new streamy.RawEntity.wrapMap(map), (cloned) => new Address._wrap(cloned), globals: _globals);
  Address._wrap(streamy.Entity entity) : super.wrap(entity, (cloned) => new Address._wrap(cloned), globals: _globals);
  Address.wrap(streamy.Entity entity, streamy.EntityWrapperCloneFn cloneWrapper) :
      super.wrap(entity, (cloned) => cloneWrapper(cloned), globals: _globals);
  factory Address.fromJsonString(String strJson, streamy.Trace trace,
      {streamy.TypeRegistry typeRegistry: streamy.EMPTY_REGISTRY}) =>
          new Address.fromJson(streamy.jsonParse(strJson, trace), typeRegistry: typeRegistry);
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
    streamy.deserializeUnknown(json, KNOWN_PROPERTIES, typeRegistry);
    return new Address.wrapMap(json);
  }
  Address clone() => super.clone();
  Address patch() => super.patch();
  Type get streamyType => Address;
}

/// An EntityGlobalFn for Account entities.
typedef dynamic AccountGlobalFn(Account entity);

class Account extends streamy.EntityWrapper {
  static final Map<String, streamy.GlobalRegistration> _globals = <String, streamy.GlobalRegistration>{};
  static final Set<String> KNOWN_PROPERTIES = new Set<String>.from([
    r'account_number',
    r'branch_id',
    r'account_type',
    r'currency_type',
    r'balance',
  ]);
  static final API_TYPE = r'Account';
  String get apiType => API_TYPE;

  /// Add a global computed synthetic property to this entity type, optionally memoized.
  static void addGlobal(String name, AccountGlobalFn computeFn,
      {bool memoize: false, List dependencies: null}) {
    _globals[name] = new streamy.GlobalRegistration(computeFn, dependencies, memoize);
  }
  Account() : super.wrap(new streamy.RawEntity(), (cloned) => new Account._wrap(cloned), globals: _globals);
  Account.fromMap(Map map) : super.wrap(new streamy.RawEntity.fromMap(map), (cloned) => new Account._wrap(cloned), globals: _globals);
  Account.wrapMap(obs.ObservableMap map) : super.wrap(new streamy.RawEntity.wrapMap(map), (cloned) => new Account._wrap(cloned), globals: _globals);
  Account._wrap(streamy.Entity entity) : super.wrap(entity, (cloned) => new Account._wrap(cloned), globals: _globals);
  Account.wrap(streamy.Entity entity, streamy.EntityWrapperCloneFn cloneWrapper) :
      super.wrap(entity, (cloned) => cloneWrapper(cloned), globals: _globals);

  /// Account number.
  fixnum.Int64 get account_number => this[r'account_number'];
  set account_number(fixnum.Int64 value) {
    this[r'account_number'] = value;
  }
  fixnum.Int64 removeAccount_number() => remove(r'account_number');

  /// Branch managing the account.
  fixnum.Int64 get branch_id => this[r'branch_id'];
  set branch_id(fixnum.Int64 value) {
    this[r'branch_id'] = value;
  }
  fixnum.Int64 removeBranch_id() => remove(r'branch_id');

  /// Account type: CHECKING or SAVINGS
  String get account_type => this[r'account_type'];
  set account_type(String value) {
    this[r'account_type'] = value;
  }
  String removeAccount_type() => remove(r'account_type');

  /// Currency code: USD or CDN
  String get currency_type => this[r'currency_type'];
  set currency_type(String value) {
    this[r'currency_type'] = value;
  }
  String removeCurrency_type() => remove(r'currency_type');

  /// Balance on the account.
  fixnum.Int64 get balance => this[r'balance'];
  set balance(fixnum.Int64 value) {
    this[r'balance'] = value;
  }
  fixnum.Int64 removeBalance() => remove(r'balance');
  factory Account.fromJsonString(String strJson, streamy.Trace trace,
      {streamy.TypeRegistry typeRegistry: streamy.EMPTY_REGISTRY}) =>
          new Account.fromJson(streamy.jsonParse(strJson, trace), typeRegistry: typeRegistry);
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
    if (json.containsKey(r'account_number')) {
      json[r'account_number'] = streamy.atoi64(json[r'account_number']);
    }
    if (json.containsKey(r'balance')) {
      json[r'balance'] = streamy.atoi64(json[r'balance']);
    }
    streamy.deserializeUnknown(json, KNOWN_PROPERTIES, typeRegistry);
    return new Account.wrapMap(json);
  }
  Map toJson() {
    Map json = super.toJson();
    streamy.serialize(json, r'account_number', streamy.str);
    streamy.serialize(json, r'balance', streamy.str);
    return json;
  }
  Account clone() => super.clone();
  Account patch() => super.patch();
  Type get streamyType => Account;
}

/// An EntityGlobalFn for Customer entities.
typedef dynamic CustomerGlobalFn(Customer entity);

class Customer extends streamy.EntityWrapper {
  static final Map<String, streamy.GlobalRegistration> _globals = <String, streamy.GlobalRegistration>{};
  static final Set<String> KNOWN_PROPERTIES = new Set<String>.from([
    r'accounts',
    r'name',
  ]);
  static final API_TYPE = r'Customer';
  String get apiType => API_TYPE;

  /// Add a global computed synthetic property to this entity type, optionally memoized.
  static void addGlobal(String name, CustomerGlobalFn computeFn,
      {bool memoize: false, List dependencies: null}) {
    _globals[name] = new streamy.GlobalRegistration(computeFn, dependencies, memoize);
  }
  Customer() : super.wrap(new streamy.RawEntity(), (cloned) => new Customer._wrap(cloned), globals: _globals);
  Customer.fromMap(Map map) : super.wrap(new streamy.RawEntity.fromMap(map), (cloned) => new Customer._wrap(cloned), globals: _globals);
  Customer.wrapMap(obs.ObservableMap map) : super.wrap(new streamy.RawEntity.wrapMap(map), (cloned) => new Customer._wrap(cloned), globals: _globals);
  Customer._wrap(streamy.Entity entity) : super.wrap(entity, (cloned) => new Customer._wrap(cloned), globals: _globals);
  Customer.wrap(streamy.Entity entity, streamy.EntityWrapperCloneFn cloneWrapper) :
      super.wrap(entity, (cloned) => cloneWrapper(cloned), globals: _globals);

  /// Customer's account numbers.
  List<fixnum.Int64> get accounts => this[r'accounts'];
  set accounts(List<fixnum.Int64> value) {
    if (value != null && value is! obs.ObservableList) {
      value = new obs.ObservableList.from(value);
    }
    this[r'accounts'] = value;
  }
  List<fixnum.Int64> removeAccounts() => remove(r'accounts');

  /// Customer's full name.
  String get name => this[r'name'];
  set name(String value) {
    this[r'name'] = value;
  }
  String removeName() => remove(r'name');
  factory Customer.fromJsonString(String strJson, streamy.Trace trace,
      {streamy.TypeRegistry typeRegistry: streamy.EMPTY_REGISTRY}) =>
          new Customer.fromJson(streamy.jsonParse(strJson, trace), typeRegistry: typeRegistry);
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
    if (json.containsKey(r'accounts')) {
      json[r'accounts'] = streamy.mapInline(streamy.atoi64)(json[r'accounts']);
    }
    streamy.deserializeUnknown(json, KNOWN_PROPERTIES, typeRegistry);
    return new Customer.wrapMap(json);
  }
  Map toJson() {
    Map json = super.toJson();
    streamy.serialize(json, r'accounts', streamy.mapCopy(streamy.str));
    return json;
  }
  Customer clone() => super.clone();
  Customer patch() => super.patch();
  Type get streamyType => Customer;
}
