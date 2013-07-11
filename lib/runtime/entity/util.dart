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

  bool equals(Object other) => other is _ErrorEntity;
  int get hashCode => "error".hashCode;

  toString() => "Internal Streamy sentinel value - should not be exposed.";
}

const _INTERNAL_ERROR = const _ErrorEntity();

/// Walk a map-like structure through a list of keys, beginning with an initial value.
_walk(initial, pieces) => pieces.fold(initial,
      (current, keyPiece) => current != null ? current[keyPiece] : null);