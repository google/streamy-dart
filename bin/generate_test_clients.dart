import 'dart:io';
import 'package:json/json.dart' as json;
import 'package:path/path.dart' as path;
import 'package:yaml/yaml.dart' as yaml;
import 'package:streamy/generator.dart';

/// Generates test clients defined by JSON in test/generated folder.
main() {
  Directory generatedDir = new Directory('test/generated');
  var allFiles = generatedDir.listSync(recursive: false, followLinks: false);
  var current = Directory.current;
  allFiles
    .where((e) => e is File)
    .where((e) => e.path.endsWith('_test.yaml'))
    //.take(1)
    .forEach((FileSystemEntity e) {
      Directory.current = current;
      File testConfigFile = e;
      print('Processing: ${testConfigFile}');
      var config = parseConfigOrDie(yaml.loadYaml(testConfigFile.readAsStringSync()));
      /*
      // Remove _test.json at the end of the path
      String basePath =
          testJsonFile.path.substring(0, testJsonFile.path.length - 10);
      String baseFileName =
          basePath.substring(basePath.lastIndexOf(path.separator) + 1);
      String discoveryJson = testJsonFile.readAsStringSync();
      */
      var templateLoader = new TemplateLoader.fromDirectory('templates');
      Directory.current = testConfigFile.parent.absolute;
      var api = apiFromConfig(config);
      var emitter = new Emitter(config, templateLoader);
      api.imports['package:streamy/base.dart'] = 'base';
      var out = emitter.process(api);
      
      if (config.outputPrefix == "") {
        _die('bad output prefix.');
      }
      maybeWriteFile(out.root, '${config.outputPrefix}.dart');
      maybeWriteFile(out.resources, '${config.outputPrefix}_resources.dart');
      maybeWriteFile(out.requests, '${config.outputPrefix}_requests.dart');
      maybeWriteFile(out.objects, '${config.outputPrefix}_objects.dart');
      maybeWriteFile(out.dispatch, '${config.outputPrefix}_dispatch.dart');
  });
}

maybeWriteFile(DartFile file, String path) {
  if (file == null) {
    return;
  }
  new File(path).writeAsStringSync(file.render());
}
