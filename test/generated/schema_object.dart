library SchemaObjectTest;

import 'package:streamy/streamy.dart' as streamy;
import 'package:streamy/test/generated/resources.dart' as resources;
import 'package:streamy/base.dart' as base;

class SchemaObjectTest {

  final streamy.Root _root;

  resources.-some-resource-Resource _-some-resource-;

  resources.-some-resource-Resource get -some-resource- {
    if (_-some-resource- == null) {
      _-some-resource- = new resources.-some-resource-Resource(_rh);
    }
    return _-some-resource-;
  }

  SchemaObjectTest(streamy.Root this._root);
}
