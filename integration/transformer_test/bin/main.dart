import 'package:transformer_test/test_objects.dart';
import 'package:fixnum/fixnum.dart';

main() {
  var foo = new Foo();
  foo.bar = new Int64(123);
  print(foo.bar);
}
