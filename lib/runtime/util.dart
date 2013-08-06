part of streamy.runtime;

internalCloneFrom(dest, source) => dest.._cloneFrom(source);
internalGetPayload(Request r) => r._payload;

dynamic nullSafeOperation(x, f(elem)) => x != null ? f(x) : null;

/// map() implementation for an Iterable that respects nulls.
List nullSafeMapToList(Iterable i, f(elem)) =>
    nullSafeOperation(i, (i2) => i2.map(f).toList());

/// Removes all key/value pairs whose values are null.
Map removeNulls(Map m) => m..keys
    .where((k) => m[k] == null)
    .toList(growable: false)  // Materialize to avoid concurrent modification.
    .forEach(m.remove);

/// A function that can deserialize a JSON string into a Dart object.
typedef dynamic Deserializer(String str);

/// Returns the object that was passed as the parameter.
identityFn(Object o) => o;


abstract class StreamyException implements Exception { }

class ClosureInEntityException extends StreamyException {
  final String key;
  final String closureToString;

  ClosureInEntityException(this.key, this.closureToString);

  String toString() => 'Attempted to set a closure as an entity property. ' +
      'Use .local for that instead. Key: $key, Closure: $closureToString';
}

class ClosureInvocationException extends StreamyException {

  final String memberName;

  ClosureInvocationException(this.memberName);

  String toString() => "Fields of DynamicEntity objects can't be invoked, as " +
      'they cannot contain closures. Field: $memberName';
}

class ZeroOrOneConsumer<Entity> extends StreamConsumer<Entity> {
  
  Future<Entity> addStream(Stream<Entity> stream) =>
      stream.fold(null, (prev, elem) {
        if (prev == null) {
          return elem;
        }
        throw new StateError('More than one result on the stream');
      });
      
  Future<Entity> close() => new Future.value(null);
}
