part of streamy.mixologist;

class Config {
  String output;
  String libraryName;
  String className;
  
  List<String> paths = [];
  List<String> mixins = [];
}

Config parseConfig(Map data) {
  var missing = ['output', 'library', 'class', 'paths', 'mixins']
    .where((key) => !data.containsKey(key));
  if (missing.isNotEmpty) {
    throw new Exception('Mixologist YAML configuration missing keys: $missing');
  }
  
  return new Config()
    ..output = data['output']
    ..libraryName = data['library']
    ..className = data['class']
    ..paths.addAll(data['paths'])
    ..mixins.addAll(data['mixins']);
}
