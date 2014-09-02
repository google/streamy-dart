part of streamy.testing;

@proxy
class DynamicEntity {

  DynamicEntity() : super();

  DynamicEntity.fromMap(Map data) {
    data.forEach((key, value) {
      this[key] = toObservable(value);
    });
  }

  noSuchMethod(Invocation invocation) {
    var memberName = MirrorSystem.getName(invocation.memberName);
    if (invocation.isGetter) {
      return this[memberName];
    } else if (invocation.isSetter) {
      // Setter member names have an '=' at the end, strip it.
      var key = memberName.substring(0, memberName.length - 1);
      this[key] = invocation.positionalArguments[0];
    } else {
      // Perhaps the called was trying to call a nonexistent method,
      // or perhaps the caller was trying to invoke a data member as a
      // completion. Throw an appropriate error.
      if (containsKey(memberName)) {
        throw new ClosureInvocationException(memberName);
      } else {
        throw new NoSuchMethodError(this, memberName,
            invocation.positionalArguments, invocation.namedArguments);
      }
    }
  }

  Type get streamyType => DynamicEntity;
}

class ClosureInvocationException extends StreamyException {

  final String memberName;

  ClosureInvocationException(this.memberName);

  String toString() => "Fields of DynamicEntity objects can't be invoked, as " +
      'they cannot contain closures. Field: $memberName';
}
