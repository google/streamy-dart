// Copyright 2014 Google Inc. All Rights Reserved.
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//     http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

/**
 * Scans a given directory recursively for Dart packages, and runs dartanalyzer
 * on each Dart file. Useful to smoke-test generated Streamy code.
 */
import 'dart:io';
import 'package:args/args.dart';
import 'package:quiver/strings.dart';
import 'package:quiver/async.dart';
import 'package:path/path.dart' as path;

var http = new HttpClient();

Directory scanDir;

main(List<String> args) {
  var errors = [];
  var argp = new ArgParser()
    ..addOption(
        'scan-dir',
        abbr: 's',
        help: 'Directory to scan for Dart packages.',
        callback: (v) {
          if (isBlank(v)) {
            errors.add('ERROR: missing option --scan-dir');
            return;
          }
          scanDir = new Directory(v);
          if (!scanDir.existsSync()) {
            errors.add('ERROR: directory not found: ${v}');
            return;
          }
        });
  argp.parse(args);

  if (!errors.isEmpty) {
    errors.forEach(print);
    print(argp.getUsage());
    exit(1);
  }

  forEachAsync(scanDir.listSync(recursive: true)
    .where((f) => f is File && f.path.endsWith('pubspec.yaml'))
    .map((f) => f.parent), (Directory packageDir) {
      print('Found package: ${packageDir}');
      return Process.run('pub', ['get', '--offline'],
          workingDirectory: packageDir.absolute.path)
        .then((pubResults) {
          stderr.write(pubResults.stderr);
          if (pubResults.exitCode != 0) {
            print('  pub get failed, package skipped');
          } else {
            forEachAsync(packageDir.listSync(recursive: true)
              .where((f) => f is File && f.path.endsWith('.dart') &&
                  !hasPackagesParent(f)).take(1), (File dartFile) {
                print('  Analyzing ${dartFile}');
                var args = [
                  '--package-root=${packageDir.absolute.path}',
                  dartFile.absolute.path,
                ];
                print(args);
                return Process.run('dartanalyzer', args,
                    workingDirectory: packageDir.absolute.path)
                .then((analyzerResults) {
                  stdout.write(analyzerResults.stdout);
                  stderr.write(analyzerResults.stderr);
                });
              });
          }
        });
    });
}

bool hasPackagesParent(FileSystemEntity f) =>
    path.split(f.absolute.path).contains('packages');
