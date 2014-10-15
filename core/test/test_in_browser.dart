import 'package:unittest/html_config.dart';
import 'all_tests.dart' as streamy_tests;

/// Runs unit tests in the browser.
main() {
  useHtmlConfiguration(false);
  streamy_tests.main([]);
}
