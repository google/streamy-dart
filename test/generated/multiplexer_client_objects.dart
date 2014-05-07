library MultiplexerTest.objects;

import 'package:streamy/streamy.dart' as streamy;
import 'package:fixnum/fixnum.dart' as fixnum;
import 'package:streamy/base.dart' as base;

class Foo extends base.Entity {

  static final List<String> KNOWN_PROPERTIES = const [
    r'id',
    r'bar',
  ];

  int get id => this[r'id'];
  void set id(int value) {
    this[r'id'] = value;
  }

  String get bar => this[r'bar'];
  void set bar(String value) {
    this[r'bar'] = value;
  }

  String get apiType => r'Foo';

  Foo() {
    base.setMap(this, {});
  }

  Foo.wrap(Map<String, dynamic> map) {
    base.setMap(this, map);
  }

  int removeId() => this.remove(r'id');

  String removeBar() => this.remove(r'bar');

  Foo clone() => copyInto(new Foo());
}
