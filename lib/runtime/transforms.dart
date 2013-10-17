part of streamy.runtime;

/// A [StreamTransformer] that de-duplicates entities. This will cause
/// metadata about the entity (Entity.streamy) to be inaccurate, but will
/// prevent multiple values from being published on [Stream]s when core [Entity]
/// data has not changed.
class EntityDedupTransformer<T extends Entity>
    extends StreamEventTransformer<Result<T>, Result<T>> {
  var _last;

  handleData(Result<T> result, EventSink<Result<T>> sink) {
    if (!Entity.deepEquals(result.result, _last)) {
      sink.add(result);
    }
    _last = result.result;
  }
}

/// A [StreamTransformer] that closes the stream after the RPC reply is
/// received.
class OneShotRequestTransformer<T extends Entity>
    implements StreamTransformer<Result<T>, Result<T>> {

  Stream<T> bind(Stream<T> input) {
    var sub;
    var output = new StreamController<T>(onCancel: () => sub.cancel());
    sub = input.listen((result) {
      output.add(result);
      if (result.source == 'RPC') {
        sub.cancel();
        output.close();
      }
    });
    sub
      ..onError(output.addError)
      ..onDone(output.close);
    return output.stream;
  }
}

class MutableTransformer<T extends Entity> extends StreamEventTransformer<Result<T>, Result<T>> {
  
  handleData(Result<T> result, EventSink<Result<T>> sink) {
    if (result.result.isFrozen) {
      sink.add(new Result<T>(result.result.clone(), result.source));
    } else {
      sink.add(result);
    }
  }
}

abstract class RequestStreamTransformer {
  Stream bind(Request request, Stream stream);
}

class TransformingRequestHandler extends RequestHandler {
  final RequestHandler delegate;
  final RequestStreamTransformer transformer;

  TransformingRequestHandler(this.delegate, this.transformer);

  Stream handle(Request request) =>
      transformer.bind(request, delegate.handle(request));
}

/// Represents a request that was issued, and allows listening for its completion.
class TrackedRequest {
  
  /// Request that was issued.
  final Request request;

  /// A future that completes before the first response for the request is returned
  /// (may be an error).
  final Future beforeFirstResponse;
  
  /// A future that completes when the first response for the request is returned
  /// (may be an error).
  final Future onFirstResponse;
  
  TrackedRequest._private(this.request, this.beforeFirstResponse, this.onFirstResponse);
}

/// Provides a global notification of when requests are issued and when they receive
/// their first response.
class RequestTrackingTransformer extends RequestStreamTransformer {
  
  final _controller = new StreamController<TrackedRequest>.broadcast(sync: true);
  
  Stream<TrackedRequest> get trackingStream => _controller.stream;
  
  RequestTrackingTransformer();
  
  Stream bind(Request request, Stream responseStream) {
    var sub;
    var preCallbackCompleter = new Completer.sync();
    var postCallbackCompleter = new Completer.sync();
    // Whether the input Stream was closed.
    var closed = false;
    // Whether the input Stream has seen a value.
    var sawValue = false;
    var c = new StreamController<Entity>(onCancel: () {
      sub.cancel();
      if (!postCallbackCompleter.isCompleted && !(closed && sawValue)) {
        postCallbackCompleter.complete();
      }
    });
    
    // Publish a tracking record for this request (synchronously).
    _controller.add(new TrackedRequest._private(
        request, preCallbackCompleter.future, postCallbackCompleter.future));
    
    // To be called when an event has been processed. Only on the first one, this
    // should complete the future sent on the tracking stream, indicating a response
    // has been processed.
    void done(entity, [error]) {
      if (postCallbackCompleter.isCompleted) {
        return;
      }
      if (entity != null) {
        postCallbackCompleter.complete(entity);
      } else {
        postCallbackCompleter.complete(error);
      }
    }
    
    // Subscribe to the stream. On a new value or error, publish it to the controller.
    sub = responseStream.listen((entity) {
      sawValue = true;
      if (!preCallbackCompleter.isCompleted) {
        preCallbackCompleter.complete(entity);
      }
      _runZonedWithOnDone(() {
        c.add(entity);
      }, () => done(entity));
    })..onError((error) {
      sawValue = true;
      if (!preCallbackCompleter.isCompleted) {
        preCallbackCompleter.complete(error);
      }
      _runZonedWithOnDone(() {
        c.addError(error);
      }, () => done(null, error));
    })..onDone(() {
      // If the stream completed without any results, the resulting
      // subscription cancellation will complete the competer.
      closed = true;
      c.close();
    });
    
    return c.stream;
  }
}

class ResultToEntityTransformer<T extends Entity> extends StreamEventTransformer<dynamic, T> {
  
  handleData(result, EventSink<T> sink) {
    if (result is Result) {
      sink.add(result.result);
    } else {
      sink.add(result);
    }
  }
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
