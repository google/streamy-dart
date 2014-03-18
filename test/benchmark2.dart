/**
 * Streamy benchmarks.
 *
 * Use this library to run benchmarks programmatically or using CLI.
 */
library streamy.benchmarks;

import 'generated/schema_object_client_objects.dart';
import 'package:benchmark_harness/benchmark_harness.dart';

class SuperCall extends BenchmarkBase {
 
  SuperCall() : super("Test");
  
  var count = 0;
  
  void run() {
    var f = new Foo()
      ..id = 7
      ..bar = "hello world";
  }
  
  void setup() {
  }
  
  void teardown() {
    print("Count: $count.");
  }
}

main() {
  new SuperCall().report();
}
