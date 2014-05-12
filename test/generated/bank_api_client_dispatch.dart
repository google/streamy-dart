library Bank.null.dispatch;

import 'package:streamy/streamy.dart' as streamy;
import 'package:fixnum/fixnum.dart' as fixnum;
import 'bank_api_client_objects.dart' as objects;
import 'package:streamy/base.dart' as base;

class Marshaller {

  static final List<String> _int64sBranch = const [
    r'id',
  ];

  static final Map<String, dynamic> _entitiesBranch = const {
    r'location': _handleAddress,
  };

  static final List<String> _int64sAccount = const [
    r'account_number',
    r'balance',
  ];

  static final List<String> _int64sCustomer = const [
    r'accounts',
  ];

  Map<String, dynamic> marshalBranch(objects.Branch entity) {
    var res = new Map()
      ..addAll(base.getMap(entity));
    streamy.marshalToString(_int64sBranch, res);
    streamy.handleEntities(_entitiesBranch, res, true);
    return res;
  }

  objects.Branch unmarshalBranch(Map<String, dynamic> data) { 
   streamy.unmarshalInt64s(_int64sBranch, data); 
   streamy.handleEntities(_entitiesBranch, data, false); 
   return new objects.Branch.wrap(data);
  }

  Map<String, dynamic> marshalAddress(objects.Address entity) {
    var res = new Map()
      ..addAll(base.getMap(entity));
    return res;
  }

  objects.Address unmarshalAddress(Map<String, dynamic> data) { 
   return new objects.Address.wrap(data);
  }

  Map<String, dynamic> marshalAccount(objects.Account entity) {
    var res = new Map()
      ..addAll(base.getMap(entity));
    streamy.marshalToString(_int64sAccount, res);
    return res;
  }

  objects.Account unmarshalAccount(Map<String, dynamic> data) { 
   streamy.unmarshalInt64s(_int64sAccount, data); 
   return new objects.Account.wrap(data);
  }

  Map<String, dynamic> marshalCustomer(objects.Customer entity) {
    var res = new Map()
      ..addAll(base.getMap(entity));
    streamy.marshalToString(_int64sCustomer, res);
    return res;
  }

  objects.Customer unmarshalCustomer(Map<String, dynamic> data) { 
   streamy.unmarshalInt64s(_int64sCustomer, data); 
   return new objects.Customer.wrap(data);
  }
}
