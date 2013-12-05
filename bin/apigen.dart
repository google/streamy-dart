import 'dart:convert' as convert;
import 'dart:io' as io;
import 'package:args/args.dart';
import 'package:json/json.dart';
import 'package:streamy/generator.dart';

/// Generates an API client from a Google API discovery file.
main(List<String> args) {
  ApigenOptions options = parseArgs(args);
  var discoveryFile = new io.File(options.discoveryFile);
  var json = discoveryFile.readAsStringSync(encoding: convert.UTF8);
  var discovery = new Discovery.fromJsonString(json);
  var clientFile = new io.File(options.clientFile);
  var basePath = clientFile.path.substring(0, clientFile.path.length - 5);
  var addendumData = {};
  if (options.addendumFile != null) {
    var addendumFile = new io.File(options.addendumFile);
    addendumData = parse(addendumFile.readAsStringSync());
  }

  var rootOut = clientFile.openWrite();
  var resourceOut = new io.File('${basePath}_resources.dart').openWrite();
  var requestOut = new io.File('${basePath}_requests.dart').openWrite();
  var objectOut = new io.File('${basePath}_objects.dart').openWrite();

  var templateProvider = new DefaultTemplateProvider(options.templatesDir);

  emitCode(new EmitterConfig(
      discovery,
      new DefaultTemplateProvider.defaultInstance(),
      rootOut,
      resourceOut,
      requestOut,
      objectOut,
      addendumData: addendumData));

  rootOut.close();
  resourceOut.close();
  requestOut.close();
  objectOut.close();
}

ApigenOptions parseArgs(List<String> arguments) {
  var argp = new ArgParser()
    ..addOption(
        'discovery_file',
        help: 'Path to the input discovery file.')
    ..addOption(
        'client_file',
        help: 'Path to the output file for generated client API code.')
    ..addOption(
        'addendum_file',
        help:'The name, if any, of the Streamy addendum to the discovery file.')
    ..addOption(
        'templates_dir',
        help: 'Directory containing code templates.');
  var args = argp.parse(arguments);
  var options = new ApigenOptions(
      args['discovery_file'],
      args['client_file'],
      args['addendum_file'],
      args['templates_dir']
  );
  if (!validateOptions(options)) {
    print(argp.getUsage());
    io.exit(1);
  }
  return options;
}

bool validateOptions(ApigenOptions options) {
  var errors = <String>[];
  if (isBlank(options.discoveryFile)) {
    errors.add('discovery_file option is required');
  }
  if (isBlank(options.clientFile)) {
    errors.add('client_file option is required');
  }
  if (errors.length > 0) {
    print(errors);
    return false;
  }
  return true;
}

bool isBlank(String s) {
  return s == null || s.trim().isEmpty;
}

/// Contains user-provided options for the API generator.
class ApigenOptions {
  /// Path to the input discovery file.
  String discoveryFile;
  /// Path to the output file containing client API code.
  String clientFile;
  /// Optional path to the addendum file which contains extensions to the
  /// discovery document.
  String addendumFile;
  /// Directory containing code templates.
  String templatesDir;

  ApigenOptions(this.discoveryFile, this.clientFile, this.addendumFile,
      String templatesDir) {
    this.templatesDir = (templatesDir != null) ? templatesDir : 'templates';
  }
}
