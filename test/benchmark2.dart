/**
 * Streamy benchmarks.
 *
 * Use this library to run benchmarks programmatically or using CLI.
 */
library streamy.benchmarks;

import 'package:streamy/base.dart' as base;
import 'package:benchmark_harness/benchmark_harness.dart';

class SuperCall extends BenchmarkBase {
 
  SuperCall() : super("super()");
  var map = {'foo': 1, 'bar': 2, 'baz': 3};
  var count = 0;
  
  get foo => this['foo'];
  
  operator[](String key) => map[key];
  
  void run() {
    count += foo;
  }
  
  void teardown() {
    print("Count: $count.");
  }
}

main() {
  new SuperCall().report();
  
}
