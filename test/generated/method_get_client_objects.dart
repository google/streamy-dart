library MethodGetTest.null.objects;

import 'package:streamy/streamy.dart' as streamy;
import 'package:fixnum/fixnum.dart' as fixnum;
import 'package:streamy/base.dart' as base;

class Foo extends base.Entity {

  int get id => this[r'id'];
  void set id(int value) {
    this[r'id'] = value;
  }

  String get bar => this[r'bar'];
  void set bar(String value) {
    this[r'bar'] = value;
  }

  fixnum.Int64 get baz => this[r'baz'];
  void set baz(fixnum.Int64 value) {
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

  int removeId() => this.remove(r'id');

  String removeBar() => this.remove(r'bar');

  fixnum.Int64 removeBaz() => this.remove(r'baz');

  Foo clone() => copyInto(new Foo());
}
