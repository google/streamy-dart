part of streamy.generator;

const SPLIT_LEVEL_NONE = 1;
const SPLIT_LEVEL_PARTS = 2;
const SPLIT_LEVEL_LIBS = 3;

class Config {
  
  String discoveryFile;
  String addendumFile;

  String serviceFile;
  
  String baseClass = 'Entity';
  String baseImport = 'package:streamy/base.dart';
  
  String importPrefix = '';
  String outputPrefix = '';
  
  int splitLevel = SPLIT_LEVEL_NONE;
  
  bool mapBackedFields = true;
  bool clone = true;
  bool removers = true;
  bool known = false;
  
  Config();
}

void _die(String message) {
  print(message);
  exit(1);
}

Config parseConfigOrDie(Map data) {
  var config = new Config();
  
  // Discovery & Service
  if (data.containsKey('discovery')) {
    config.discoveryFile = data['discovery'];
    if (data.containsKey('addendum')) {
      config.addendumFile = data['addendum'];
    }
  }
  if (data.containsKey('service')) {
    config.serviceFile = data['service'];
    if (data.containsKey('discovery')) {
      _die('Cannot specify both discovery and service.');
    }
    if (data.containsKey('addendum')) {
      _die('Cannot specify both service and addendum.');
    }
  }
  
  if (config.discoveryFile == null && config.serviceFile == null) {
    _die('Must specify either discovery or service.');
  }
  
  // Base class.
  if (!data.containsKey('base') || data['base'] is! Map) {
    _die('Missing base class section.');
  }
  var base = data['base'];
  if (!base.containsKey('class') || !base.containsKey('import')) {
    _die('Missing class or import.');
  }
  config.baseClass = base['class'];
  config.baseImport = base['import'];
  if (base.containsKey('backing')) {
    switch (base['backing']) {
      case 'map':
        config.mapBackedFields = true;
        break;
      case 'fields':
        config.mapBackedFields = false;
        break;
      default:
        _die('Invalid value for: backing');
    }
  }
  
  if (base.containsKey('options')) {
    var options = base['options'];
    if (options is! Map) {
      _die('Invalid value for: options.');
    }
    if (options.containsKey('clone')) {
      config.clone = base['clone'];
    }
    if (options.containsKey('removers')) {
      config.removers = base['removers'];
    }
    if (options.containsKey('known')) {
      config.known = base['known'];
    }
  }
  
  if (data.containsKey('output')) {
    var output = data['output'];
    if (output is! Map) {
      _die('Invalid value for: output.');
    }
    if (output.containsKey('files')) {
      switch (output['files']) {
        case 'single':
          config.splitLevel = SPLIT_LEVEL_NONE;
          break;
        case 'parts':
          config.splitLevel = SPLIT_LEVEL_PARTS;
          break;
        case 'split':
          config.splitLevel = SPLIT_LEVEL_LIBS;
          break;
        default:
          _die('Unknown value for: files.');
      }
    }
    if (output.containsKey('prefix')) {
      config.outputPrefix = output['prefix'];
    }
    if (output.containsKey('import')) {
      config.importPrefix = output['import'];
    }
  }
  
  return config;
}

Api apiFromConfig(Config config) {
  if (config.discoveryFile != null) {
    var addendum = {};
    var discovery = json.parse(
        new io.File(config.discoveryFile).readAsStringSync());
    if (config.addendumFile != null) {
      addendum = json.parse(new io.File(config.addendumFile).readAsStringSync());
    }
    return parseDiscovery(discovery, addendum);
  } else if (config.serviceFile != null) {
    _die('Handle services.');
  }
}
class TemplateLoader {
  
  factory TemplateLoader.fromDirectory(String path) {
    return new FileTemplateLoader(path);
  }
  
  Future<mustache.Template> load(String name);
}

class FileTemplateLoader implements TemplateLoader {
  final Directory path;
  
  FileTemplateLoader(String path) : path = new io.Directory(path).absolute;
  
  Future<mustache.Template> load(String name) {
    var f = new io.File("${path.path}/$name.mustache");
    if (!f.existsSync()) {
      return null;
    }
    return f.readAsString().then(mustache.parse);
  }
}
