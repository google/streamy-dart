part of streamy.runtime;

void _freezeHelper(object) {
  if (object is Freezeable) {
    object.freeze();
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
  bool deliverListChanges() => _delegate.deliverListChanges();
  elementAt(int index) => _delegate.elementAt(index);
  bool every(bool test(element)) => _delegate.every(test);
  Iterable expand(Iterable f(element)) => _delegate.expand(f);
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
  Stream<List<ListChangeRecord>> get listChanges => _delegate.listChanges;
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
  void shuffle([random]) => _throw();
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

  void observed() {}
  void unobserved() {}

  _throw() => throw new UnsupportedError('List is immutable.');
}

_clone(v) {
  if (v is Cloneable) {
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

_patch(v) {
  if (v is Patchable) {
    return v.patch();
  } else if (v is Map) {
    ObservableMap c = new ObservableMap();
    v.forEach((k, v) {
      c[k] = _patch(v);
    });
    return c;
  } else if (v is List) {
    // PATCH semantics dictate that arrays are replaced and not merged. Hence,
    // the array contents need to be clones, not patches.
    return new ObservableList.from(v.map((value) => _clone(value)));
  } else {
    return v;
  }
}

_patchCheckEqual(a, b) {
  if (a is List) {
    if (b is! List || b.length != a.length) {
      return false;
    }
    return zip([a, b]).every((values) => _patchCheckEqual(values[0], values[1]));
  } else if (a is DynamicAccess) {
    return (b is DynamicAccess) && EntityUtils.deepEquals(a, b);
  }
  return a == b;
}

void serialize(Map json, String key, Function map) {
  if (json.containsKey(key)) {
    json[key] = map(json[key]);
  }
}

/// A sentinel value which indicates that an RPC returned an error.
class _ErrorEntity {

  final apiType = '_ErrorEntity';

  const _ErrorEntity();

  GlobalView get global => new GlobalView.empty();

  operator[](key) => throw "Not implemented";
  operator[]=(key, value) {
    throw "Not implemented";
  }
  bool get isFrozen => true;
  void _freeze() {
    // Nothing to freeze in error entity
  }
  toJson() => throw "Not implemented";
  clone() => throw "Not implemented";
  patch() => throw "Not implemented";
  @deprecated  // defined here solely to conform to the interface
  contains(key) => throw "Not implemented";
  containsKey(key) => throw "Not implemented";
  get local => throw "Not implemented";
  get fieldNames => throw "Not implemented";
  get streamyType => throw "Not implemented";

  bool equals(Object other) => other is _ErrorEntity;
  int get hashCode => "error".hashCode;
  toString() => "Internal Streamy sentinel value - should not be exposed.";
}

const _INTERNAL_ERROR = const Response(null, Source.ERROR, 0);

/// Walk a map-like structure through a list of keys, beginning with an initial value.
_walk(initial, List<String> pieces) {
  int len = pieces.length;
  var current = initial;
  for (int i = 0; i < len; i++) {
    if (current == null) {
      return null;
    }
    String piece = pieces[i];
    current = current[piece];
  }
  return current;
}
