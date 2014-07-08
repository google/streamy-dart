library streamy.generator;

import 'dart:async';
import 'dart:convert';
import 'dart:io' as io;
import 'package:analyzer/analyzer.dart' as analyzer;
import 'package:mustache/mustache.dart' as mustache;
import 'package:quiver/strings.dart' as strings;
import 'package:yaml/yaml.dart' as yaml;
import 'package:path/path.dart' as path;

part 'generator/ast.dart';
part 'generator/config.dart';
part 'generator/dart.dart';
part 'generator/discovery.dart';
part 'generator/default.dart';
part 'generator/service.dart';
part 'generator/emitter.dart';
part 'generator/util.dart';

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

    var packageDirPath = '${outputDir.path}/${packageName}';
    var libDirPath = '${packageDirPath}/lib';
    new io.Directory(libDirPath).createSync(recursive: true);
    var basePath = '${libDirPath}/${client.config.outputPrefix}';

    _maybeOutput(DartFile dartFile, String suffix) {
      if (dartFile == null) return new Future.value();
      var fileName = '${client.config.outputPrefix}${suffix}.dart';
      var file = new io.File(path.join(libDirPath, fileName));
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
