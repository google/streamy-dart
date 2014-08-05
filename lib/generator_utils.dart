library streamy.generator.utils;

import 'dart:async';
import 'dart:convert';
import 'dart:io' as io;
import 'package:streamy/generator.dart';
import 'dart:convert' as convert;
import 'package:mustache/mustache.dart' as mus;

/// Generates a Streamy API client library for a given [discoveryFile] in the
/// pub package format.
Future generateStreamyClientLibrary(
    io.File discoveryFile,
    io.Directory outputDir,
    {io.File addendumFile,
    io.Directory templatesDir,
    String fileName,
    String libVersion: '0.0.0',
    String localStreamyLocation,
    String remoteStreamyLocation,
    String remoteBranch}) {
  var json = discoveryFile.readAsStringSync(encoding: convert.UTF8);
  var addendumData = {};
  if (addendumFile != null) {
    addendumData = JSON.decode(addendumFile.readAsStringSync());
  }
  var discovery = new Discovery.fromJsonString(json, addendumData: addendumData);
  if (fileName == null) {
    fileName = discovery.name;
  }

  var libDirPath = '${outputDir.path}/lib';
  new io.Directory(libDirPath).createSync(recursive: true);
  var basePath = '${libDirPath}/$fileName';
  var rootOut = new io.File('${basePath}.dart').openWrite();
  var resourceOut = new io.File('${basePath}_resources.dart').openWrite();
  var requestOut = new io.File('${basePath}_requests.dart').openWrite();
  var objectOut = new io.File('${basePath}_objects.dart').openWrite();

  var templateProvider = templatesDir != null
      ? new DefaultTemplateProvider(templatesDir.path)
      : new DefaultTemplateProvider.defaultInstance();

  emitCode(new EmitterConfig(
      discovery,
      templateProvider,
      rootOut,
      resourceOut,
      requestOut,
      objectOut,
      addendumData: addendumData,
      fileName: fileName));

  var pubspecFile = new io.File('${outputDir.path}/pubspec.yaml');

  var homepage = discovery.documentationLink != null
      ? discovery.documentationLink
      : 'https://github.com/google/streamy-dart';

  var streamyVersion = '">=0.0.7"';
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

  mus.Template pubspecTemplate = mus.parse(templateProvider['pubspec']);
  var pubspecData = {
    'package_name': '${discovery.name}_${discovery.version}',
    'version': libVersion,
    'discovery_name': discovery.name,
    'homepage': homepage,
    'streamy_version': streamyVersion,
  };
  pubspecFile.writeAsStringSync(
      pubspecTemplate.renderString(pubspecData, htmlEscapeValues: false));

  return Future.wait([
    rootOut.close(),
    resourceOut.close(),
    requestOut.close(),
    objectOut.close(),
  ]);
}
