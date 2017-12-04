library streamy.generator;

import 'dart:async';
import 'dart:convert';
import 'dart:io' as io;
import 'package:mustache/mustache.dart' as mustache;
import 'package:yaml/yaml.dart' as yaml;
import 'package:path/path.dart' as path;
import 'package:streamy/generator/config.dart';
import 'package:streamy/generator/dart.dart';
import 'package:streamy/generator/discovery/discovery_parser.dart' as discovery;
import 'package:streamy/generator/emitter.dart';
import 'package:streamy/generator/ir.dart';
import 'package:streamy/generator/protobuf/protobuf_parser.dart' as proto;
import 'package:streamy/generator/template_loader.dart';
import 'package:streamy/generator/util.dart';

_clone(v) {
  if (v == null) {
    return v;
  } else if (v is Map) {
    var res = {};
    v.forEach((key, value) {
      res[key] = _clone(value);
    });
    return res;
  } else if (v is List) {
    return v.map(_clone).toList();
  }
  return v;
}

/// Generates a Streamy API client package in pub format.
Future generateStreamyClientPackage(
    io.File configFile,
    io.Directory outputDir,
    String inputFile,
    {
      String addendumFile,
      String packageName,
      String packageVersion: '0.0.0',
      String localStreamyLocation,
      String remoteStreamyLocation,
      String remoteBranch,
      String protoc,
      List<String> protocImportPaths,
      String pathPrefix: '',
      bool useLibDir: true
    }) {
  var configYaml = _clone(yaml.loadYaml(configFile.readAsStringSync()));
  if (inputFile != null || addendumFile != null) {
    augmentYaml(configYaml, inputFile, addendumFile, protocImportPaths);
  }
  var config = parseConfigOrDie(configYaml);
  var templateLoader = new DefaultTemplateLoader.defaultInstance();
  var emitterFuture = emitterFromTemplateLoader(config, templateLoader);
  var apiFuture = apiFromConfig(config,
      pathPrefix: pathPrefix,
      protoc: protoc);
  return Future.wait([emitterFuture, apiFuture]).then((List list) {
    Emitter emitter = list[0];
    Api api = list[1];
    StreamyClient client = emitter.process(api);
    if (packageName == null) {
      if (api.name != null) {
        packageName = api.name;
      } else {
        var basename = path.basename(configFile.path);
        packageName = basename.substring(0, basename.indexOf('.'));
      }
    }

    var packageDirPath = outputDir.path;
    var libDirPath = '${packageDirPath}';
    if (useLibDir) {
      libDirPath = '$libDirPath/lib';
      new io.Directory(libDirPath).createSync(recursive: true);
    }
    var basePath = '${libDirPath}/${client.config.outputPrefix}';

    _maybeOutput(DartFile dartFile, String suffix) {
      if (dartFile == null) return new Future.value();
      var fileName = '${client.config.outputPrefix}${suffix}.dart';
      var file = new io.File(path.join(libDirPath, fileName));
      new io.Directory(path.dirname(file.path)).createSync(recursive: true);
      file.writeAsStringSync(dartFile.render());
    }

    _maybeOutput(client.root, '');
    _maybeOutput(client.resources, '_resources');
    _maybeOutput(client.requests, '_requests');
    _maybeOutput(client.objects, '_objects');
    _maybeOutput(client.dispatch, '_dispatch');

    var pubspecFile = new io.File('${packageDirPath}/pubspec.yaml');
    var homepage = api.docLink != null
        ? api.docLink
        : 'https://github.com/google/streamy-dart';
    var streamyVersion = '">=${new io.File('VERSION').readAsStringSync()}"';

    if (localStreamyLocation != null && remoteStreamyLocation == null) {
      streamyVersion = '''

      path: ${localStreamyLocation}''';
    }

    if (remoteStreamyLocation != null && localStreamyLocation == null) {
      streamyVersion = '''

      git:
        url: ${remoteStreamyLocation}
        ref: ${remoteBranch}''';
    }

    return templateLoader.load('pubspec').then((mustache.Template pubspecTemplate) {
      var pubspecData = {
          'package_name': packageName,
          'version': packageVersion,
          'api_name': api.name,
          'homepage': homepage,
          'streamy_version': streamyVersion,
      };
      pubspecFile.writeAsStringSync(pubspecTemplate.renderString(pubspecData));
    });
  });
}

Future<String> _fileReader(String path) => new io.File(path).readAsString();

Future<Api> apiFromConfig(
    Config config,
    {
      String pathPrefix: '',
      fileReader: _fileReader,
      String protoc
    }) {
  if (config.discoveryFile != null) {
    return discovery.parseFromConfig(config, pathPrefix, fileReader);
  }
  if (config.service != null) {
    return proto.parseServiceFromConfig(config, pathPrefix, fileReader);
  }
  if (config.proto != null) {
    return proto.parseFromProtoConfig(config.proto, protoc);
  }
  throw new Exception('Config missing discovery, service, or proto. Parser bug?');
}

Future<Emitter> emitterFromTemplateLoader(Config config,
    TemplateLoader loader) {
  var templates = <String, mustache.Template>{};
  var futures = <Future>[];
  _TEMPLATES.forEach((name) => futures.add(loader
      .load(name)
      .then((template) {
        templates[name] = template;
      })));
  return Future
      .wait(futures)
      .then((_) => new Emitter(config, templates));
}

void augmentYaml(Map yaml, String inputFile, String addendumFile,
    List<String> protoImportPaths) {
  if (yaml.containsKey('proto')) {
    if (!yaml['proto'].containsKey('source')) {
      yaml['proto']['source'] = {};
    }
    var source = yaml['proto']['source'];
    if (inputFile == null && !source.containsKey('file')) {
      throw new Exception('Input file not specified.');
    }
    source['file'] = inputFile;
    if (protoImportPaths.isNotEmpty) {
      source['root'] = protoImportPaths;
    }
  } else {
    if (inputFile != null) {
      yaml['discovery'] = inputFile;
    } else if (!yaml.containsKey('discovery')) {
      throw new Exception('Discovery file not specified.');
    }
    if (addendumFile != null) {
      yaml['addendum'] = addendumFile;
    }
  }
}

const _TEMPLATES = const <String>[
    'lazy_resource_getter',
    'list',
    'map',
    'marshal',
    'marshal_handle',
    'marshal_mapbacked',
    'object_add_global',
    'object_clone',
    'object_ctor',
    'object_getter',
    'object_patch',
    'object_remove',
    'object_setter',
    'proto_marshaller_ctor',
    'request_clone',
    'request_ctor',
    'request_marshal_payload',
    'request_method',
    'request_param_getter',
    'request_param_setter',
    'request_remove',
    'request_send',
    'request_send_direct',
    'request_unmarshal_response',
    'root_begin_transaction',
    'root_constructor',
    'root_send',
    'root_transaction_constructor',
    'string_list',
    'string_map',
    'unmarshal',
    'unmarshal_json',
];
