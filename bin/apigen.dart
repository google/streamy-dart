import 'dart:io' as io;
import 'package:args/args.dart';
import 'package:quiver/strings.dart';
import 'package:quiver/pattern.dart';
import 'package:streamy/generator_utils.dart';

final _SPLITTING_LEVELS = const {
  'none': SPLIT_LEVEL_NONE,
  'parts': SPLIT_LEVEL_PARTS,
  'full': SPLIT_LEVEL_LIBS
};

io.File discoveryFile;
io.Directory outputDir;
io.File addendumFile;
io.Directory templatesDir;
int splitLevel;
String clientFileName;
String libVersion;
String localStreamyLocation;
String remoteStreamyLocation;
String remoteBranch;

String baseClass;
String baseImport;

/// Generates an API client from a Google API discovery file.
main(List<String> args) {
  parseArgs(args);
  // Build a configuration.
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
    ..addOption(
      'client-file-name',
      abbr: 'c',
      help: 'Prefix for the .dart files generated.',
      callback: (String value) {
        if (isBlank(value)) {
          errors.add('--client-file-name is required');
          return;
        }
        clientFileName = value;
      })
    ..addOption(
      'base-class',
      abbr: 'bc',
      help: 'Base class that Entities will inherit from. This is typically a ' +
          'Mixologist-generated class, but doesn\'t have to be.',
      defaultsTo: 'Entity',
      callback: (String value) {
        baseClass = value;
      })
    ..addOption(
      'base-import',
      abbr: 'bi',
      help: 'Fully qualified import path to use for the generated base class.',
      defaultsTo: 'package:streamy/base.dart',
      callback: (String value) {
        baseImport = value;
      })
    ..addOption(
      'output-splitting',
      abbr: 's',
      help: "Splitting level for generated code. 'none' for no splitting " +
          "(default). 'parts' for multiple part files within one library, " +
          "and 'full' for independent libraries.",
      defaultsTo: 'none',
      callback: (String value) {
        value = value.toLowerCase();
        if (!_SPLITTING_LEVELS.containsKey(value)) {
          errors.add('Invalid --output-splitting level: $value');
          return;
        }
        splitLevel = _SPLITTING_LEVELS[value];
      });
    ..addOption(
        'discovery-file',
        abbr: 'd',
        help: 'Path to the discovery file.',
        callback: (String value) {
          if (isBlank(value)) {
            errors.add('--discovery-file is required');
            return;
          }
          discoveryFile = new io.File(value);
          if (!discoveryFile.existsSync()) {
            errors.add('Discovery file $value does not exist');
            return;
          }
        })
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
        'addendum-file',
        abbr: 'a',
        help: 'Path to addendum to the discovery file.',
        callback: (String value) {
          if (!isBlank(value)) {
            addendumFile = new io.File(value);
            if (!addendumFile.existsSync()) {
              errors.add('Addendum file $value does not exist');
              return;
            }
          }
        })
    ..addOption(
        'templates-dir',
        abbr: 't',
        help: 'Directory containing code templates.',
        defaultsTo: 'templates',
        callback: (String value) {
          templatesDir = new io.Directory(value);
          if (!templatesDir.existsSync()) {
            errors.add('Code template directory $value does not exist');
            return;
          }
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
          libVersion = value;
        })
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
    ..addFlag(
        'help',
        abbr: 'h',
        help: 'display commandline help options',
        negatable: false,
        callback: (bool value) => value ? printUsage() : null)
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
        });
  argp.parse(arguments);
  if (errors.length > 0) {
    errors.forEach((e) {
      // TODO: use logging for errors
      print('ERROR: $e');
    });
    printUsage();
  }
}
