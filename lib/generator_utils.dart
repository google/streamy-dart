library streamy.generator.utils;

import 'dart:async';
import 'dart:io' as io;
import 'package:json/json.dart';
import 'package:streamy/generator.dart';
import 'dart:convert' as convert;

/// Generates a Streamy API client library for a given [discoveryFile] in the
/// pub package format.
Future generateStreamyClientLibrary(
    io.File discoveryFile,
    io.Directory outputDir,
    {io.File addendumFile,
    io.Directory templatesDir,
    String libVersion: '0.0.0',
    String localStreamyLocation}) {
  var json = discoveryFile.readAsStringSync(encoding: convert.UTF8);
  var discovery = new Discovery.fromJsonString(json);
  var addendumData = {};
  if (addendumFile != null) {
    addendumData = parse(addendumFile.readAsStringSync());
  }

  var libDir = new io.Directory('${outputDir.path}/lib');
  libDir.createSync();

  var basePath = '${libDir.path}/${discovery.name}';
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
      addendumData: addendumData));

  var pubspecFile = new io.File('${outputDir.path}/pubspec.yaml');

  var homepage = discovery.documentationLink != null
      ? discovery.documentationLink
      : 'https://github.com/google/streamy-dart';

  var streamyVersion = '">=0.0.7"';
  if (localStreamyLocation != null) {
    streamyVersion = '''

    path: ${localStreamyLocation}''';
  }

  pubspecFile.writeAsString(
'''name: ${discovery.name}_${discovery.version}
version: ${libVersion}
description: >
  API client library for ${discovery.name} for use with Streamy RPC framework.
authors:
- Streamy
homepage: ${homepage}
environment:
  sdk: '>=1.0.0'
dependencies:
  browser: any
  args: ">=0.9.0"
  meta: ">=0.8.8"
  fixnum: ">=0.9.0"
  json: ">=0.9.0"
  observe: ">=0.9.1"
  streamy: ${streamyVersion}
  quiver: ">=0.14.0"
'''
  );

  return Future.wait([
    rootOut.close(),
    resourceOut.close(),
    requestOut.close(),
    objectOut.close(),
  ]);
}
