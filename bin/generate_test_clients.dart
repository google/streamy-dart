import "dart:io";
import "dart:json";
import "package:streamy/apigenlib.dart";

/// Generates test clients defined by JSON in test/generated folder.
main() {
  Directory generatedDir = new Directory("test/generated");
  var allFiles = generatedDir.listSync(recursive: false, followLinks: false);
  allFiles.forEach((FileSystemEntity e) {
    if (!(e is File)) {
      return;
    }
    File testJsonFile = e;
    if (!testJsonFile.path.endsWith("_test.json")) {
      return;
    }
    print("Processing: ${testJsonFile}");
    // Remove _test.json at the end of the path
    String basePath =
        testJsonFile.path.substring(0, testJsonFile.path.length - 10);
    String discoveryJson = testJsonFile.readAsStringSync();
    var d = new Discovery.fromJsonString(discoveryJson);
    var g = new Generator(new DefaultTemplateProvider.defaultInstance());
    File testClientFile = new File("${basePath}_client.dart");
    File addendumFile = new File("${basePath}_addendum.json");
    Map addendumData = {};
    if (addendumFile.existsSync()) {
      print("Processing addendum: $testJsonFile");
      addendumData = parse(addendumFile.readAsStringSync());
    }
    String generatedCode = g.generate(new Path(basePath).filename, d, addendumData: addendumData);
    testClientFile.writeAsString(generatedCode);
  });
}
