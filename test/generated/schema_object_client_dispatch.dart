library SchemaObjectTest.dispatch;

import 'package:streamy/streamy.dart' as streamy;
import 'package:fixnum/fixnum.dart' as fixnum;
import 'schema_object_client_objects.dart' as objects;
import 'package:streamy/base.dart' as base;

class Marshaller {

  static final List<String> _int64sFoo = const [
    r'qux',
  ];

  static final List<String> _doublesFoo = const [
    r'quux',
  ];

  static final Map<String, dynamic> _entitiesBar = const {
    r'primary': _handleFoo,
    r'foos': _handleFoo,
  };

  static final List<String> _int64s-some-entity- = const [
    r'%badly#named property~!@#$%^&*()?',
  ];

  Map<String, dynamic> marshalFoo(objects.Foo entity) {
    var res = new Map()
      ..addAll(base.getMap(entity));
    streamy.marshalToString(_int64sFoo, res);
    streamy.marshalToString(_doublesFoo, res);
    return res;
  }

  objects.Foo unmarshalFoo(Map<String, dynamic> data) { 
   streamy.unmarshalInt64s(_int64sFoo, data); 
   streamy.unmarshalDoubles(_doublesFoo, data); 
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

  Map<String, dynamic> marshalContext(objects.Context entity) {
    var res = new Map()
      ..addAll(base.getMap(entity));
    return res;
  }

  objects.Context unmarshalContext(Map<String, dynamic> data) { 
   return new objects.Context.wrap(data);
  }

  Map<String, dynamic> marshal-some-entity-(objects.-some-entity- entity) {
    var res = new Map()
      ..addAll(base.getMap(entity));
    streamy.marshalToString(_int64s-some-entity-, res);
    return res;
  }

  objects.-some-entity- unmarshal-some-entity-(Map<String, dynamic> data) { 
   streamy.unmarshalInt64s(_int64s-some-entity-, data); 
   return new objects.-some-entity-.wrap(data);
  }
}
