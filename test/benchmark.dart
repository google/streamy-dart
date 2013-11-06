library streamy.benchmarks;

import 'dart:math';

import 'package:benchmark_harness/benchmark_harness.dart';
import 'package:fixnum/fixnum.dart';
import 'package:json/json.dart' as json;
import 'package:streamy/streamy.dart';
import 'generated/benchmark_client.dart';

const MAX = 10000000;
const EXPANSION = 35;
const LEVEL = 3;



Foo makePopulatedFoo(Random random, int level) {
  Foo foo = new Foo()
    ..id = random.nextInt(MAX)
    ..baz = random.nextInt(MAX)
    ..qux = new Int64.fromInts(random.nextInt(MAX), random.nextInt(MAX))
    ..quux = new List.generate(random.nextInt(EXPANSION),
        (_) => random.nextDouble(), growable: false)
    ..corge = new List.generate(random.nextInt(EXPANSION),
        (_) => random.nextInt(MAX), growable: false)
    ..bar = new Bar();
  if (level > 0) {
    foo.bar.foos = new List.generate(EXPANSION,
        (_) => makePopulatedFoo(random, level - 1), growable: false);
  }
  return foo;
}

class DeserializationBenchmark extends BenchmarkBase {

  final Random random = new Random(1234);
  var js;

  static void main() {
    new DeserializationBenchmark().report();
  }

  DeserializationBenchmark() : super("Deserialization");

  void run() {
    var foo = new Foo.fromJsonString(js, new NoopTrace());
  }

  void setup() {
    var foo = makePopulatedFoo(random, LEVEL);
    js = json.stringify(foo);
  }
}

class JsonParseBenchmark extends BenchmarkBase {

  final Random random = new Random(1234);
  var js;

  static void main() {
    new JsonParseBenchmark().report();
  }

  JsonParseBenchmark() : super("JsonParse");

  void run() {
    var foo = json.parse(js);
  }

  void setup() {
    var foo = makePopulatedFoo(random, LEVEL);
    js = json.stringify(foo);
    print("js length: ${js.length}");
  }
}

main() {
  JsonParseBenchmark.main();
  DeserializationBenchmark.main();
}