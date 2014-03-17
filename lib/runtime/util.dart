part of streamy.runtime;

/// 2^25. Chosen to ensure that ((17 * runningHashCode) + valueHashCode)
/// never exceeds 2^30, the limit of unboxed integers in 32-bit DartVM.
/// Hopefully this will keep hashCode math fast.
const MAX_HASHCODE = 33554432;

typedef void CancelFn();

class Cloneable {
  dynamic clone();
}

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
typedef dynamic Deserializer(String str, Trace trace);

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

/// Provides efficient repeated access to a nested field in an [Entity]
/// structure. Efficiency is provided in two main ways: by front-loading the
/// path parsing, and by memoizing lookups so repeated accesses on the same
/// object are fast. This is especially useful for speeding up [Comparator]s,
/// so a useful [FastComparator] abstraction is provided for that purpose.
class FastFieldAccessor<S extends Entity, T> {

  final List<String> _pieces;
  final Expando<T> _cache = new Expando<T>();

  FastFieldAccessor(String path) : _pieces = path.split('.');

  T operator[](S entity) {
    var memoized = _cache[entity];
    if (memoized != null) {
      return memoized;
    }
    var current = entity;
    var i = 0;
    while (current != null && i < _pieces.length) {
      current = current[_pieces[i++]];
    }
    if (current != null) {
      _cache[entity] = current;
    }
    return current;
  }
}

/// A [Comparator] that uses a [FastFieldAccessor] to speed up comparisons based
/// on nested fields in an [Entity].
class FastComparator<S extends Entity, T> {

  final FastFieldAccessor<S, T> accessor;
  final Comparator<T> comparator;

  FastComparator(String field) : this.withComparator(field, Comparable.compare);

  FastComparator.withComparator(String field, this.comparator) :
      accessor = new FastFieldAccessor<S, T>(field);

  int call(S a, S b) => comparator(accessor[a], accessor[b]);
}

/// Applies [fn] to each element and replaces the element with the result.
mapInline(fn(e)) => (List l) {
  if (l == null) return null;
  for (int i = 0; i < l.length; i++) {
    l[i] = fn(l[i]);
  }
  return l;
};

/// Static and null-safe version of [Iterable.map]. Does not alter the passed
/// list. Creates a separate copy instead.
mapCopy(fn(e)) => (List l) {
  if (l == null) return null;
  return l.map(fn).toList();
};

/// Parses [String] to [Int64]. Null-safe.
Int64 atoi64(String v) => v != null ? Int64.parseInt(v) : null;
/// Converts [int] to [Int64]. Null-safe.
Int64 itoi64(int v) => v != null ? new Int64(v) : null;
/// Parses [String] to [double]. Null-safe.
double atod(String v) => v != null ? double.parse(v) : null;
/// Calls [Object.toString] on the passed argument. Null-safe.
String str(v) => v != null ? v.toString() : null;
