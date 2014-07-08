part of streamy.runtime;

final _observableJsonCodec = new JsonCodec.withReviver(_observableReviver);

/// Parses JSON into [Observable] lists and maps.
dynamic jsonParse(String json) {
  return _observableJsonCodec.decode(json);
}

_observableReviver(dynamic key, dynamic value) {
  if (value is List) {
    return new ObservableList.from(value);
  } else {
    return value;
  }
}
