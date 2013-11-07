// Miscellaneous project-related utilities

import 'package:args/args.dart';

const STREAMY_PROJECT_ROOT_OPTION = 'streamy_project_root';
final _TRAILING_SLASHES = new RegExp(r"/+$");

// Path to the root of the Streamy project files.
String projectRootDir(List<String> arguments) {
  var argp = new ArgParser()
    ..addOption(
        STREAMY_PROJECT_ROOT_OPTION,
        help: 'Path to the root of the Streamy project files.');
  var args = argp.parse(arguments);
  if (args[STREAMY_PROJECT_ROOT_OPTION] != null) {
    return args[STREAMY_PROJECT_ROOT_OPTION].replaceAll(_TRAILING_SLASHES, "");
  } else {
    return '.';
  }
}
