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

  @override
  String toString() => response.toString();
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

  RetryingRequestHandler(this.delegate, {this.strategy: retryImmediately, this.maxRetries: 0,
      this.errorCodesToRetry: const [
        408, // Request timeout
        500, // Internal server error
        502, // Bad gateway
        503, // Service unavailable
        504  // Gateway timeout
      ]});

  Stream<Response> handle(Request request, Trace trace) {
    var strategy = this.strategy;
    if (request.local['retryStrategy'] != null) {
      strategy = request.local['retryStrategy'];
    }

    // Pending request subscription. Used to cancel the request if asked.
    var pendingSub;

    var output;
    output = new StreamController<Response>(onCancel: () {
      if (output.isClosed) {
        return;
      }
      pendingSub.cancel();
    });

    int retry = 0;

    void doRpc() {
      pendingSub = delegate.handle(request, trace).listen((result) {
        // We're done.
        output.add(result);
        output.close();
      })..onError((e) {
        // If the request/error is not retryable, or the number of retries is over the limit,
        // stop retrying.
        retry++;
        var retryable = !_isRetryable(request, e);
        if (retryable || (maxRetries > 0 && retry > maxRetries)) {
          if (retryable) {
            trace.record(new RetryMaxedOutEvent());
          }
          // If this error can't be handled, pass it to the app and stop trying.
          output.addError(e);
          output.close();
          return;
        }
        // This request may need to be retried. Ask the retry strategy.
        trace.record(new MaybeRetryEvent());
        strategy(request, retry, e).catchError((_) => false).then((shouldRetry) {
          if (!shouldRetry) {
            trace.record(new RetryAbortEvent());
            // The retry handler says to give up. Pass the original error through.
            output.addError(e);
            output.close();
            return;
          }
          trace.record(new RetryEvent());
          // Retry now!
          doRpc();
        });
      });
    }

    // Kick off the first request.
    doRpc();
    return output.stream;
  }

  bool _isRetryable(request, e) {
    if (!request.isCachable || e is! StreamyRpcException) {
      return false;
    }
    return errorCodesToRetry.contains(e.httpStatus);
  }
}

class RetryEvent implements TraceEvent {

  factory RetryEvent() => const RetryEvent._private();

  const RetryEvent._private();

  String toString() => 'streamy.retry.retry';
}

class MaybeRetryEvent implements TraceEvent {
  factory MaybeRetryEvent() => const MaybeRetryEvent._private();

  const MaybeRetryEvent._private();

  String toString() => 'streamy.retry.maybe';
}

class RetryAbortEvent implements TraceEvent {
  factory RetryAbortEvent() => const RetryAbortEvent._private();

  const RetryAbortEvent._private();

  String toString() => 'streamy.retry.abort';
}

class RetryMaxedOutEvent implements TraceEvent {
  factory RetryMaxedOutEvent() => const RetryMaxedOutEvent._private();

  const RetryMaxedOutEvent._private();

  String toString() => 'streamy.retry.maxedOut';
}


