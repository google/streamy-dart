part of streamy.runtime;

/// Metadata that Streamy tracks about a given entity.
class StreamyEntityMetadata {

  /// Internal map of metadata.
  final _metadata = {};

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
}
