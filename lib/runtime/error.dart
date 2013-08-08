part of streamy.runtime;

typedef Future RetryStrategy(int retryCount);

Future<bool> retryImmediately(int retryCount) => new Future.value(true);

class RetryingRequestHandler extends RequestHandler {
  
  final RequestHandler delegate;
  final RetryStrategy strategy;
  final List errorCodesToRetry;
  final int maxRetries;
  
  RetryingRequestHandler(this.delegate, {this.strategy: retryImmediately, this.maxRetries: 3, this.errorCodesToRetry: [500, 503]});
  
  Stream handle(Request request) {
    if (request.local['globalErrorHandling'] == false) {
      return delegate.handle(request);
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
          var retryFuture = strategy(++retry, e);
          if (retry > maxRetries) {
            // Time to give up.
            throw e;
          }
          return retryFuture.then((_) => doRpc());
        });
    }
    
    return doRpc().asStream();
  }
}
