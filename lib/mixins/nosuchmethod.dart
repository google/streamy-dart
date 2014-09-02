library streamy.trait.nosuchmethod;

import 'dart:mirrors';

class NoSuchMethod {
  
  noSuchMethod(Invocation inv) {
    if (!inv.isAccessor) {
      return super.noSuchMethod(inv);
    }
    if (inv.isGetter) {
      return this[MirrorSystem.getName(inv.memberName)];
    } else if (inv.isSetter) {
      this[MirrorSystem.getName(inv.memberName)] = inv.positionalArguments[0];
    }
  }
}
