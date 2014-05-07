library MethodPostTest;

import 'package:streamy/streamy.dart' as streamy;
import 'package:streamy/test/generated/resources.dart' as resources;
import 'package:streamy/base.dart' as base;

class MethodPostTest {

  final streamy.Root _root;

  resources.FoosResource _foos;

  resources.FoosResource get foos {
    if (_foos == null) {
      _foos = new resources.FoosResource(_rh);
    }
    return _foos;
  }

  MethodPostTest(streamy.Root this._root);
}
