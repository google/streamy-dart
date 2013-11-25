part of streamy.runtime;

/// Deduplicates outgoing requests. If a second identical request is received
/// before the first returns data, this sends the delegated request's responses
/// to both requests.
class DeduplicatingRequestHandler extends RequestHandler {

  final RequestHandler delegate;
  final _sinkMap = new Map<Request, Set<StreamController<Response>>>();
  final _subMap = new Map<Request, StreamSubscription<Response>>();

  DeduplicatingRequestHandler(this.delegate);

  Stream<Response> handle(Request request, Trace trace) {
    // Non-cachable requests go straight through.
    if (!request.isCachable) {
      return delegate.handle(request, trace);
    }

    // The algorithm here is a little complex. The class fields [_sinkMap] and
    // [_subMap] hold, a list of sinks ([StreamController]s) for the individual
    // requests which are being deduplicated, and a [StreamSubscription] to the
    // deduplicated delegate request, respectively.
    //
    // Critically, these are only set for deduplicated requests which have not
    // seen the first reply. Future identical requests will not result in a
    // delegated request, but will have a [Stream] returned with its
    // [StreamController] added to the list of sinks.
    //
    // Once the first reply is received, the request is removed from the
    // [_sinkMap] and [_subMap], so future requests will result in a new
    // backend request, even if they are identical to the one already in
    // progress.
    //
    // Inside [handle], the [sink], [sinks], and [sub] fields represent the
    // sink [StreamController] for the immediate request being handled, the
    // list of sinks for all identical requests that will share the same
    // delegated request, and the subscription to the delegated request,
    // respectively. These fields are closed over by [onCancel], which handles
    // the cancellation of any individual request, and by the listener methods
    // for the delegated request which send received [Response]s to all sinks.

    var sink;
    var sinks;
    var sub;

    // Called when an individual request has its listener cancelled. Removes
    // the sink from the list of sinks, and cancels the delegated request if
    // this was the last listener.
    void onCancel() {
      sinks.remove(sink);
      if (sinks.isEmpty) {
        // Need to clean up [_sinkMap] and [_subMap]. They could be currently
        // deduping another instance of the same [request], though, so make
        // sure the [sinks] [Set] in [_sinkMap] is the same before removing
        // the [request] from both.
        if (_sinkMap.containsKey(request) && _sinkMap[request] == sinks) {
          _sinkMap.remove(request);
          _subMap.remove(request);
        }
        sub.cancel();
      }
    }

    // Determine whether a delegated request needs to occur, or whether the
    // current request can be deduplicated with an existing pending request.
    if (_sinkMap.containsKey(request)) {
      // Deduplication is possible. Retrieve the list of sinks and the
      // delegated request subscription (necessary to close over these fields).
      sinks = _sinkMap[request];
      sub = _subMap[request];

      // Add a new sink to the deduplicated request.
      sink = new StreamController<Response>(onCancel: onCancel);
      sinks.add(sink);
    } else {
      // A backend request needs to occur. Create a new set of sinks.
      sink = new StreamController<Response>(onCancel: onCancel);
      sinks = new Set<StreamController<Response>>()..add(sink);
      sinks.add(sink);
      var requestKey = request.cacheKey();

      // Until the first response is received, new requests can be deduplicated
      // with this request. When the first response is received, the list of
      // sinks is removed from the global state and thus unavailable for
      // deduplication of future requests.
      var first = true;
      void maybeFirst() {
        if (!first) {
          return;
        }
        first = false;
        _sinkMap.remove(requestKey);
        _subMap.remove(requestKey);
      }

      // Make the delegated request and fan it out to all deduplicated requests.
      sub = delegate.handle(request, trace).listen((resp) {
        maybeFirst();
        sinks.forEach((sink) => sink.add(resp));
      })..onError((err) {
        maybeFirst();
        sinks.forEach((sink) => sink.addError(err));
      })..onDone(() {
        maybeFirst();
        sinks.forEach((sink) => sink.close());
      });

      // Save the list of deduplicated requests to global state.
      _sinkMap[requestKey] = sinks;
      // Save the subscription to the delegated request (used when the last
      // deduplicated request is cancelled, to cancel the delegated request).
      _subMap[requestKey] = sub;
    }
    return sink.stream;
  }
}
