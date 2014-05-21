library streamy.test;

import 'base_test.dart' as base_test;

import 'generated/addendum_test.dart' as generated_addendum_test;
import 'generated/handler_test.dart' as generated_handler_test;
import 'generated/method_get_test.dart' as generated_method_get_test;
import 'generated/method_post_test.dart' as generated_method_post_test;
import 'generated/method_params_test.dart' as generated_method_params_test;
import 'generated/schema_object_test.dart' as generated_schema_object_test;

import 'runtime/batching_test.dart' as runtime_batching_test;
import 'runtime/branching_test.dart' as runtime_branching_test;
import 'runtime/cache_test.dart' as runtime_cache_test;
import 'runtime/dedup_test.dart' as runtime_dedup_test;
import 'runtime/error_test.dart' as runtime_error_test;
import 'runtime/http_test.dart' as runtime_http_test;
import 'runtime/marshaller_test.dart' as runtime_marshaller_test;
import 'runtime/multiplexer_test.dart' as runtime_multiplexer_test;
import 'runtime/proxy_test.dart' as runtime_proxy_test;
import 'runtime/request_test.dart' as runtime_request_test;
import 'runtime/transforms_test.dart' as runtime_transforms_test;
import 'runtime/transaction_test.dart' as runtime_transaction_test;

import 'streamy_test.dart' as streamy_test;

/*
import 'generated/multiplexer_test.dart' as multiplexer_test;
import 'generated/schema_unknown_fields_test.dart' as schema_unknown_fields_test;
import 'generator/emitter_test.dart' as generator_emitter_test;
*/

main(List<String> args) {
  ensureCheckedMode();

  base_test.main();
  generated_addendum_test.main();
  generated_handler_test.main();
  generated_method_get_test.main();
  generated_method_post_test.main();
  generated_method_params_test.main();
  generated_schema_object_test.main();
  runtime_batching_test.main();
  runtime_branching_test.main();
  runtime_cache_test.main();
  runtime_dedup_test.main();
  runtime_error_test.main();
  runtime_http_test.main();
  runtime_marshaller_test.main();
  runtime_multiplexer_test.main();
  runtime_proxy_test.main();
  runtime_request_test.main();
  runtime_transforms_test.main();
  runtime_transaction_test.main();
  /*
  streamy_test.main();
  schema_unknown_fields_test.main();
  generator_emitter_test.main(args);
  */
}

void ensureCheckedMode() {
  try {
    Object a = "Testing checked mode...";
    int b = a;
    print(b);  // ensures that the code is not tree-shaken off
    throw new StateError("Checked mode is disabled. Use option -c.");
  } on TypeError {
    // expected
  }
}
