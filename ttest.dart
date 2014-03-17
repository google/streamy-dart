library streamy;

import 'package:streamy/base.dart' as base;
import 'test/generated/schema_object_client_objects.dart';

main() {
  var f = new Foo();
  f.id = 1;
  f.bar = "baz";
  print(base.getMap(f));
}