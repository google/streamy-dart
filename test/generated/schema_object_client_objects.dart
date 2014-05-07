library SchemaObjectTest.objects;

import 'package:streamy/streamy.dart' as streamy;
import 'package:fixnum/fixnum.dart' as fixnum;
import 'package:streamy/base.dart' as base;

class Foo extends base.Entity {

  static final List<String> KNOWN_PROPERTIES = const [
    r'id',
    r'bar',
    r'baz',
    r'qux',
    r'quux',
    r'corge',
  ];

  int get id => this[r'id'];
  void set id(int value) {
    this[r'id'] = value;
  }

  String get bar => this[r'bar'];
  void set bar(String value) {
    this[r'bar'] = value;
  }

  int get baz => this[r'baz'];
  void set baz(int value) {
    this[r'baz'] = value;
  }

  fixnum.Int64 get qux => this[r'qux'];
  void set qux(fixnum.Int64 value) {
    this[r'qux'] = value;
  }

  List<double> get quux => this[r'quux'];
  void set quux(List<double> value) {
    this[r'quux'] = value;
  }

  double get corge => this[r'corge'];
  void set corge(double value) {
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

  String removeBar() => this.remove(r'bar');

  int removeBaz() => this.remove(r'baz');

  fixnum.Int64 removeQux() => this.remove(r'qux');

  List<double> removeQuux() => this.remove(r'quux');

  double removeCorge() => this.remove(r'corge');

  Foo clone() => copyInto(new Foo());
}

class Bar extends base.Entity {

  static final List<String> KNOWN_PROPERTIES = const [
    r'primary',
    r'foos',
  ];

  Foo get primary => this[r'primary'];
  void set primary(Foo value) {
    this[r'primary'] = value;
  }

  List<Foo> get foos => this[r'foos'];
  void set foos(List<Foo> value) {
    this[r'foos'] = value;
  }

  String get apiType => r'Bar';

  Bar() {
    base.setMap(this, {});
  }

  Bar.wrap(Map<String, dynamic> map) {
    base.setMap(this, map);
  }

  Foo removePrimary() => this.remove(r'primary');

  List<Foo> removeFoos() => this.remove(r'foos');

  Bar clone() => copyInto(new Bar());
}

class Context extends base.Entity {

  static final List<String> KNOWN_PROPERTIES = const [
    r'facets',
  ];

  List<List<dynamic>> get facets => this[r'facets'];
  void set facets(List<List<dynamic>> value) {
    this[r'facets'] = value;
  }

  String get apiType => r'Context';

  Context() {
    base.setMap(this, {});
  }

  Context.wrap(Map<String, dynamic> map) {
    base.setMap(this, map);
  }

  List<List<dynamic>> removeFacets() => this.remove(r'facets');

  Context clone() => copyInto(new Context());
}

class -some-entity- extends base.Entity {

  static final List<String> KNOWN_PROPERTIES = const [
    r'%badly#named property~!@#$%^&*()?',
  ];

  fixnum.Int64 get %badly#named property~!@#$%^&*()? => this[r'%badly#named property~!@#$%^&*()?'];
  void set %badly#named property~!@#$%^&*()?(fixnum.Int64 value) {
    this[r'%badly#named property~!@#$%^&*()?'] = value;
  }

  String get apiType => r'-some-entity-';

  -some-entity-() {
    base.setMap(this, {});
  }

  -some-entity-.wrap(Map<String, dynamic> map) {
    base.setMap(this, map);
  }

  fixnum.Int64 remove%badly#named property~!@#$%^&*()?() => this.remove(r'%badly#named property~!@#$%^&*()?');

  -some-entity- clone() => copyInto(new -some-entity-());
}
