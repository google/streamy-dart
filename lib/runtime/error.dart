part of streamy.runtime;

typedef Future RetryStrategy(int retryCount);

Future<bool> retryImmediately(int retryCount) => new Future.value(true);

typedef void StreamyRpcRetryFn();

class StreamyRpcException implements Exception {
  final int httpStatus;
  final Request request;
  bool get retryable => false;
  final List<Map> errors;
  Map get error => errors[0];
  
  StreamyRpcException._private(this.httpStatus, this.request, this.errors);
}

class StreamyRetryableRpcException extends StreamyRpcException {
  
  final int retryCount;
  final StreamyRpcExceptionRetryFn retry;
  
  bool get retryable => true;
  
  StreamyRetryableRpcException._wrap(StreamyRpcException e, this.retryCount, this.retry) : super(e.httpStatus, e.request, e.errors)
  

class NotRetryableException implements Exception {
  toString() => "[notRetryable: Streamy request is not retryable]";
}

class RetryingRequestHandler extends RequestHandler {
  
  final RequestHandler delegate;
  final RetryStrategy strategy;
  final List errorCodesToRetry;
  final int maxRetries;
  
  RetryingRequestHandler(this.delegate, {this.strategy: retryImmediately, this.maxRetries: 3, this.errorCodesToRetry: [500, 503]});
  
  Stream handle(Request request) {
    if (request.local['globalErrorHandling'] == false) {
      return _handleLocally(request);
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
          var retryFuture = strategy(request, ++retry, e);
          if (retry > maxRetries) {
            // Time to give up.
            throw e;
          }
          return retryFuture.then((_) => doRpc());
        });
    }
    
    return doRpc().asStream();
  }
  
  Stream _handleLocally(Request request) {
    // We explicitly don't care about onCancel, since only the Multiplexer will use this.
    StreamController c = new StreamController();
    int retry = 0;
    
    void doRpc() {
      delegate.handle(request).single
        .then((value) {
          c.add(value);
          c.close();
        }).catchError((e) {
          if (!_isRetryable(e)) {
            c.addError(e);
            c.close();
            return;
          }
          if (retry > maxRetries) {
            c.addError(e);
            c.close();
          }
          c.addError(new StreamyRetryableRpcException._wrap(e, ++retry, doRpc));
        });
    }
    
    doRpc();
    return c.stream;
  }
}
