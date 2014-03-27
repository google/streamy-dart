library streamy.trait.base.map;

import 'package:streamy/streamy.dart' as streamy;

class MapBase implements streamy.DynamicAccess {
  var _map;
  
  Iterable<String> get keys => _map.keys;
  bool containsKey(String key) => _map.containsKey(key);
  operator[](String key) => _map[key];
  operator[]=(String key, value) {
    _map[key] = value;
  }
  remove(String key) => _map.remove(key);
}

Map getMap(MapBase entity) => entity._map;
void setMap(MapBase entity, map) {
  entity._map = map;
}
