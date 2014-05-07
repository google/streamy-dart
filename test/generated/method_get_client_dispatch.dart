library MethodGetTest.dispatch;

import 'package:streamy/streamy.dart' as streamy;
import 'package:fixnum/fixnum.dart' as fixnum;
import 'method_get_client_objects.dart' as objects;
import 'package:streamy/base.dart' as base;

class Marshaller {

  static final List<String> _int64sFoo = const [
    r'baz',
  ];

  Map<String, dynamic> marshalFoo(objects.Foo entity) {
    var res = new Map()
      ..addAll(base.getMap(entity));
    streamy.marshalToString(_int64sFoo, res);
    return res;
  }

  objects.Foo unmarshalFoo(Map<String, dynamic> data) { 
   streamy.unmarshalInt64s(_int64sFoo, data); 
   return new objects.Foo.wrap(data);
  }
}
