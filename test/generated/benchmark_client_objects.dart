library SchemaObjectTest.objects;

import 'package:streamy/streamy.dart' as streamy;
import 'package:fixnum/fixnum.dart' as fixnum;
import 'package:streamy/base.dart' as base;

class Foo extends base.Entity {

  static final List<String> KNOWN_PROPERTIES = const [
    r'id',
    r'bar',
    r'baz',
    r'cruft',
    r'qux',
    r'quux',
    r'corge',
  ];

  int get id => this[r'id'];
  void set id(int value) {
    this[r'id'] = value;
  }

  Bar get bar => this[r'bar'];
  void set bar(Bar value) {
    this[r'bar'] = value;
  }

  int get baz => this[r'baz'];
  void set baz(int value) {
    this[r'baz'] = value;
  }

  String get cruft => this[r'cruft'];
  void set cruft(String value) {
    this[r'cruft'] = value;
  }

  fixnum.Int64 get qux => this[r'qux'];
  void set qux(fixnum.Int64 value) {
    this[r'qux'] = value;
  }

  List<double> get quux => this[r'quux'];
  void set quux(List<double> value) {
    this[r'quux'] = value;
  }

  List<int> get corge => this[r'corge'];
  void set corge(List<int> value) {
    this[r'corge'] = value;
  }

  String get apiType => r'Foo';

  Foo() {
    base.setMap(this, {});
  }

  Foo.wrap(Map<String, dynamic> map) {
    base.setMap(this, map);
  }

  int removeId() => this.remove(r'id');

  Bar removeBar() => this.remove(r'bar');

  int removeBaz() => this.remove(r'baz');

  String removeCruft() => this.remove(r'cruft');

  fixnum.Int64 removeQux() => this.remove(r'qux');

  List<double> removeQuux() => this.remove(r'quux');

  List<int> removeCorge() => this.remove(r'corge');

  Foo clone() => copyInto(new Foo());
}

class Bar extends base.Entity {

  static final List<String> KNOWN_PROPERTIES = const [
    r'foos',
    r'foo',
  ];

  List<Foo> get foos => this[r'foos'];
  void set foos(List<Foo> value) {
    this[r'foos'] = value;
  }

  Foo get foo => this[r'foo'];
  void set foo(Foo value) {
    this[r'foo'] = value;
  }

  String get apiType => r'Bar';

  Bar() {
    base.setMap(this, {});
  }

  Bar.wrap(Map<String, dynamic> map) {
    base.setMap(this, map);
  }

  List<Foo> removeFoos() => this.remove(r'foos');

  Foo removeFoo() => this.remove(r'foo');

  Bar clone() => copyInto(new Bar());
}
