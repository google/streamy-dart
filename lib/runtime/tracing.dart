part of streamy.runtime;

/// An event that occurs during the processing of a particular request. Can be a const singleton
/// instance or a subclass which contains more data about the event.
abstract class TraceEvent {
  String toString();
}

/// A trace for a particular request. Essentially a sink for [TraceEvent]s.
abstract class Trace {
  void add(TraceEvent event);
  void done();
}

/// A tracing strategy that creates [Trace]s for [Request]s. Supplied by the user during the
/// construction of [Root]s.
abstract class Tracer {
  Trace trace(Request request);
}

class NoopTrace implements Trace {
  const NoopTrace();

  void add(TraceEvent _) {}
  void done();
}

/// A [Tracer] that drops [TraceEvent]s on the floor.
class NoopTracer implements Tracer {
  const NoopTracer();

  Trace trace(Request request) => const NoopTrace();
}

/// A [Request] that's being traced, along with a [Stream] of events.
class TracedRequest {
  final Request request;
  final Stream<TraceEvent> events;

  TracedRequest(this.request, this.events);
}

class _StreamTrace implements Trace {
  var _controller = new StreamController<TraceEvent>.broadcast(sync: true);

  void add(TraceEvent event) {
    _controller.add(event);
  }
  
  void done() {
    _controller.done();
  }

  Stream<TraceEvent> get events => _controller.stream;
}

/// A [Tracer] which reports [TracedRequest]s on a [Stream], allowing subscription to their
/// [TraceEvent]s.
class StreamTracer implements Tracer {
  var _controller = new StreamController<TracedRequest>.broadcast(sync: true);

  Trace trace(Request request) {
    var trace = new _StreamTrace();
    _controller.add(new TracedRequest(request, trace.events));
    return trace;
  }
}
