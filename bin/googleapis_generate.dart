/*
 * Generates Streamy client API packages for all discovery documents located in
 * a given directory.
 *
 * This program is a follow-up to googleapis_fetch.dart
 */
import 'dart:io';
import 'dart:async';
import 'package:args/args.dart';
import 'package:streamy/generator.dart';
import 'package:streamy/generator_utils.dart';
import 'package:quiver/async.dart';
import 'package:quiver/strings.dart';

Directory inputDir;
Directory outputDir;
String localStreamyLocation;

main(List<String> args) {
  var errors = [];
  var argp = new ArgParser()
    ..addOption(
        'input-dir',
        abbr: 'i',
        help: 'Directory containing discovery documents.',
        callback: (v) {
          if (isBlank(v)) {
            errors.add('ERROR: Missing --input-dir option');
            return;
          }
          inputDir = new Directory(v);
          if (!inputDir.existsSync()) {
            errors.add(
                'ERROR: input directory ${inputDir.path} does not exist');
            return;
          }
        })
    ..addOption(
        'output-dir',
        abbr: 'o',
        help: 'Output directory where all packages will be written to.',
        defaultsTo: '/tmp/googleapis',
        callback: (v) {
          outputDir = new Directory(v);
          outputDir.create(recursive: true);
        })
    ..addOption(
        'local-streamy-location',
        help: 'Path to a local Streamy package. If specified the local '
              'version will be used instead of pub version.',
        callback: (String value) {
          localStreamyLocation = value;
        });
  argp.parse(args);

  if (!errors.isEmpty) {
    errors.forEach(print);
    print(argp.getUsage());
    exit(1);
  }

  var discoveryFiles = inputDir.listSync()
      .where((f) => f.path.endsWith('.json'))
      .toList();
  forEachAsync(discoveryFiles, processDiscovery).then((_) {
    print('----------------------------------');
    print('Generated ${discoveryFiles.length} packages.');
    print('Results written to ${outputDir.absolute.path}');
  });
}

Future processDiscovery(File sourceFile) {
  var discoveryStr = sourceFile.readAsStringSync();
  var discovery = new Discovery.fromJsonString(discoveryStr);

  print('Generating ${discovery.name}:${discovery.version}');

  var packageDir = new Directory(
      '${outputDir.path}/${discovery.name}/${discovery.version}');
  packageDir.createSync(recursive: true);

  new File('${packageDir.path}/${discovery.name}_${discovery.version}.json')
      .writeAsStringSync(discoveryStr);

  return generateStreamyClientLibrary(sourceFile, packageDir,
      localStreamyLocation: localStreamyLocation);
}
