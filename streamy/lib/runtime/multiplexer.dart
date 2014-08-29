part of streamy.runtime;

class ActiveRequest {
  final StreamController<Response> sink;
  final trace;
  bool seenPrimary = false;

  ActiveRequest({onCancel})
      : sink = new StreamController<Response>(onCancel: onCancel);

  Stream<Response> get stream => sink.stream;

  void addPrimary(Response response) {
    sink.add(response);
    if (response.authority == Authority.PRIMARY) {
      seenPrimary = true;
    }
  }

  /// Secondary responses come from other requests. Should one be of primary
  /// authority, it is degraded to secondary if this request has not gotten its
  /// primary response yet.
  void addSecondary(Response response) {
    var authority = response.authority;
    if (!seenPrimary && authority == Authority.PRIMARY) {
      authority = Authority.SECONDARY;
    }
    sink.add(new Response(response.entity, response.source, response.ts,
        authority: authority));
  }
}

/// Holds all cachable [Stream]s open after the delegated request completes.
/// When a future [Request] is made which matches an open request, the
/// [Response] is sent on that stream as well. Thus, clients that hold [Stream]s
/// open after receiving the initial [Response] can be informed of future
/// updates or changes.
///
/// It is possible that [Response]s from other [Request]s can arrive prior to
/// the primary [Response] for the original [Request]. If this happens, any
/// responses with PRIMARY authority delivered to other active [Stream]s will be
/// downgraded to SECONDARY authority, until the primary response is received.
class MultiplexingRequestHandler extends RequestHandler {

  final RequestHandler delegate;
  final map = new SetMultimap<Request, ActiveRequest>();

  MultiplexingRequestHandler(this.delegate);

  Stream<Response> handle(HttpRequest request, Trace trace) {
    if (!request.isCachable) {
      return delegate.handle(request, trace);
    }
    var key = request.cacheKey();
    var sub;
    var active;

    active = new ActiveRequest(onCancel: () {
      if (sub != null) {
        sub.cancel();
      }
      map.remove(key, active);
    });
    sub = delegate.handle(request, trace).listen((resp) {
      active.addPrimary(resp);
      map[key]
        .where((a) => a != active)
        .forEach((a) => a.addSecondary(resp));
    })..onError(active.sink.addError)..onDone(() {
      sub = null;
    });

    map.add(key, active);
    return active.stream;
  }
}
