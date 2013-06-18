import "dart:io";
import "package:third_party/dart/streamy/lib/apigenlib.dart";

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
    String generatedCode = g.generate(new Path(basePath).filename, d);
    File testClientFile = new File("${basePath}_client.dart");
    testClientFile.writeAsString(generatedCode);
  });
}
