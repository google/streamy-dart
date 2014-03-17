/**
 * WARNING: GENERATED CODE. DO NOT EDIT BY HAND.
 * 
 */
library bank.objects;
import 'package:fixnum/fixnum.dart' as fixnum;
import 'package:streamy/base.dart' as base;
import 'package:streamy/streamy.dart' as streamy;
import 'package:observe/observe.dart' as obs;

/// An EntityGlobalFn for Branch entities.
typedef dynamic BranchGlobalFn(Branch entity);

class Branch extends base.EntityBase {
  static final Set<String> KNOWN_PROPERTIES = new Set<String>.from([
    r'id',
    r'name',
    r'location',
  ]);
  String get apiType => r'Branch';

  /// Add a global computed synthetic property to this entity type, optionally memoized.
  static void addGlobal(String name, BranchGlobalFn computeFn,
      {bool memoize: false, List dependencies: null}) {
    streamy.GlobalView.register(Branch, name, new streamy.GlobalRegistration(computeFn, dependencies, memoize));
  }
  Branch() : this.wrapMap(<String, dynamic>{});
  Branch.wrapMap(Map map) {
    base.setMap(this, map);
  }

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
          new Branch.fromJson(streamy.jsonParse(strJson), typeRegistry: typeRegistry);
  static Branch entityFactory(Map json, streamy.TypeRegistry reg) =>
      new Branch.fromJson(json, typeRegistry: reg);
  factory Branch.fromJson(Map json,
      {streamy.TypeRegistry typeRegistry: streamy.EMPTY_REGISTRY, bool copy: false}) {
    if (json == null) {
      return null;
    }
    if (copy) {
      json = new Map.from(json);
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
    Map json = new Map.from(base.getMap(this));
    streamy.serialize(json, r'id', streamy.str);
    return json;
  }
  Branch clone() => copyInto(new Branch());
  Branch patch() => super.patch();
  Type get streamyType => Branch;
}

/// An EntityGlobalFn for Address entities.
typedef dynamic AddressGlobalFn(Address entity);

class Address extends base.EntityBase {
  static final Set<String> KNOWN_PROPERTIES = new Set<String>.from([
  ]);
  String get apiType => r'Address';

  /// Add a global computed synthetic property to this entity type, optionally memoized.
  static void addGlobal(String name, AddressGlobalFn computeFn,
      {bool memoize: false, List dependencies: null}) {
    streamy.GlobalView.register(Address, name, new streamy.GlobalRegistration(computeFn, dependencies, memoize));
  }
  Address() : this.wrapMap(<String, dynamic>{});
  Address.wrapMap(Map map) {
    base.setMap(this, map);
  }
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
      json = new Map.from(json);
    }
    streamy.deserializeUnknown(json, KNOWN_PROPERTIES, typeRegistry);
    return new Address.wrapMap(json);
  }
  Map toJson() {
    Map json = new Map.from(base.getMap(this));
    return json;
  }
  Address clone() => copyInto(new Address());
  Address patch() => super.patch();
  Type get streamyType => Address;
}

/// An EntityGlobalFn for Account entities.
typedef dynamic AccountGlobalFn(Account entity);

class Account extends base.EntityBase {
  static final Set<String> KNOWN_PROPERTIES = new Set<String>.from([
    r'account_number',
    r'branch_id',
    r'account_type',
    r'currency_type',
    r'balance',
  ]);
  String get apiType => r'Account';

  /// Add a global computed synthetic property to this entity type, optionally memoized.
  static void addGlobal(String name, AccountGlobalFn computeFn,
      {bool memoize: false, List dependencies: null}) {
    streamy.GlobalView.register(Account, name, new streamy.GlobalRegistration(computeFn, dependencies, memoize));
  }
  Account() : this.wrapMap(<String, dynamic>{});
  Account.wrapMap(Map map) {
    base.setMap(this, map);
  }

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
          new Account.fromJson(streamy.jsonParse(strJson), typeRegistry: typeRegistry);
  static Account entityFactory(Map json, streamy.TypeRegistry reg) =>
      new Account.fromJson(json, typeRegistry: reg);
  factory Account.fromJson(Map json,
      {streamy.TypeRegistry typeRegistry: streamy.EMPTY_REGISTRY, bool copy: false}) {
    if (json == null) {
      return null;
    }
    if (copy) {
      json = new Map.from(json);
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
    Map json = new Map.from(base.getMap(this));
    streamy.serialize(json, r'account_number', streamy.str);
    streamy.serialize(json, r'balance', streamy.str);
    return json;
  }
  Account clone() => copyInto(new Account());
  Account patch() => super.patch();
  Type get streamyType => Account;
}

/// An EntityGlobalFn for Customer entities.
typedef dynamic CustomerGlobalFn(Customer entity);

class Customer extends base.EntityBase {
  static final Set<String> KNOWN_PROPERTIES = new Set<String>.from([
    r'accounts',
    r'name',
  ]);
  String get apiType => r'Customer';

  /// Add a global computed synthetic property to this entity type, optionally memoized.
  static void addGlobal(String name, CustomerGlobalFn computeFn,
      {bool memoize: false, List dependencies: null}) {
    streamy.GlobalView.register(Customer, name, new streamy.GlobalRegistration(computeFn, dependencies, memoize));
  }
  Customer() : this.wrapMap(<String, dynamic>{});
  Customer.wrapMap(Map map) {
    base.setMap(this, map);
  }

  /// Customer's account numbers.
  List<fixnum.Int64> get accounts => this[r'accounts'];
  set accounts(List<fixnum.Int64> value) {
/*
    if (value != null && value is! obs.ObservableList) {
      value = new obs.ObservableList.from(value);
    }
*/
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
          new Customer.fromJson(streamy.jsonParse(strJson), typeRegistry: typeRegistry);
  static Customer entityFactory(Map json, streamy.TypeRegistry reg) =>
      new Customer.fromJson(json, typeRegistry: reg);
  factory Customer.fromJson(Map json,
      {streamy.TypeRegistry typeRegistry: streamy.EMPTY_REGISTRY, bool copy: false}) {
    if (json == null) {
      return null;
    }
    if (copy) {
      json = new Map.from(json);
    }
    if (json.containsKey(r'accounts')) {
      json[r'accounts'] = streamy.mapInline(streamy.atoi64)(json[r'accounts']);
    }
    streamy.deserializeUnknown(json, KNOWN_PROPERTIES, typeRegistry);
    return new Customer.wrapMap(json);
  }
  Map toJson() {
    Map json = new Map.from(base.getMap(this));
    streamy.serialize(json, r'accounts', streamy.mapCopy(streamy.str));
    return json;
  }
  Customer clone() => copyInto(new Customer());
  Customer patch() => super.patch();
  Type get streamyType => Customer;
}
