part of streamy.runtime;

/// 2^25. Chosen to ensure that ((17 * runningHashCode) + valueHashCode)
/// never exceeds 2^30, the limit of unboxed integers in 32-bit DartVM.
/// Hopefully this will keep hashCode math fast.
const MAX_HASHCODE = 33554432;

typedef void CancelFn();

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

/// A [StreamConsumer] which publishes zero or one entities, depending on whether
/// the [Stream] returns a value or not. Like a [Stream].single which returns
/// null if no value is ever published.
class ZeroOrOneConsumer<Entity> extends StreamConsumer<Entity> {

  Future<Entity> addStream(Stream<Entity> stream) =>
      stream.fold(null, (prev, elem) {
        if (prev == null) {
          return elem;
        }
        throw new StateError('More than one result on the stream: $elem');
      });

  Future<Entity> close() => new Future.value(null);
}
