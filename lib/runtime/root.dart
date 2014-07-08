part of streamy.runtime;

/// The root object representing an entire API, which makes its resources
/// available.
abstract class Root {

  // Type name as defined in the API.
  String get apiType => 'Root';

  /// Execute a [Request] and return a [Stream] of the results.
  Stream<Response> send(Request req);
}

// A [Root] with an Http path.
abstract class HttpRoot implements Root {
  final String servicePath;
  
  HttpRoot(this.servicePath);

  dynamic get marshaller;
}

/// Substitute for a [Root] object that executes requests as part of the same
/// transaction. The implementation of a transactional strategy is provided by
/// a [TransactionStrategy] object.
class TransactionRoot extends Root {

  final Transaction _tx;

  TransactionRoot(Transaction this._tx) : super();

  Stream send(Request request) => _tx.send(request);
  Future commit() => _tx.commit();
}
