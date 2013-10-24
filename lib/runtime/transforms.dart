part of streamy.runtime;

/// An [EventTransformer] that de-duplicates entities. This will cause
/// metadata about the entity (Entity.streamy) to be inaccurate, but will
/// prevent multiple values from being published on [Stream]s when core [Entity]
/// data has not changed.
class EntityDedupTransformer extends EventTransformer {
  var _last = null;

  EntityDedupTransformer() : super();

  void handleData(Response<T> response, EventSink<T> sink, Trace trace) {
    if (!Entity.deepEquals(response.entity, _last)) {
      sink.add(response);
    }
    _last = response.entity;
  }
}

/// An [EventTransformer] that closes the stream after the RPC reply is
/// received.
class OneShotRequestTransformer extends EventTransformer {

  const OneShotRequestTransformer() : super();

  void handleData(Response response, EventSink<Response> sink, Trace trace) {
    sink.add(response);
    if (response.source == Source.RPC) {
      sink.close();
    }
  }
}

/// An [EventTransformer] that clones frozen entities, to make them mutable.
class MutableTransformer extends EventTransformer {

  const MutableTransformer() : super();

  void handleData(Response response, EventSink<Response> sink, Trace trace) {
    if (response.entity.isFrozen) {
      sink.add(new Response(response.entity.clone(), response.source, response.ts));
    } else {
      sink.add(response);
    }
  }
}

/// An [EventTransformer] that traces user callback timings. Should be the last
/// transformer before user code.
class UserCallbackTracingTransformer extends EventTransformer {

  var _openCallbacks = 0;
  var _closed = false;

  UserCallbackTracingTransformer() : super();

  void handleData(Response response, EventSink<Response> sink, Trace trace) {
    trace.record(const UserCallbackQueuedEvent());
    _openCallbacks++;
    _runZonedWithOnDone(() => sink.add(response), () {
      trace.record(const UserCallbackDoneEvent());
      _openCallbacks--;
      if (_openCallbacks == 0 && _closed) {
        trace.record(const RequestOverEvent());
      }
    });
  }

  void handleError(error, EventSink<Response> sink, Trace trace) {
    trace.record(const UserCallbackQueuedEvent());
    _openCallbacks++;
    _runZonedWithOnDone(() => sink.addError(error), () {
      trace.record(const UserCallbackDoneEvent());
      _openCallbacks--;
      if (_openCallbacks == 0 && _closed) {
        trace.record(const RequestOverEvent());
      }
    });
  }

  void handleDone(EventSink<Response> sink, Trace trace) {
    _closed = true;
    if (_openCallbacks == 0) {
      trace.record(const RequestOverEvent());
    }
  }

  static bool traceDonePredicate(TraceEvent event) => event is RequestOverEvent;
}

/// Fired when the user callback of a response is queued.
class UserCallbackQueuedEvent implements TraceEvent {
  const UserCallbackQueuedEvent();

  String toString() => 'streamy.userCallback.start';
}

/// Fired when the user callback of a response completes.
class UserCallbackDoneEvent implements TraceEvent {
  const UserCallbackDoneEvent();

  String toString() => 'streamy.userCallback.done';
}

/// Fired when the response [Stream] has terminated.
class RequestOverEvent implements TraceEvent {
  const RequestOverEvent();

  String toString() => 'streamy.requestOver';
}

/// An operation that can be applied during request processing. A [Transformer]
/// has the opportunity to modify both the [Request] and [Response], as well as
/// fulfill [Request]s itself.
abstract class Transformer {

  Stream<Response> bind(Request request, RequestHandler delegate, Trace trace);
}

/// A [Transformer] that's implemented by overriding a number of methods for
/// handling different events.
abstract class EventTransformer implements Transformer {

  const EventTransformer();

  Stream<Response> bind(Request request, RequestHandler delegate, Trace trace) {
    var sub;
    var output = new StreamController<Response>(onCancel: () {
      sub.cancel();
      handleCancel(trace);
    });
    var input = delegate.handle(handleRequest(request, output, trace), trace);
    sub = input.listen((response) {
      handleData(response, output, trace);
      if (output.isClosed) {
        sub.cancel();
      }
    })..onError((error) {
      handleError(error, output, trace);
      if (output.isClosed) {
        sub.cancel();
      }
    })..onDone(() {
      handleDone(output, trace);
      if (!output.isClosed) {
        output.close();
      }
    });
    return output.stream;
  }

  Request handleRequest(Request request, EventSink<Response> sink, Trace trace) => request;

  void handleData(Response response, EventSink<Response> sink, Trace trace) => sink.add(response);
  void handleError(error, EventSink<Response> sink, Trace trace) => sink.addError(error);
  void handleDone(EventSink<Response> sink, Trace trace) {
    sink.close();
  }
  void handleCancel(Trace trace) {}
}

/// A factory method for constructing a new [Transformer]. For stateless [Transformer]s, this can
/// be optimized to return a const-constructed [Transformer].
typedef Transformer TransformerFactory();

class TransformingRequestHandler extends RequestHandler {
  final RequestHandler delegate;
  final TransformerFactory transformerFactory;

  TransformingRequestHandler(this.delegate, this.transformerFactory);

  Stream<Response> handle(Request request, Trace trace) =>
      transformerFactory().bind(request, delegate, trace);
}

/// A factory method for constructing a new [StreamTransformer]. For stateless [StreamTransformer]s,
// this can be optimized to return a const-constructed [StreamTransformer].
typedef StreamTransformer<Response, Response> StreamTransformerFactory(Request request, Trace trace);

/// A [RequestHandler] that transforms [Response] [Stream]s with a dart:async [StreamTransformer].
class DartAsyncTransformRequestHandler extends RequestHandler {
  final RequestHandler delegate;
  StreamTransformerFactory transformerFactory;

  DartAsyncTransformRequestHandler(this.delegate, this.transformerFactory);

  Stream<Response> handle(Request request, Trace trace) =>
    delegate.handle(request).transform(transformerFactory(request, trace));
}

_runZonedWithOnDone(fn, onDone) {
  // Initial count is 1 due to running 'fn'. This makes it work out
  // nicely if 'fn' itself throws an Exception.
  var asyncCount = 1;
  runZonedExperimental(() {
    try {
      fn();
    } finally {
      asyncCount--;
      if (asyncCount == 0) {
        onDone();
      }
    }
  }, onRunAsync: (callback) {
    asyncCount++;
    runAsync(() {
      try {
        callback();
      } finally {
        asyncCount--;
        if (asyncCount == 0) {
          onDone();
        }
      }
    });
  });
}
