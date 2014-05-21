part of streamy.generator;

const SPLIT_LEVEL_NONE = 1;
const SPLIT_LEVEL_PARTS = 2;
const SPLIT_LEVEL_LIBS = 3;

class SendParam {
  final String name;
  final TypeRef typeRef;
  final dynamic defaultValue;
  
  SendParam(this.name, this.typeRef, this.defaultValue);
}

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
  bool patch = true;
  bool removers = true;
  bool known = false;
  bool global = false;
  
  List<SendParam> sendParams = [];
  
  Config();
}

void _die(String message) => throw new Exception(message);

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
  
  if (data.containsKey('options')) {
    var options = data['options'];
    if (options is! Map) {
      _die('Invalid value for: options.');
    }
    if (options.containsKey('clone')) {
      config.clone = options['clone'];
    }
    if (options.containsKey('removers')) {
      config.removers = options['removers'];
    }
    if (options.containsKey('known')) {
      config.known = options['known'];
    }
    if (options.containsKey('global')) {
      config.global = options['global'];
    }
    if (options.containsKey('patch')) {
      config.patch = options['patch'];
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
  
  if (data.containsKey('request')) {
    var request = data['request'];
    if (request is! Map) {
      _die('Invalid value for: request.');
    }
    if (request.containsKey('sendParams')) {
      config.sendParams.addAll(request['sendParams']
        .keys
        .map((name) {
          var param = request['sendParams'][name];
          var type = const TypeRef.any();
          var defaultValue = null;
          var parseDefaultValue;
          if (param is Map) {
            if (param.containsKey('type')) {
              switch (param['type']) {
                case 'string':
                  type = const TypeRef.string();
                  break;
                case 'int':
                  type = const TypeRef.integer();
                  parseDefaultValue = (dv) => int.parse(dv.toString());
                  break;
                case 'boolean':
                  parseDefaultValue = (dv) => dv.toString() == 'true';
                  break;
                default:
                  _die('Unsupported sendParam type: ${param["type"]}');
                  break;
                
              }
            }
            if (param.containsKey('default')) {
              defaultValue = parseDefaultValue(param['default']);
            }
            return new SendParam(name, type, defaultValue);
          }
        }));
    }
  }
  
  return config;
}

Future<String> _fileReader(String path) => new io.File(path).readAsString();

Future<Api> apiFromConfig(
  Config config, {String pathPrefix: '', fileReader: _fileReader}) {
  if (config.discoveryFile != null) {
    var addendum = new Future.value('{}');
    var discovery = fileReader(pathPrefix + config.discoveryFile);
    if (config.addendumFile != null) {
      addendum = fileReader(pathPrefix + config.addendumFile);
    }
    return Future
      .wait([discovery, addendum])
      .then((data) => data.map(json.parse).toList(growable: false))
      .then((data) => parseDiscovery(data[0], data[1]));
  } else {
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
  final io.Directory path;
  
  FileTemplateLoader(String path) : path = new io.Directory(path).absolute;
  
  Future<mustache.Template> load(String name) {
    var f = new io.File("${path.path}/$name.mustache");
    if (!f.existsSync()) {
      return null;
    }
    return f.readAsString().then(mustache.parse);
  }
}
