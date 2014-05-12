library SchemaUnknownFieldsTest.null.objects;

import 'package:streamy/streamy.dart' as streamy;
import 'package:fixnum/fixnum.dart' as fixnum;
import 'package:streamy/base.dart' as base;

class Foo extends base.Entity {

  static final List<String> KNOWN_PROPERTIES = const [
    r'baz',
  ];

  String get baz => this[r'baz'];
  void set baz(String value) {
    this[r'baz'] = value;
  }

  static final String API_TYPE = r'Foo';

  String get apiType => r'Foo';

  Foo() {
    base.setMap(this, {});
  }

  Foo.wrap(Map<String, dynamic> map) {
    base.setMap(this, map);
  }

  String removeBaz() => this.remove(r'baz');

  Foo clone() => copyInto(new Foo());
}

class Bar extends base.Entity {

  static final List<String> KNOWN_PROPERTIES = const [
  ];

  static final String API_TYPE = r'Bar';

  String get apiType => r'Bar';

  Bar() {
    base.setMap(this, {});
  }

  Bar.wrap(Map<String, dynamic> map) {
    base.setMap(this, map);
  }

  Bar clone() => copyInto(new Bar());
}
