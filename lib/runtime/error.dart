part of streamy.runtime;

typedef Future RetryStrategy(Request request, int retryNum, e);

Future<bool> retryImmediately(Request request, int retryNum, e) => new Future.value(true);

class StreamyRpcException implements Exception {
  final int httpStatus;
  final Request request;
  final Map response;
  List<Map> get errors => response != null ? response['error']['errors'] : null;
  Map get error => errors != null && errors.length > 0 ? errors[0] : null;
  String get message => error != null && error.containsKey('message') ? error['message'] : null;
  
  StreamyRpcException(this.httpStatus, this.request, this.response);
}

class RetryingRequestHandler extends RequestHandler {
  
  final RequestHandler delegate;
  final RetryStrategy strategy;
  final List errorCodesToRetry;
  final int maxRetries;
  
  RetryingRequestHandler(this.delegate, {this.strategy: retryImmediately, this.maxRetries: 0, this.errorCodesToRetry: [500, 503]});
  
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
          if (!_isRetryable(e)) {
            // Rethrow exceptions which can't be handled.
            throw e;
          }
          // We need to retry. retryFuture is a future that doesn't return a value, but indicates when
          // the call should be retried.
          var retryFuture = retryStrategy(request, ++retry, e);
          if (retry == maxRetries + 1) {
            // Time to give up.
            throw e;
          }
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
  
  bool _isRetryable(e) {
    if (e is! StreamyRpcException) {
      return false;
    }
    return (e.httpStatus in errorCodesToRetry);
  }
}
