library streamy.generator;

import 'dart:async';
import 'dart:convert';
import 'dart:io' as io;
import 'package:analyzer/analyzer.dart' as analyzer;
import 'package:mustache/mustache.dart' as mustache;
import 'package:quiver/strings.dart' as strings;
import 'package:yaml/yaml.dart' as yaml;
import 'package:path/path.dart' as path;
import 'package:streamy/generator/config.dart';
import 'package:streamy/generator/dart.dart';
import 'package:streamy/generator/discovery.dart';
import 'package:streamy/generator/ir.dart';
import 'package:streamy/generator/proto.dart';
import 'package:streamy/generator/util.dart';

part 'generator/default.dart';
part 'generator/service.dart';
part 'generator/emitter.dart';

/// Generates a Streamy API client package in pub format.
Future generateStreamyClientPackage(
    io.File configFile,
    io.Directory outputDir,
    {
      String packageName,
      String packageVersion: '0.0.0',
      String localStreamyLocation,
      String remoteStreamyLocation,
      String remoteBranch
    }) {
  var configYaml = yaml.loadYaml(configFile.readAsStringSync());
  var config = parseConfigOrDie(configYaml);
  var templateLoader = new DefaultTemplateLoader.defaultInstance();
  var emitterFuture = Emitter.fromTemplateLoader(config, templateLoader);
  var apiFuture = apiFromConfig(config,
      pathPrefix: '${configFile.parent.path}${path.separator}');
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
    var libDirPath = '${packageDirPath}/lib';
    new io.Directory(libDirPath).createSync(recursive: true);
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
      pubspecFile.writeAsStringSync(
          pubspecTemplate.renderString(pubspecData, htmlEscapeValues: false));
    });
  });
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
    .then((data) => data.map(JSON.decode).toList(growable: false))
    .then((data) => parseDiscovery(data[0], data[1]));
  }
  if (config.service != null) {
    return Future
    .wait(config.service.inputs.map((input) => fileReader(pathPrefix + input.filePath)))
    .then((dataList) {
      var api = new Api(config.service.name);
      for (var i = 0; i < config.service.inputs.length; i++) {
        _parseServiceFile(api, config.service.inputs[i].importPath, analyzer.parseCompilationUnit(dataList[i]), i);
      }
      return api;
    });
  }
  if (config.proto != null) {
    return fromProto(config.proto);
  }
  throw new Exception('Config missing discovery, service, or proto. Parser bug?');
}

abstract class TemplateLoader {

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
