library SchemaObjectTest.dispatch;

import 'package:streamy/streamy.dart' as streamy;
import 'package:fixnum/fixnum.dart' as fixnum;
import 'benchmark_client_objects.dart' as objects;
import 'package:streamy/base.dart' as base;

class Marshaller {

  static final List<String> _int64sFoo = const [
    r'qux',
  ];

  static final List<String> _doublesFoo = const [
    r'quux',
  ];

  static final Map<String, dynamic> _entitiesFoo = const {
    r'bar': _handleBar,
  };

  static final Map<String, dynamic> _entitiesBar = const {
    r'foos': _handleFoo,
    r'foo': _handleFoo,
  };

  Map<String, dynamic> marshalFoo(objects.Foo entity) {
    var res = new Map()
      ..addAll(base.getMap(entity));
    streamy.marshalToString(_int64sFoo, res);
    streamy.marshalToString(_doublesFoo, res);
    streamy.handleEntities(_entitiesFoo, res, true);
    return res;
  }

  objects.Foo unmarshalFoo(Map<String, dynamic> data) { 
   streamy.unmarshalInt64s(_int64sFoo, data); 
   streamy.unmarshalDoubles(_doublesFoo, data); 
   streamy.handleEntities(_entitiesFoo, data, false); 
   return new objects.Foo.wrap(data);
  }

  Map<String, dynamic> marshalBar(objects.Bar entity) {
    var res = new Map()
      ..addAll(base.getMap(entity));
    streamy.handleEntities(_entitiesBar, res, true);
    return res;
  }

  objects.Bar unmarshalBar(Map<String, dynamic> data) { 
   streamy.handleEntities(_entitiesBar, data, false); 
   return new objects.Bar.wrap(data);
  }
}
