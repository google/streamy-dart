library MethodGetTest;

import 'package:streamy/streamy.dart' as streamy;
import 'package:streamy/test/generated/resources.dart' as resources;
import 'package:streamy/base.dart' as base;

class MethodGetTest {

  final streamy.Root _root;

  resources.FoosResource _foos;

  resources.FoosResource get foos {
    if (_foos == null) {
      _foos = new resources.FoosResource(_rh);
    }
    return _foos;
  }

  MethodGetTest(streamy.Root this._root);
}
