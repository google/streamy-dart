part of streamy.runtime;

/// Metadata that Streamy tracks about a given entity.
class StreamyEntityMetadata {

  /// Internal constructor.
  StreamyEntityMetadata._private();

  /// Utility to help copy metadata from one entity to another.
  _mergeFrom(StreamyEntityMetadata other) {
    ts = other.ts;
  }

  /// Timestamp at which this entity was returned from the server.
  int ts;
}

class Result<T> {
  
  T result;
  String source;
  
  Result(T this.result, String this.source);
}
