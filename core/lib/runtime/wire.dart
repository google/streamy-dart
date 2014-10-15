part of streamy.runtime;

abstract class Serializer {
  dynamic serialize(value);
}

class JsonSerializer implements Serializer {
  serialize(value) {
    if (value == null) {
      return null;
    } else if (value is DynamicAccess) {
      var map = <String, dynamic>{};
      for (var key in value.keys) {
        map[key] = serialize(value[key]);
      }
      return map;
    } else if (value is Int64) {
      return value.toString();
    } else if (value is List) {
      return value.map(serialize).toList();
    } else {
      return value;
    }
  }
}
