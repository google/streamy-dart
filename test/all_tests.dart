import "package:third_party/dart/streamy/test/generated/method_get_test.dart" as method_get_test;
import "package:third_party/dart/streamy/test/generated/method_post_test.dart" as method_post_test;
import "package:third_party/dart/streamy/test/generated/method_params_test.dart" as method_params_test;
import "package:third_party/dart/streamy/test/generated/multiplexer_test.dart" as multiplexer_test;
import "package:third_party/dart/streamy/test/generated/schema_object_test.dart" as schema_object_test;
import "package:third_party/dart/streamy/test/generated/schema_unknown_fields_test.dart" as schema_unknown_fields_test;

main() {
  method_get_test.main();
  method_post_test.main();
  method_params_test.main();
  schema_object_test.main();
  schema_unknown_fields_test.main();
  multiplexer_test.main();
}
