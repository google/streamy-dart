library Bank.objects;

import 'package:streamy/streamy.dart' as streamy;
import 'package:fixnum/fixnum.dart' as fixnum;
import 'package:streamy/base.dart' as base;

class Branch extends base.Entity {

  static final List<String> KNOWN_PROPERTIES = const [
    r'id',
    r'name',
    r'location',
  ];

  fixnum.Int64 get id => this[r'id'];
  void set id(fixnum.Int64 value) {
    this[r'id'] = value;
  }

  String get name => this[r'name'];
  void set name(String value) {
    this[r'name'] = value;
  }

  Address get location => this[r'location'];
  void set location(Address value) {
    this[r'location'] = value;
  }

  String get apiType => r'Branch';

  Branch() {
    base.setMap(this, {});
  }

  Branch.wrap(Map<String, dynamic> map) {
    base.setMap(this, map);
  }

  fixnum.Int64 removeId() => this.remove(r'id');

  String removeName() => this.remove(r'name');

  Address removeLocation() => this.remove(r'location');

  Branch clone() => copyInto(new Branch());
}

class Address extends base.Entity {

  static final List<String> KNOWN_PROPERTIES = const [
  ];

  String get apiType => r'Address';

  Address() {
    base.setMap(this, {});
  }

  Address.wrap(Map<String, dynamic> map) {
    base.setMap(this, map);
  }

  Address clone() => copyInto(new Address());
}

class Account extends base.Entity {

  static final List<String> KNOWN_PROPERTIES = const [
    r'account_number',
    r'branch_id',
    r'account_type',
    r'currency_type',
    r'balance',
  ];

  fixnum.Int64 get accountNumber => this[r'account_number'];
  void set accountNumber(fixnum.Int64 value) {
    this[r'account_number'] = value;
  }

  int get branchId => this[r'branch_id'];
  void set branchId(int value) {
    this[r'branch_id'] = value;
  }

  String get accountType => this[r'account_type'];
  void set accountType(String value) {
    this[r'account_type'] = value;
  }

  String get currencyType => this[r'currency_type'];
  void set currencyType(String value) {
    this[r'currency_type'] = value;
  }

  fixnum.Int64 get balance => this[r'balance'];
  void set balance(fixnum.Int64 value) {
    this[r'balance'] = value;
  }

  String get apiType => r'Account';

  Account() {
    base.setMap(this, {});
  }

  Account.wrap(Map<String, dynamic> map) {
    base.setMap(this, map);
  }

  fixnum.Int64 removeAccountNumber() => this.remove(r'account_number');

  int removeBranchId() => this.remove(r'branch_id');

  String removeAccountType() => this.remove(r'account_type');

  String removeCurrencyType() => this.remove(r'currency_type');

  fixnum.Int64 removeBalance() => this.remove(r'balance');

  Account clone() => copyInto(new Account());
}

class Customer extends base.Entity {

  static final List<String> KNOWN_PROPERTIES = const [
    r'accounts',
    r'name',
  ];

  List<fixnum.Int64> get accounts => this[r'accounts'];
  void set accounts(List<fixnum.Int64> value) {
    this[r'accounts'] = value;
  }

  String get name => this[r'name'];
  void set name(String value) {
    this[r'name'] = value;
  }

  String get apiType => r'Customer';

  Customer() {
    base.setMap(this, {});
  }

  Customer.wrap(Map<String, dynamic> map) {
    base.setMap(this, map);
  }

  List<fixnum.Int64> removeAccounts() => this.remove(r'accounts');

  String removeName() => this.remove(r'name');

  Customer clone() => copyInto(new Customer());
}
