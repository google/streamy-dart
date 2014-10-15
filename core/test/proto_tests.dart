library streamy.test;

import 'generated/proto_test.dart' as generated_proto_test;
import 'runtime/marshaller_test.dart' as runtime_marshaller_test;

main(List<String> args) {
  generated_proto_test.main();
  runtime_marshaller_test.main();
}
