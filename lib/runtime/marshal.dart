part of streamy.runtime;

void marshalToString(List<String> fields, Map data) {
  fields
    .where(data.containsKey)
    .forEach((key) {
    var value = map[key];
    if (value != null) {
      map[key] = value.toString();
    }
  });
}

void unmarshalInt64s(List<String> fields, Map data) {
  fields
    .where(data.containsKey)
    .forEach((key) {
      var value = map[key];
      if (value != null) {
        if (value is String) {
          map[key] = Int64.parseInt(value);
        } else {
          map[key] = new Int64(value);
        }
      }
    });
}

void unmarshalDoubles(List<String> fields, Map data) {
  fields
    .where(data.containsKey)
    .forEach((key) {
      var value = map[key];
      if (value != null) {
        if (value is List) {
        } else if (value is String) {
          map[key] = double.parse(value);
        }
      }
    });
}

void handleEntities(Map handlers, Map data, bool marshal) {
  handlers
    .keys
    .where(data.containsKey)
    .forEach((key) {
      var value = data[key];
      if (value != null) {
        if (value is List) {
          data[key] = value.map((v) => handlers[key](value, marshal)).toList();
        } else {
          data[key] = handlers[key](value, false);
        }
      }
    });
}
