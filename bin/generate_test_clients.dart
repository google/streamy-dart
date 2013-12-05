import 'dart:io';
import 'package:json/json.dart';
import 'package:path/path.dart' as path;
import 'package:streamy/generator.dart';

/// Generates test clients defined by JSON in test/generated folder.
main() {
  Directory generatedDir = new Directory('test/generated');
  var allFiles = generatedDir.listSync(recursive: false, followLinks: false);
  allFiles.forEach((FileSystemEntity e) {
    if (!(e is File)) {
      return;
    }
    File testJsonFile = e;
    if (!testJsonFile.path.endsWith('_test.json')) {
      return;
    }
    print('Processing: ${testJsonFile}');
    // Remove _test.json at the end of the path
    String basePath =
        testJsonFile.path.substring(0, testJsonFile.path.length - 10);
    String baseFileName =
        basePath.substring(basePath.lastIndexOf(path.separator) + 1);
    String discoveryJson = testJsonFile.readAsStringSync();
    var discoveryData = new Discovery.fromJsonString(discoveryJson);

    var rootOut = new File('${basePath}_client.dart').openWrite();
    var resourceOut = new File('${basePath}_client_resources.dart').openWrite();
    var requestOut = new File('${basePath}_client_requests.dart').openWrite();
    var objectOut = new File('${basePath}_client_objects.dart').openWrite();

    File addendumFile = new File('${basePath}_addendum.json');
    Map addendumData = {};
    if (addendumFile.existsSync()) {
      print('Processing addendum: $testJsonFile');
      addendumData = parse(addendumFile.readAsStringSync());
    }
    addendumData['resources_import'] = '${baseFileName}_client_resources.dart';
    addendumData['requests_import'] = '${baseFileName}_client_requests.dart';
    addendumData['objects_import'] = '${baseFileName}_client_objects.dart';

    emitCode(new EmitterConfig(
        discoveryData,
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
  });
}
