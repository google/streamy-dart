import "dart:io" as io;
import "package:third_party/dart/args/lib/args.dart";
import "package:third_party/dart/streamy/lib/apigenlib.dart";

/// Generates an API client from a Google API discovery file.
main() {
  ApigenOptions options = parseArgs();
  var discoveryFile = new io.File(options.discoveryFile);
  discoveryFile.readAsString(encoding: io.Encoding.UTF_8).then((String json) {
    var discovery = new Discovery.fromJsonString(json);
    var clientFile = new io.File(options.clientFile);
    String code = new Generator(new DefaultTemplateProvider(options.templatesDir))
        .generate(options.libraryName, discovery);
    clientFile.writeAsString(code, encoding: io.Encoding.UTF_8);
  });
}

ApigenOptions parseArgs() {
  var argp = new ArgParser()
    ..addOption(
        'discovery_file',
        help: "Path to the input discovery file.")
    ..addOption(
        'client_file',
        help: "Path to the output file for generated client API code.")
    ..addOption(
        'library_name',
        help: "The name of the library name for generated client API code.")
    ..addOption(
        'templates_dir',
        help: "Directory containing code templates.");
  var args = argp.parse(new io.Options().arguments);
  var options = new ApigenOptions(
      args["discovery_file"],
      args["client_file"],
      args["library_name"],
      args["templates_dir"]
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
    errors.add("discovery_file option is required");
  }
  if (isBlank(options.clientFile)) {
    errors.add("client_file option is required");
  }
  if (isBlank(options.libraryName)) {
    errors.add("library_name option is required");
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
  /// The name of the library name for generated client API code.
  String libraryName;
  /// Directory containing code templates.
  String templatesDir;

  ApigenOptions(this.discoveryFile, this.clientFile, this.libraryName,
      String templatesDir) {
    this.templatesDir = (templatesDir != null) ? templatesDir : "templates";
  }
}
