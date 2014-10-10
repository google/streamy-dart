library streamy.generator.config;

import 'dart:async';
import 'dart:io' as io;
import 'package:streamy/generator/ir.dart';

const SPLIT_LEVEL_NONE = 1;
const SPLIT_LEVEL_PARTS = 2;
const SPLIT_LEVEL_LIBS = 3;

class SendParam {
  final String name;
  final TypeRef typeRef;
  final dynamic defaultValue;
  
  SendParam(this.name, this.typeRef, this.defaultValue);
}

class ServiceConfig {
  final String name;
  final List<ServiceInput> inputs = [];
  
  ServiceConfig(this.name);
}

class ServiceInput {
  final String importPath;
  final String filePath;
  
  ServiceInput(this.importPath, this.filePath);
}

class ProtoConfig {
  final String name;
  final String sourceFile;
  final String root;
  final String servicePath;
  
  /// Map of import path to import aliases.
  final depsByImport = <String, ProtoDependency>{};
  final depsByPackage = <String, ProtoDependency>{};
  final orderedImports = <String>[];
  
  ProtoConfig(this.name, this.sourceFile, this.root, this.servicePath);
  
  List<String> orderImported(Iterable<String> imports) => imports
    .where(orderedImports.contains)
    .toList()
    ..sort((a, b) {
      var apos = orderedImports.indexOf(a);
      var bpos = orderedImports.indexOf(b);
      if (apos == -1 || bpos == -1) {
      }
      return Comparable.compare(apos, bpos);
    });
}

class ProtoDependency {
  final String prefix;
  final String importPackage;
  final String protoPackage;
  
  ProtoDependency(this.prefix, this.importPackage, this.protoPackage);
}

class Config {
  
  String discoveryFile;
  String addendumFile;

  ServiceConfig service;
  ProtoConfig proto;

  String baseClass = 'Entity';
  String baseImport = 'package:streamy/base.dart';
  
  String importPrefix = '';
  String outputPrefix = '';
  
  int splitLevel = SPLIT_LEVEL_NONE;

  /// Indicates whether to generate marshallers
  bool generateMarshallers = true;
  /// Indicates whether to generate API root, resource and request objects
  bool generateApi = true;

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
    var service = data['service'];
    if (!service.containsKey('name')) {
      _die('Missing service name.');
    }
    if (!service.containsKey('source') || service['source'] is! List) {
      _die('Missing service source(s).');
    }
    config.service = new ServiceConfig(service['name']);
    config.service.inputs.addAll(service['source'].map((src) {
      if (!src.containsKey('import')) {
        _die('Missing service source import.');
      }
      if (!src.containsKey('file')) {
        _die('Missing service source file.');
      }
      return new ServiceInput(src['import'], src['file']);
    }));
    if (data.containsKey('discovery')) {
      _die('Cannot specify both discovery and service.');
    }
    if (data.containsKey('addendum')) {
      _die('Cannot specify both service and addendum.');
    }
  }
  if (data.containsKey('proto')) {
    var proto = data['proto'];
    if (!proto.containsKey('name')) {
      _die('Missing proto api name.');
    }
    if (!proto.containsKey('source')) {
      _die('Missing proto source.');
    }
    var servicePath = '${proto['name']}/';
    if (proto.containsKey('servicePath')) {
      servicePath = proto['servicePath'];
    }
    if (servicePath == null) {
      servicePath = '';
    }
    var source = proto['source'];
    if (!source.containsKey('file')) {
      _die('Missing proto source file.');
    }
    if (!source.containsKey('root')) {
      _die('Missing proto root.');
    }
    config.proto = new ProtoConfig(proto['name'], source['file'],
        source['root'], servicePath);
    if (proto.containsKey('dependencies')) {
      var deps = proto['dependencies'];
      deps.forEach((prefix, depData) {
        var importPackage = depData['import'];
        var protoPackage = depData['package'];
        var dep = new ProtoDependency(prefix, importPackage, protoPackage);
        if (config.proto.depsByImport.containsKey(importPackage)) {
          _die('Double import of Dart package: $importPackage.');
        }
        if (config.proto.depsByPackage.containsKey(protoPackage)) {
          _die('Double import of proto package: $protoPackage');
        }
        config.proto
          ..depsByPackage[protoPackage] = dep
          ..depsByImport[importPackage] = dep
          ..orderedImports.add(prefix);
      });
    }
  }
  
  if (config.discoveryFile == null && config.service == null && config.proto == null) {
    _die('Must specify either discovery, service, or proto.');
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
    if (output.containsKey('generateApi')) {
      config.generateApi = output['generateApi'];
    }
    if (output.containsKey('generateMarshallers')) {
      config.generateMarshallers = output['generateMarshallers'];
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
