part of streamy.runtime;

class ActiveRequest {
  final sink;
  final trace;
  Stream<Response> get stream => sink.stream;
  var seenPrimary = false;

  ActiveRequest({onCancel})
      : sink = new StreamController<Response>(onCancel: onCancel);

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

/// The multiplexer holds client streams open.
class MultiplexingRequestHandler extends RequestHandler {

  final RequestHandler delegate;
  final map = new SetMultimap<Request, ActiveRequest>();

  MultiplexingRequestHandler(this.delegate);

  Stream<Response> handle(Request request, Trace trace) {
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
