part of streamy.runtime;

class ActiveRequest {
  final sink;
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
    if (!seenPrimary && authority == response.PRIMARY) {
      authority = Authority.SECONDARY;
    }
    sink.add(new Response(response.entity, response.source, response.ts,
        authority: response.authority));
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

class MultiplexerCacheHitEvent implements TraceEvent {
  factory MultiplexerCacheHitEvent() => const MultiplexerCacheHitEvent._private();

  const MultiplexerCacheHitEvent._private();

  String toString() => 'streamy.multiplexer.cache.hit';
}

class MultiplexerCacheMissEvent implements TraceEvent {
  factory MultiplexerCacheMissEvent() => const MultiplexerCacheMissEvent._private();

  const MultiplexerCacheMissEvent._private();

  String toString() => 'streamy.multiplexer.cache.miss';
}

class MultiplexerRpcSendEvent implements TraceEvent {
  factory MultiplexerRpcSendEvent() => const MultiplexerRpcSendEvent._private();

  const MultiplexerRpcSendEvent._private();

  String toString() => 'streamy.multiplexer.rpc.send';
}

class MultiplexerRpcCancelEvent implements TraceEvent {
  factory MultiplexerRpcCancelEvent() => const MultiplexerRpcCancelEvent._private();

  const MultiplexerRpcCancelEvent._private();

  String toString() => 'streamy.multiplexer.rpc.cancel';
}
