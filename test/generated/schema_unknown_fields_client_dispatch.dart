library SchemaUnknownFieldsTest.null.dispatch;

import 'package:streamy/streamy.dart' as streamy;
import 'package:fixnum/fixnum.dart' as fixnum;
import 'schema_unknown_fields_client_objects.dart' as objects;
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

  Map<String, dynamic> marshalBar(objects.Bar entity) {
    var res = new Map()
      ..addAll(base.getMap(entity));
    return res;
  }

  objects.Bar unmarshalBar(Map<String, dynamic> data) { 
   return new objects.Bar.wrap(data);
  }
}
