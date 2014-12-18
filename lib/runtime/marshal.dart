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

void unmarshalInt64s(List<String> fields, Map data, {bool lazy: false}) {
  fields
    .where(data.containsKey)
    .forEach((key) {
      data[key] = unmarshalInt64Data(data[key], lazy);
    });
}

unmarshalInt64Data(data, bool lazy) {
  if (data == null) {
    return null;
  } else if (data is List) {
    if (lazy) {
      return new LazyList(new ObservableList.from(data.map(Lazy.toLazy(unmarshalInt64DataLazy))));
    } else {
      return new ObservableList.from(data.map(unmarshalInt64DataNonLazy));
    }
  } else if (data is String) {
    return Int64.parseInt(data);
  } else {
    return new Int64(data);
  }
}

unmarshalInt64DataLazy(data) => unmarshalDoubleData(data, true);
unmarshalInt64DataNonLazy(data) => unmarshalDoubleData(data, false);

void unmarshalDoubles(List<String> fields, Map data, {bool lazy: false}) {
  fields
    .where(data.containsKey)
    .forEach((key) {
      data[key] = unmarshalDoubleData(data[key], lazy);
    });
}

unmarshalDoubleData(data, bool lazy) {
  if (data == null) {
    return null;
  } else if (data is List) {
    if (lazy) {
      return new LazyList(new ObservableList.from(data.map(Lazy.toLazy(unmarshalDoubleDataLazy)))); 
    } else {
      return new ObservableList.from(data.map(unmarshalDoubleDataNonLazy));
    }
  } else if (data is String) {
    return double.parse(data);
  } else {
    return data;
  }
}

unmarshalDoubleDataLazy(data) => unmarshalDoubleData(data, true);
unmarshalDoubleDataNonLazy(data) => unmarshalDoubleData(data, false);

void handleEntities(Map handlers, Map data, bool marshal, {bool lazy: false}) {
  handlers
    .keys
    .where(data.containsKey)
    .forEach((key) {
      data[key] = handleEntityData(data[key], handlers[key], marshal, lazy);
    });
}

handleEntityData(data, handler, bool marshal, bool lazy) {
  if (data == null) {
    return null;
  } else if (data is List) {
    var unwrapper = (v) => handleEntityData(v, handler, marshaller, lazy);
    if (!lazy) {
      return new ObservableList.from(data.map(unwrapper));
    } else {
      return new LazyList(new ObservableList.from(data.map(Lazy.toLazy(unwrapper))));
    }
  } else {
    return handler(data, marshal, lazy: lazy);
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
