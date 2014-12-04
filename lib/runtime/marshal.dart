part of streamy.runtime;

void marshalToString(List<String> fields, Map data) {
  fields
    .where(data.containsKey)
    .forEach((key) {
      data[key] = marshalDataToString(data[key]);
    });
}

marshalDataToString(data) {
  if (data == null) {
    return null;
  } else if (data is List) {
    return new ObservableList.from(data.map(marshalDataToString));
  } else {
    return data.toString();
  }
}

void unmarshalInt64s(List<String> fields, Map data) {
  fields
    .where(data.containsKey)
    .forEach((key) {
      data[key] = unmarshalInt64Data(data[key]);
    });
}

unmarshalInt64Data(data) {
  if (data == null) {
    return null;
  } else if (data is List) {
    return new ObservableList.from(data.map(unmarshalInt64Data));
  } else if (data is String) {
    return Int64.parseInt(data);
  } else {
    return new Int64(data);
  }
}

void unmarshalDoubles(List<String> fields, Map data) {
  fields
    .where(data.containsKey)
    .forEach((key) {
      data[key] = unmarshalDoubleData(data[key]);
    });
}

unmarshalDoubleData(data) {
  if (data == null) {
    return null;
  } else if (data is List) {
    return new ObservableList.from(data.map(unmarshalDoubleData));
  } else if (data is String) {
    return double.parse(data);
  } else {
    return data;
  }
}

void handleEntities(Map handlers, Map data, bool marshal) {
  handlers
    .keys
    .where(data.containsKey)
    .forEach((key) {
      data[key] = handleEntityData(data[key], handlers[key], marshal);
    });
}

handleEntityData(data, handler, bool marshal) {
  if (data == null) {
    return null;
  } else if (data is List) {
    return new ObservableList.from(
        data.map((v) => handleEntityData(v, handler, marshal)));
  } else {
    return handler(data, marshal);
  }
}

void unmarshalEntities(Map marshalledProperties, Map data) {
  marshalledProperties.keys.where(data.containsKey).forEach((key) {
    data[key] = unmarshalEntityData(marshalledProperties[key], data[key]);
  });
}

unmarshalEntityData(unmarshaller(dynamic), data) {
  if (data == null) {
    return null;
  } else if (data is List) {
    return new ObservableList.from(
        data.map((v) => unmarshalEntityData(unmarshaller, v)));
  } else {
    return unmarshaller(data);
  }
}
