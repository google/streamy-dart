library AddendumTest.dispatch;

import 'package:streamy/streamy.dart' as streamy;
import 'package:fixnum/fixnum.dart' as fixnum;
import 'addendum_client_objects.dart' as objects;
import 'package:streamy/base.dart' as base;

class Marshaller {

  Map<String, dynamic> marshalFoo(objects.Foo entity) {
    var res = new Map()
      ..addAll(base.getMap(entity));
    return res;
  }

  objects.Foo unmarshalFoo(Map<String, dynamic> data) { 
   return new objects.Foo.wrap(data);
  }
}
