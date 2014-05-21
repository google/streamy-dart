part of streamy.runtime;

/**
 * A [JsonListener] that parses Json into Streamy-compatible structures.
 *
 * Currently, this means that it builds [Observable] data types.
 */
class StreamyBuildJsonListener extends BuildJsonListener {
  
  void beginObject() {
    super.beginObject();
    currentContainer = new ObservableMap();
  }
  
  void beginArray() {
    super.beginArray();
    currentContainer = new ObservableList();
  }
}

dynamic jsonParse(String json) {
  var listener = new StreamyBuildJsonListener();
  new JsonParser(json, listener).parse();
  return listener.result;
}
