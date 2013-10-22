part of streamy.runtime;

/// Produces an entity from a given JSON map
typedef Entity EntityFactory(Map json, TypeRegistry reg);

/// Doesn't contain any types.
const TypeRegistry EMPTY_REGISTRY = const _EmptyTypeRegistry();

void _freezeHelper(object) {
  if (object is Entity) {
    object._freeze();
  } else if (object is Map) {
    object.forEach((key, value) {
      if (value is ObservableList) {
        object[key] = new _ObservableImmutableListView(value);
      }
      _freezeHelper(value);
    });
  } else if (object is List) {
    object.forEach(_freezeHelper);
  }
}

class _ObservableImmutableListView implements ObservableList {
  
  ObservableList _delegate;
  
  _ObservableImmutableListView(ObservableList this._delegate);
  
  Stream<List<ChangeRecord>> get changes => _delegate.changes;
  get first => _delegate.first;
  bool get hasObservers => _delegate.hasObservers;
  bool get isEmpty => _delegate.isEmpty;
  bool get isNotEmpty => _delegate.isNotEmpty;
  Iterator get iterator => _delegate.iterator;
  get last => _delegate.last;
  int get length => _delegate.length;
  set length(int value) => _throw();
  Iterable get reversed => _delegate.reversed;
  get single => _delegate.single;
  operator[](int index) => _delegate[index];
  operator[]=(_a, _b) => _throw();
  void add(_) => _throw();
  void addAll(Iterable _) => _throw();
  bool any(bool test(element)) => _delegate.any(test);
  Map asMap() => _delegate.asMap();
  void clear() => _throw();
  bool contains(element) => _delegate.contains(element);
  bool deliverChanges() => _delegate.deliverChanges();
  elementAt(int index) => _delegate.elementAt(index);
  bool every(bool test(element)) => _delegate.every(test);
  Iterable expand(Iterable f(element)) => _delegate.expand(element);
  void fillRange(_a, _b, [_c]) => _throw();
  firstWhere(bool test(element), {Object orElse()}) => _delegate.firstWhere(test, orElse: orElse);
  fold(initialValue, combine(previousValue, element)) => _delegate.fold(initialValue, combine);
  void forEach(void action(element)) => _delegate.forEach(action);
  Iterable getRange(int start, int end) => _delegate.getRange(start, end);
  int indexOf(Object element, [int startIndex = 0]) => _delegate.indexOf(element, startIndex);
  void insert(_a, _b) => _throw();
  void insertAll(_a, _b) => _throw();
  String join([String separator = '']) => _delegate.join(separator);
  int lastIndexOf(Object element, [int startIndex]) => _delegate.lastIndexOf(element, startIndex);
  lastWhere(bool test(element), {Object orElse()}) => _delegate.lastWhere(test, orElse: orElse);
  Iterable map(f(element)) => _delegate.map(f);
  void notifyChange(_) => _throw();
  void notifyPropertyChange(_a, _b, _c) => _throw();
  reduce(combine(previous, element)) => _delegate.reduce(combine);
  bool remove(_) => _throw();
  removeAt(_) => _throw();
  removeLast() => _throw();
  void removeRange(_a, _b) => _throw();
  void removeWhere(_) => _throw();
  void replaceRange(_a, _b, _c) => _throw();
  void retainWhere(_) => _throw();
  void setAll(_a, _b) => _throw();
  void setRange(_a, _b, _c, [_d]) => _throw();
  void shuffle() => _throw();
  singleWhere(bool test(element)) => _delegate.singleWhere(test);
  Iterable skip(int count) => _delegate.skip(count);
  Iterable skipWhile(bool test(element)) => _delegate.skipWhile(test);
  void sort([_]) => _throw();
  List sublist(int start, [int end]) => _delegate.sublist(start, end);
  Iterable take(int count) => _delegate.take(count);
  Iterable takeWhile(bool test(element)) => _delegate.takeWhile(test);
  List toList({bool growable: true}) => _delegate.toList(growable: growable);
  Set toSet() => _delegate.toSet();
  String toString() => _delegate.toString();
  Iterable where(test(element)) => _delegate.where(test);
  
  _throw() => throw new UnsupportedError('List is immutable.');
}


/// Information about types generated from a discovery document.
abstract class TypeRegistry {

