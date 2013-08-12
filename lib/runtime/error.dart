part of streamy.runtime;

/// Thrown by Streamy whenever the backend returns an error which cannot be recovered from.
class StreamyRpcException implements Exception {

  /// The Http status code returned by the backend.
  final int httpStatus;

  /// The request that resulted in the error.
  final Request request;

  /// The deserializer error response (if any).
  final Map response;

  /// Convenience accessor 
  List<Map> get errors => response != null ? response['error']['errors'] : null;
  Map get error => errors != null && errors.length > 0 ? errors[0] : null;
  String get message => error != null && error.containsKey('message') ? error['message'] : null;

  StreamyRpcException(this.httpStatus, this.request, this.response);
}

typedef Future<bool> RetryStrategy(Request request, int retryNum, e);

Future<bool> retryImmediately(Request request, int retryNum, e) => new Future.value(true);

/// A [RequestHandler] which retries requests according to a [RetryStrategy], with the default
/// being to retry them immediately.
class RetryingRequestHandler extends RequestHandler {

  final RequestHandler delegate;
  final RetryStrategy strategy;
  final List errorCodesToRetry;
  final int maxRetries;

  RetryingRequestHandler(this.delegate, {this.strategy: retryImmediately, this.maxRetries: 0, this.errorCodesToRetry: const [
    408, // Request timeout
    500, // Internal server error
    502, // Bad gateway
    503, // Service unavailable
    504  // Gateway timeout
  ]});

  Stream handle(Request request) {
    var strategy = this.strategy;
    if (request.local['retryStrategy'] != null) {
      strategy = request.local['retryStrategy'];
    }

    int retry = 0;

    Future doRpc() {
      return delegate.handle(request).single
        // A successful RPC returns from here.
        .catchError((e) {
          if (!_isRetryable(request, e)) {
            // Rethrow exceptions which can't be handled.
            throw e;
          }
          // We need to retry. retryFuture is a future that doesn't return a value, but indicates when
          // the call should be retried.
          retry++;
          if (maxRetries > 0 && retry > maxRetries) {
            // Time to give up.
            throw e;
          }
          var retryFuture = strategy(request, retry, e);
          return retryFuture.then((shouldRetry) {
            if (!shouldRetry) {
              throw e;
            }
            return doRpc();
          });
        });
    }

    return doRpc().asStream();
  }

  bool _isRetryable(request, e) {
    if (!request.isCachable || e is! StreamyRpcException) {
      return false;
    }
    return errorCodesToRetry.contains(e.httpStatus);
  }
}
