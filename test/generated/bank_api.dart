library Bank;

import 'package:streamy/streamy.dart' as streamy;
import 'package:streamy/test/generated/resources.dart' as resources;
import 'package:streamy/base.dart' as base;

class Bank {

  final streamy.Root _root;

  resources.BranchesResource _branches;

  resources.BranchesResource get branches {
    if (_branches == null) {
      _branches = new resources.BranchesResource(_rh);
    }
    return _branches;
  }

  Bank(streamy.Root this._root);
}
