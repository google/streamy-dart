part of streamy.runtime;

typedef bool StreamTraceOverIndicator(TraceEvent event);

/// An event that occurs during the processing of a particular request. Can be a const singleton
/// instance or a subclass which contains more data about the event.
abstract class TraceEvent {
  String toString();
}

/// Indicates the start of JSON parsing.
class JsonParseStartEvent extends TraceEvent {
  String toString() => "streamy.json.start";
}

/// Indicates the end of JSON parsing.
class JsonParseEndEvent extends TraceEvent {
  String toString() => "streamy.json.end";
}

/// Indicates the start of deserialization.
class DeserializationStartEvent extends TraceEvent {
  int size;

  DeserializationStartEvent(this.size);
  String toString() => "streamy.deserialization.start($size)";
}

/// Indicates the end of deserialization.
class DeserializationEndEvent extends TraceEvent {
  String toString() => "streamy.deserialization.end";
}

/// A trace for a particular request. Essentially a sink for [TraceEvent]s.
abstract class Trace {
  void record(TraceEvent event);
}

/// A tracing strategy that creates [Trace]s for [Request]s. Supplied by the user during the
/// construction of [Root]s.
abstract class Tracer {
  Trace trace(Request request);
}

class NoopTrace implements Trace {
  const NoopTrace();

  void record(TraceEvent _) {}
}

/// Logs all traces into an in-memory list.
class LoggingTrace implements Trace {
  final List<TraceEvent> log = <TraceEvent>[];

  void record(TraceEvent evt) {
    log.add(evt);
  }
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
  StreamTraceOverIndicator traceOverPredicate;

  _StreamTrace(this.traceOverPredicate);

  void record(TraceEvent event) {
    if (_controller.isClosed) {
      return;
    }
    _controller.add(event);
    if (traceOverPredicate(event)) {
      _controller.close();
    }
  }

  Stream<TraceEvent> get events => _controller.stream;
}

/// A [Tracer] which reports [TracedRequest]s on a [Stream], allowing subscription to their
/// [TraceEvent]s.
class StreamTracer implements Tracer {
  var _controller = new StreamController<TracedRequest>.broadcast(sync: true);
  StreamTraceOverIndicator traceOverPredicate;

  StreamTracer(this.traceOverPredicate);

  Trace trace(Request request) {
    var trace = new _StreamTrace(traceOverPredicate);
    _controller.add(new TracedRequest(request, trace.events));
    return trace;
  }

  Stream<TracedRequest> get requests => _controller.stream;
}
