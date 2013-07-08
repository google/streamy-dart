part of streamy.runtime;

/// A [StreamTransformer] that de-duplicates entities. This will cause
/// metadata about the entity (Entity.streamy) to be inaccurate, but will
/// prevent multiple values from being published on [Stream]s when core [Entity]
/// data has not changed.
class EntityDedupTransformer extends StreamEventTransformer<Entity, Entity> {
  var _last = null;

  handleData(Entity data, EventSink<Entity> sink) {
    if (data != _last) {
      sink.add(data);
    }
    _last = data;
  }
}

/// A [StreamTransformer] that closes the stream after the RPC reply is
/// received.
class OneShotRequestTransformer implements StreamTransformer<Entity, Entity> {

  Stream<Entity> bind(Stream<Entity> input) {
    var output = new StreamController<Entity>();
    var sub;
    sub = input.listen((e) {
      output.add(e);
      if (e.streamy.source == "RPC") {
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