import "package:third_party/dart/unittest/lib/html_config.dart";
import "package:third_party/dart/streamy/test/all_tests.dart" as streamy_tests;

/// Runs unit tests in the browser.
main() {
  useHtmlConfiguration(false);
  streamy_tests.main();
}
