part of streamy.runtime;

final _observableJsonCodec = new JsonCodec.withReviver(_observableReviver);

/// Parses JSON into [Observable] lists and maps.
dynamic jsonParse(String json, [Trace trace = const NoopTrace()]) {
  trace.record(new JsonParseStartEvent());
  var result = _observableJsonCodec.decode(json);
  trace.record(new JsonParseEndEvent());
  return result;
}

_observableReviver(dynamic key, dynamic value) {
  if (value is List) {
    return new ObservableList.from(value);
  } else {
    return value;
  }
}
