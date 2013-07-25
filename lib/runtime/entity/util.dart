part of streamy.runtime;

/// Produces an entity from a given JSON map
typedef Entity EntityFactory(Map json);

/// Information about a type generated from a discovery document
class TypeInfo {
  final EntityFactory _ef;
  TypeInfo(this._ef);
  Entity fromJson(Map json) => this._ef(json);
}

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
  get streamy => throw "Not implemented";

  bool equals(Object other) => other is _ErrorEntity;
  int get hashCode => "error".hashCode;
  toString() => "Internal Streamy sentinel value - should not be exposed.";
}

const _INTERNAL_ERROR = const _ErrorEntity();

/// Walk a map-like structure through a list of keys, beginning with an initial value.
_walk(initial, pieces) => pieces.fold(initial,
      (current, keyPiece) => current != null ? current[keyPiece] : null);