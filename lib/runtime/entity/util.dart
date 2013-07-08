part of streamy.runtime;

/// Produces an entity from a given JSON map
typedef Entity EntityFactory(Map json);

/// Information about a type generated from a discovery document
class TypeInfo {
  final EntityFactory _ef;
  TypeInfo(this._ef);
  Entity fromJson(Map json) => this._ef(json);
}
