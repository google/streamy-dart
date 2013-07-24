import 'streamy_test.dart' as streamy_test;
import 'generated/addendum_test.dart' as addendum_test;
import 'generated/docs_test.dart' as docs_test;
import 'generated/method_get_test.dart' as method_get_test;
import 'generated/method_post_test.dart' as method_post_test;
import 'generated/method_params_test.dart' as method_params_test;
import 'generated/multiplexer_test.dart' as multiplexer_test;
import 'generated/schema_object_test.dart' as schema_object_test;
import 'generated/schema_unknown_fields_test.dart' as schema_unknown_fields_test;
import 'runtime/multiplexer_test.dart' as runtime_multiplexer_test;

main() {
  ensureCheckedMode();
  addendum_test.main();
  docs_test.main();
  method_get_test.main();
  method_post_test.main();
  method_params_test.main();
  schema_object_test.main();
  schema_unknown_fields_test.main();
  multiplexer_test.main();
  streamy_test.main();
  runtime_multiplexer_test.main();
}

void ensureCheckedMode() {
  try {
    Object a = "abc";
    int b = a;
    print(b);  // ensures that the code is not tree-shaken off
    throw new StateError("Checked mode is disabled. Use option -c.");
  } on TypeError {
    // expected
  }
}
