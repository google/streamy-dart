part of streamy.runtime;

/// Metadata that Streamy tracks about a given entity.
class StreamyEntityMetadata {

  /// Internal map of metadata.
  final _metadata = new ComparableMap<String, dynamic>();

  /// Internal constructor.
  StreamyEntityMetadata._private();

  /// Utility to help copy metadata from one entity to another.
  _mergeFrom(StreamyEntityMetadata other) => _metadata.addAll(other._metadata);

  /// Get the timestamp at which this entity was returned from the server.
  int get ts => _metadata['ts'];

  /// Set the timestamp at which this entity was returned from the server.
  void set ts(int v) {
    _metadata['ts'] = v;
  }

  /// Get the source of this entity (cache, rpc, etc).
  String get source => _metadata['source'];

  /// Set the source of this entity.
  void set source(String v) {
    _metadata['source'] = v;
  }

  bool operator ==(other) =>
    other is StreamyEntityMetadata && other._metadata == _metadata;

  int get hashCode => _metadata.hashCode;
}

/// A [Map] that has dot-property access and equality, which backs the .local
/// property.
class LocalDataMap implements Map {

  final Map _delegate = {};

  LocalDataMap();

  factory LocalDataMap.of(Map other) {
    var ldm = new LocalDataMap();
    other.forEach((k, v) => ldm[k] = v);
    return ldm;
  }

  // Straight delegations from [Map]:

  bool get isEmpty => _delegate.isEmpty;
  bool get isNotEmpty => _delegate.isNotEmpty;
  Iterable get keys => _delegate.keys;
  int get length => _delegate.length;
  Iterable get values => _delegate.values;
  void clear() {
    _delegate.clear();
  }
  bool containsKey(key) => _delegate.containsKey(key);
  bool containsValue(value) => _delegate.containsValue(value);
  void forEach(void fn(k, v)) {
    _delegate.forEach(fn);
  }
  dynamic remove(key) => _delegate.remove(key);
  dynamic operator[](key) => _delegate[key];

  // Overrides of [Map] behavior:

  /// Override of the [Map] setter interface, which wraps [Map] values in
  /// [LocalDataMap]s.
  operator[]=(key, value) {
    if (value is Map) {
      value = new LocalDataMap.of(value);
    }
    return (_delegate[key] = value);
  }

  /// Overrides the [Map] putIfAbsent interface, which wraps [Map] values in
  /// [LocalDataMap]s.
  dynamic putIfAbsent(key, dynamic isAbsent()) {
    if (!containsKey(key)) {
      // Use the setter interface to handle the [LocalDataMap] conversion.
      this[key] = isAbsent();
    }
    return this[key];
  }

  /// Implements the [Map] [addAll]] interface, which wraps [Map] values in
  /// [LocalDataMap]s.
  void addAll(Map other) {
    other.forEach((key, value) {
      this[key] = value;
    });
  }

  bool operator==(other) => compareMapObjects(this, other);
  int get hashCode => hashCodeForMap(this);

  /// [noSuchMethod] provides dot-property access to fields.
  noSuchMethod(Invocation invocation) {
    var memberName = MirrorSystem.getName(invocation.memberName);
    if (invocation.isGetter) {
      return this[memberName];
    } else if (invocation.isSetter) {
      // Setter member names have a '=' at the end, strip it.
      var key = memberName.substring(0, memberName.length - 1);
      this[key] = invocation.positionalArguments[0];
    } else {
      // This is a closure invocation for a property.
      return Function.apply(this[memberName], invocation.positionalArguments,
          invocation.namedArguments);
    }
  }
}
