import 'dart:io';
import 'package:json/json.dart' as json;
import 'package:path/path.dart' as path;
import 'package:streamy/generator.dart';

/// Generates test clients defined by JSON in test/generated folder.
main() {
  Directory generatedDir = new Directory('test/generated');
  var allFiles = generatedDir.listSync(recursive: false, followLinks: false);
  allFiles
    .where((e) => e is File)
    .where((e) => e.path.endsWith('_test.json'))
    //.take(1)
    .forEach((FileSystemEntity e) {
      File testJsonFile = e;
      print('Processing: ${testJsonFile}');
      // Remove _test.json at the end of the path
      String basePath =
          testJsonFile.path.substring(0, testJsonFile.path.length - 10);
      String baseFileName =
          basePath.substring(basePath.lastIndexOf(path.separator) + 1);
      String discoveryJson = testJsonFile.readAsStringSync();
      
      
      File addendumFile = new File('${basePath}_addendum.json');
      Map addendumData = {};
      if (addendumFile.existsSync()) {
        print('Processing addendum: $testJsonFile');
        addendumData = json.parse(addendumFile.readAsStringSync());
      }
      
      var discoveryData = json.parse(discoveryJson);
      var api = parseDiscovery(discoveryData, addendumData);
      
      var pc = new PathConfig.prefixed('', '${baseFileName}_client_');
      var hc = new HierarchyConfig.fixed(new DartType('Entity', 'base', const []));
      var c = new Config(backingMapGetter: 'base.getMap');
      var emitter = new Emitter(SPLIT_LEVEL_LIBS, pc, hc, c, new TemplateLoader.fromDirectory('templates'));
      api.imports['package:streamy/base.dart'] = 'base';
      var out = emitter.process(api);
      
      maybeWriteFile(out.root, '${baseFileName}_client.dart');
      maybeWriteFile(out.resources, '${baseFileName}_client_resources.dart');
      maybeWriteFile(out.requests, '${baseFileName}_client_requests.dart');
      maybeWriteFile(out.objects, '${baseFileName}_client_objects.dart');
      maybeWriteFile(out.dispatch, '${baseFileName}_client_dispatch.dart');
  });
}

maybeWriteFile(DartFile file, String path) {
  if (file == null) {
    return;
  }
  print("Writing: test/generated/$path");
  new File('test/generated/$path').writeAsStringSync(file.render());
}
