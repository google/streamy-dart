part of streamy.runtime;

/// A [StreamTransformer] that de-duplicates entities. This will cause
/// metadata about the entity (Entity.streamy) to be inaccurate, but will
/// prevent multiple values from being published on [Stream]s when core [Entity]
/// data has not changed.
class EntityDedupTransformer<T extends Entity>
    extends StreamEventTransformer<T, T> {
  var _last = null;

  handleData(T data, EventSink<T> sink) {
    if (data != _last) {
      sink.add(data);
    }
    _last = data;
  }
}

/// A [StreamTransformer] that closes the stream after the RPC reply is
/// received.
class OneShotRequestTransformer<T extends Entity>
    implements StreamTransformer<T, T> {

  Stream<T> bind(Stream<T> input) {
    var output = new StreamController<T>();
    var sub;
    sub = input.listen((e) {
      output.add(e);
      if (e.streamy.source == 'RPC') {
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
  
  /// A future that completes when the first response for the request is returned
  /// (may be an error).
  final Future<Entity> whenComplete;
  
  TrackedRequest._private(this.request, this.whenComplete);
}

/// Provides a global notification of when requests are issued and when they receive
/// their first response.
class RequestTrackingTransformer extends RequestStreamTransformer {
  
  final _controller = new StreamController<TrackedRequest>.broadcast(sync: true);
  
  Stream<TrackedRequest> get trackingStream => _controller.stream;
  
  RequestTrackingTransformer();
  
  Stream bind(Request request, Stream responseStream) {
    var sub;
    
    var c = new StreamController<Entity>(onCancel: () => sub.cancel());
    var completer = new Completer<Entity>();
    
    // Publish a tracking record for this request (synchronously).
    _controller.add(new TrackedRequest._private(request, completer.future));
    
    var first = true;
    
    // To be called when an event has been processed. Only on the first one, this
    // should complete the future sent on the tracking stream, indicating a response
    // has been processed.
    void done(entity, [error]) {
      if (!first) {
        return;
      }
      first = false;
      print("completing future");
      if (entity != null) {
        completer.complete(entity);
      } else {
        completer.completeError(error);
      }
      print("done completing future");
    }
    
    // Subscribe to the stream. On a new value or error, publish it to the controller.
    sub = responseStream.listen((entity) {
      runZonedExperimental(() {
        c.add(entity);
      }, onDone: () => done(entity));
    })..onError((error) {
      runZonedExperimental(() {
        c.addError(error);
      }, onDone: () => done(null, error));
    })..onDone(() {
      c.close();
    });
    
    return c.stream;
  }
}
