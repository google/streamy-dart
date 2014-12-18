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

/// Marshals a given [object] to a value that can be fed to a [JsonEncoder].
/// Turns entities into plain maps where keys are entity property names and
/// values are recursively marshalled via this method. Encodes [Int64] and
/// `double` as `String` to preserve precision. Leaves other types intact.
// TODO(yjbanov): consider using JsonEncoder with toEncodable instead
jsonMarshal(dynamic object) {
  if (object is List) {
    var len = object.length;
    var list = new List(len);
    for (int i = 0; i < len; i++) {
      list[i] = jsonMarshal(object[i]);
    }
    return list;
  } else if (object is Map) {
    final ret = {};
    object.forEach((k, v) {
      ret[k] = jsonMarshal(v);
    });
    return ret;
  } else if (object is Int64) {
    return object.toString();
  } else if (object == null || object is num || object is bool ||
      object is String) {
    return object;
  } else {
    throw new ArgumentError('Unable to marshal type ${object.runtimeType}');
  }
}