  /// Constructs a registry from a map that maps schema/entity kind to
  /// factories that can deserialize the JSON representation to a concrete
  /// entity object.
  factory TypeRegistry(Map<String, EntityFactory> factoryMap) =>
      new _TypeRegistryImpl(factoryMap);

  /// Checks if a given kind is registered.
  bool isRegistered(String kind);

  /// Deserializes JSON into a concrete entity object. Throws if given [kind]
  /// is not registered, so check with [isRegistered] method prior to calling
  /// this method.
  Entity deserialize(String kind, Map json);
}

/// A real type registry implementation.
class _TypeRegistryImpl implements TypeRegistry {
  final Map<String, EntityFactory> _factoryMap;

  _TypeRegistryImpl(Map<String, EntityFactory> this._factoryMap);

  bool isRegistered(String kind) => this._factoryMap.containsKey(kind);

  Entity deserialize(String kind, Map json) {
    if (!isRegistered(kind)) {
      throw new StateError("'$kind' is not a registered type.");
    }
    return this._factoryMap[kind](json, this);
  }
}

/// A dummy registry that doesn't have any types.
class _EmptyTypeRegistry implements TypeRegistry {
  const _EmptyTypeRegistry();

  Entity deserialize(String kind, Map json) {
    throw new StateError("Not supported by empty registry.");
  }
  bool isRegistered(String kind) => false;
}

_clone(v) {
  if (v is Entity) {
    return v.clone();
  } else if (v is Map) {
    ObservableMap c = new ObservableMap();
    v.forEach((k, v) {
      c[k] = _clone(v);
    });
    return c;
  } else if (v is List) {
    return new ObservableList.from(v.map((value) => _clone(value)));
  } else {
    return v;
  }
}

/**
 * Adds unknown properties from the ramaining map entries after all known
 * properties have been deserialized. [remainderJson] contains the remaining
 * map entries. [typeRegistry] contains information about all types generated
 * from the discovery document.
 *
 * WARNING: This function will overwrite any entries whose field names coincide
 * with keys in the [remainderJson].
 */
addUnknownProperties(Entity destination, Map remainderJson, TypeRegistry reg) {
  remainderJson.forEach((String key, dynamic value) {
    destination[key] = _deserialize(value, reg);
  });
}

/**
 *  Deserializes a JSON [value] into a proper Dart object, unless it is
 *  already deserialized. The [typeRegistry] is used to lookup known types by
 *  'kind' attribute specified in the discovery document.
 */
_deserialize(dynamic value, TypeRegistry reg) {
  if (value is Map) {
    // Might be an object of a known kind
    String kind = value['kind'];
    if (kind == null || !reg.isRegistered(kind)) {
      // Not an object of known kind. Deserialize recursively.
      var result = new RawEntity();
      value.forEach((String key, dynamic value) {
        result[key] = _deserialize(value, reg);
      });
      return result;
    } else {
      // Known kind is specified, deserialize using factory.
      return reg.deserialize(kind, value);
    }
  } if (value is List) {
    // Might contain elements of known kinds
    return value.map((elem) => _deserialize(elem, reg)).toList();
  } else {
    // Already deserialized.
    return value;
  }
}

deserialize(value, TypeRegistry reg) => _deserialize(value, reg);

/// A sentinel value which indicates that an RPC returned an error.
class _ErrorEntity implements Entity {

  const _ErrorEntity();

  operator[](key) => throw "Not implemented";
  operator[]=(key, value) {
    throw "Not implemented";
  }
  toJson() => throw "Not implemented";
  clone() => throw "Not implemented";
  @deprecated  // defined here solely to conform to the interface
  contains(key) => throw "Not implemented";
  containsKey(key) => throw "Not implemented";
  remove(key) => throw "Not implemented";
  get local => throw "Not implemented";
  get fieldNames => throw "Not implemented";
  get streamyType => throw "Not implemented";

  bool equals(Object other) => other is _ErrorEntity;
  int get hashCode => "error".hashCode;
  toString() => "Internal Streamy sentinel value - should not be exposed.";
}

const _INTERNAL_ERROR = const Response(null, Source.ERROR, 0);

/// Walk a map-like structure through a list of keys, beginning with an initial value.
_walk(initial, pieces) => pieces.fold(initial,
      (current, keyPiece) => current != null ? current[keyPiece] : null);