/*
 * Generates an API client.
 */
library streamy.bin.apigen;

import 'dart:io' as io;
import 'package:args/args.dart';
import 'package:quiver/strings.dart';
import 'package:quiver/pattern.dart';
import 'package:streamy/generator.dart';

io.File configFile;
io.Directory outputDir;
String packageName;
String packageVersion;
String localStreamyLocation;
String remoteStreamyLocation;
String remoteBranch;
String protocPath;

main(List<String> args) {
  parseArgs(args);
  generateStreamyClientPackage(
      configFile,
      outputDir,
      packageName: packageName,
      packageVersion: packageVersion,
      localStreamyLocation: localStreamyLocation,
      remoteStreamyLocation: remoteStreamyLocation,
      remoteBranch: remoteBranch,
      protoc: protocPath
  );
}

void parseArgs(List<String> arguments) {
  final String locataionErrorMessage = 'both local-streamy-location and '
      'remote-streamy-location simultaneously not supported';

  var errors = <String>[];
  var argp = new ArgParser();

  printUsage() {
    print(argp.getUsage());
    io.exit(1);
  }

  argp

    // Main options
    ..addOption(
      'config',
      abbr: 'c',
      help: 'Path to the configuration YAML file.',
      callback: (String value) {
        if (isBlank(value)) {
          errors.add('--config is required');
          return;
        }
        configFile = new io.File(value);
        if (!configFile.existsSync()) {
          errors.add('$value does not exist');
          return;
        }
        if (!io.FileSystemEntity.isFileSync(value)) {
          errors.add('$value does not seem to be a file');
          return;
        }
      }
    )
    ..addOption(
      'output-dir',
      abbr: 'o',
      help: 'Directory for the generated client library package.',
      callback: (String value) {
        if (isBlank(value)) {
          errors.add('--output-dir is required');
          return;
        }
        outputDir = new io.Directory(value);
        if (!outputDir.existsSync()) {
          errors.add('Output directory $value does not exist');
          return;
        }
      })
    ..addOption(
      'package-name',
      abbr: 'p',
      help: 'Name of the generated Dart package. Defaults to the name derived '
            'from the config file. This is simultaneously the name of the '
            'directory created under --output-dir and the package name in the '
            'generated pubspec.yaml.',
      callback: (String value) {
        // TODO: validate package name
        if (isBlank(value)) {
          errors.add('--package-name is required');
          return;
        }
        packageName = value;
      })
    ..addOption(
      'package-version',
      abbr: 'v',
      help: 'Version to be specified in the generated pubspec.yaml',
      defaultsTo: '0.0.0',
      callback: (String value) {
        if (!matchesFull(new RegExp(r'\d\.\d\.\d'), value)) {
          errors.add('Version must be in format 1.1.1, but got: $value');
          return;
        }
        packageVersion = value;
      })

    // Options mostly used for debugging purposes
    ..addOption(
        'local-streamy-location',
        help: 'Path to a local Streamy package. If specified the local '
              'version will be used instead of pub version.',
        callback: (String value) {
          if (remoteStreamyLocation != null && !isBlank(value)) {
            errors.add(locataionErrorMessage);
            return;
          }
          localStreamyLocation = value;
        })
    ..addOption(
        'remote-streamy-location',
        help: 'Remote to a git Streamy repository. If specified the remote '
              'version will be used instead of pub version.',
        callback: (String value) {
          if (localStreamyLocation != null && !isBlank(value)) {
            errors.add(locataionErrorMessage);
            return;
          }
          remoteStreamyLocation = value;
        })
    ..addOption(
        'remote-branch',
        defaultsTo: 'master',
        help: 'Remote branch name to use',
        callback: (String value) {
          remoteBranch = value;
        })
    ..addOption(
        'protoc',
        defaultsTo: 'protoc',
        help: 'Path to the protocol buffer compiler (protoc).',
        callback: (String value) {
          protocPath = value;
        })
    ..addFlag(
      'help',
      abbr: 'h',
      help: 'display commandline help options',
      negatable: false,
      callback: (bool value) => value ? printUsage() : null);

  argp.parse(arguments);
  if (errors.length > 0) {
    errors.forEach((e) {
      // TODO: use logging for errors
      print('ERROR: $e');
    });
    printUsage();
  }
}
