part of streamy.runtime;

/**
 * Accepts HTTP requests and decides how to batch them and when to send
 * batches.
 */
abstract class BatchingStrategy {
  /// Accepts a HTTP request
  void add(StreamyHttpRequest request);

  /**
   * Produces requests and batches of requests to be sent to the server.
   *
   * To send a single standalone HTTP request the stream must produce a value
   * of type [StreamyHttpRequest].
   *
   * To send a batch of HTTP requests, the stream must produce a value of type
   * [Batch].
   */
  Stream get batches;
}

/**
 * Represents a batch of HTTP requests to be sent as a single multipart/mixed
 * payload.
 */
abstract class Batch {
  final List<StreamyHttpRequest> requests;
  final Future onCancel;

  Batch(this.requests, this.onCancel);

  /**
   * Is called by [BatchingHttpService] to notify the [BatchingStrategy] that
   * a batch request has completed.
   */
  void done(StreamyHttpResponse batchResponse);
}

/**
 * Batches requests and sends them to a delegate HTTP service as
 * multipart/mixed POST requests.
 */
class BatchingHttpService implements StreamyHttpService {

  static final _responseCompleter =
      new Expando<Completer<StreamyHttpResponse>>(
          'BatchingHttpService.responseCompleter');

  final String _batchUrl;
  final String _method;
  final Map<String, String> _headers;
  final BatchingStrategy _batchingStrategy;
  final StreamyHttpService _delegate;
  final Random _random;

  BatchingHttpService(this._batchUrl, this._method, this._headers,
      this._batchingStrategy, this._delegate, {Function onBatchStrategyError,
      Random random}) :
      _random = random {
    _batchingStrategy.batches.listen(_internalSend,
        onError: onBatchStrategyError);
  }

  Future<StreamyHttpResponse> send(StreamyHttpRequest request) {
    var completer = new Completer<StreamyHttpResponse>();
    _responseCompleter[request] = completer;
    _batchingStrategy.add(request);
    return completer.future;
  }

  void _internalSend(dynamic whatToSend) {
    if (whatToSend is! StreamyHttpRequest &&
        whatToSend is! Batch) {
      throw new ArgumentError('Unsupported type ${whatToSend.runtimeType}');
    }
    if (whatToSend is StreamyHttpRequest) {
      _sendSingleRequest(whatToSend);
    }
    if (whatToSend is Batch) {
      _sendBatch(whatToSend);
    }
  }

  void _sendSingleRequest(StreamyHttpRequest request) {
    var completer = _responseCompleter[request];
    _delegate.send(request)
      .then(completer.complete, onError: completer.completeError);
  }

  void _sendBatch(Batch batch) {
    var multipartReq = new StreamyHttpRequest.multipart(_batchUrl, _method,
        _headers, batch.onCancel, batch.requests, random: _random);
    _delegate.send(multipartReq)
      .then((StreamyHttpResponse multipartResp) {
        var parts = multipartResp.splitMultipart();
        for (List pair in zip([batch.requests, parts])) {
          StreamyHttpRequest req = pair[0];
          StreamyHttpResponse resp = pair[1];
          _responseCompleter[req].complete(resp);
        }
        batch.done(multipartResp);
      });
  }
}
