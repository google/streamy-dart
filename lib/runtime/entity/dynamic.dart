part of streamy.runtime;

class DynamicEntity extends RawEntity {

  DynamicEntity() : super();

  DynamicEntity.fromMap(Map data) {
    data.forEach((key, value) {
      this[key] = value;
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
      throw new ClosureInvocationException(memberName);
    }
  }

  Type get streamyType => DynamicEntity;
}