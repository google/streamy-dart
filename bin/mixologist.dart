library streamy.mixologist.bin;

import 'dart:async';
import 'dart:io' as io;
import 'package:args/args.dart';
import 'package:path/path.dart' as path;
import 'package:streamy/mixologist.dart' as mixologist;
import 'package:streamy/src/fs/local_fs.dart';
import 'package:yaml/yaml.dart' as yaml;

io.Directory outputDir;
io.File configFile;

main(List<String> args) {
  parseArgs(args);
  mixologist.Config config;
  configFile.readAsString()
    .then((String configString) {
      config = mixologist.parseConfig(yaml.loadYaml(configString));
    })
    .then((_) =>
        mixologist.mix(config, new LocalFileSystem(new io.Directory('./lib'))))
    .then((String code) {
      var outputFilePath = path.join(outputDir.path, config.output);
      new io.Directory(path.dirname(outputFilePath)).createSync(recursive: true);
      var outputFile = new io.File(outputFilePath);
      return outputFile.writeAsString(code);
    });
}

void parseArgs(List<String> args) {
  var argp = new ArgParser()
    ..addOption('config-file',
      abbr: 'c',
      help: 'Path to *.mixologist.yaml configuration file',
      callback: (value) {
        configFile = new io.File(value);
      })
    ..addOption('output-dir',
      abbr: 'o',
      help: 'Output directory',
      callback: (value) {
        outputDir = new io.Directory(value);
      });
  argp.parse(args);
  if (outputDir == null || configFile == null) {
    print(argp.getUsage());
    return;
  }
}
