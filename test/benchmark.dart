library streamy.benchmarks;

import 'dart:json' as json;
import 'dart:math';

import 'package:benchmark_harness/benchmark_harness.dart';
import 'package:fixnum/fixnum.dart';
import 'generated/benchmark_client.dart';

const MAX = 10000000;
const EXPANSION = 35;
const LEVEL = 3;

class DeserializationBenchmark extends BenchmarkBase {
  
  final Random _random = new Random(1234);
  var js;

  static void main() {
    new DeserializationBenchmark().report();
  }
  
  DeserializationBenchmark() : super("Deserialization");
  
  void run() {
    var foo = new Foo.fromJsonString(js);
  }
  
  void setup() {
    var foo = _makePopulatedFoo(LEVEL);
    js = json.stringify(foo);
  }
  
  Foo _makePopulatedFoo(int level) {
    Foo foo = new Foo()
      ..id = _random.nextInt(MAX)
      ..baz = _random.nextInt(MAX)
      ..qux = new Int64.fromInts(_random.nextInt(MAX), _random.nextInt(MAX))
      ..quux = new List.generate(_random.nextInt(EXPANSION),
          (_) => _random.nextDouble(), growable: false)
      ..corge = new List.generate(_random.nextInt(EXPANSION),
          (_) => _random.nextInt(MAX), growable: false)
      ..bar = new Bar();
    if (level > 0) {
      foo.bar.foos = new List.generate(EXPANSION,
          (_) => _makePopulatedFoo(level - 1), growable: false);
    }
    return foo;
  }
}

main() {
  DeserializationBenchmark.main();
}