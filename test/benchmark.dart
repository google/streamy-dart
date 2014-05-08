/**
 * Streamy benchmarks.
 *
 * Use this library to run benchmarks programmatically or using CLI.
 */
library streamy.benchmarks;

import 'dart:math';

import 'package:benchmark_harness/benchmark_harness.dart';
import 'package:args/args.dart';
import 'package:fixnum/fixnum.dart';
import 'package:json/json.dart' as json;
import 'package:intl/intl.dart' as intl;
import 'package:streamy/streamy.dart';
import 'generated/benchmark_client_objects.dart';

const MAX = 10000000;
const EXPANSION = 15;  // this seems a reasonable number that doesn't kill
                       // Chrome when running the JS version of the benchmark.
const LEVEL = 3;
const ENTITIES_IN_LIST = 1000;
final Random random = new Random(1234);

/// Add your new benchmark here so it is autmatically picked up by command-line
/// and in-browser runners.
final List<StreamyBenchmark> ALL_BENCHMARKS = [
  new JsonParseBenchmark(),
  new DeserializationBenchmark(),

  // Sorting benchmarks
  new EntitySortBenchmark.noSort(),

  // - Using Streamy entities

  // -- dot-property
  new EntitySortBenchmark.dotProperty(),
  new EntitySortBenchmark.shallowSort(),
  new EntitySortBenchmark.global(),
  new EntitySortBenchmark.memoizedGlobal(),

  // -- bracket
  new EntitySortBenchmark.squareBracket(),
  new EntitySortBenchmark.squareBracketShallow(),
  new EntitySortBenchmark.memoizedBracketGlobal(),

  // - Using plain Dart objects
  new EntitySortBenchmark.plainSort(),
  new EntitySortBenchmark.plainSortShallow(),

  // - Using maps
  new EntitySortBenchmark.mapSort(),
  new EntitySortBenchmark.mapSortShallow(),

  // - Using lists
  new EntitySortBenchmark.listSort(),
  new EntitySortBenchmark.listSortShallow(),
];

typedef void ReportPrinter(StreamyBenchmarkReport);

BenchmarkConfig _config;

/// Runs benchmarks from command-line. The configuration is provided via
/// command-line arguments.
main(List<String> args) {
  ReportPrinter reportPrinter;
  List<String> benchmarks;

  var p = new ArgParser()
    ..addOption(
        'report',
        abbr: 'r',
        help: 'Report output format',
        allowed: const ['human', 'csv', 'tsv'],
        allowedHelp: const {
          'human': 'Human readable text format',
          'csv': 'Comma-separated value format',
          'tsv': 'Tab-separated value format',
        },
        defaultsTo: 'human',
        callback: (v) {
          switch(v) {
            case 'human':
              reportPrinter = (r) {
                print(r.toString());
              };
              break;
            case 'csv':
              reportPrinter = (r) {
                print(r.toCsv());
              };
              break;
            case 'tsv':
              reportPrinter = (r) {
                print(r.toTsv());
              };
              break;
            default: throw new ArgumentError('Unsupported report format: $v');
          }
        },
        allowMultiple: false,
        hide: false)
    ..addOption(
        'benchmark',
        abbr: 'b',
        help: 'Benchmark to run, can be repeated to specify more than one. '
              'In the absence of this option we run all benchmarks.',
        allowed: ALL_BENCHMARKS.map((b) => b.name).toList(),
        allowedHelp: new Map.fromIterable(
            ALL_BENCHMARKS,
            key: (StreamyBenchmark b) => b.name,
            value: (StreamyBenchmark b) => b.description),
        allowMultiple: true,
        callback: (List<String> v) {
          if (v.length == 0) v = null;
          benchmarks = v;
        });
  try {
    var argResults = p.parse(args, allowTrailingOptions: false);
    if (argResults.rest.length > 0) {
      throw new FormatException(
          'Unknown trailing parameters: ${argResults.rest}');
    }
  } on Exception catch (e) {
    print(e);
    print(p.getUsage());
    return;
  }

  runWithConfig(new BenchmarkConfig(reportPrinter, benchmarks: benchmarks));
}

/// Runs benchmarks using user-provided configuration.
void runWithConfig(BenchmarkConfig config) {
  _config = config;
  _runBenchmarks();
}

class BenchmarkConfig {
  final ReportPrinter reportPrinter;
  final List<StreamyBenchmark> benchmarkQueue;

  BenchmarkConfig._private(this.reportPrinter, this.benchmarkQueue);

  factory BenchmarkConfig(ReportPrinter reportPrinter,
                          {List<String> benchmarks}) {
    var queue = ALL_BENCHMARKS
        .where((StreamyBenchmark b) =>
          // When benchmarks list is null we run all benchmarks
          benchmarks == null || benchmarks.contains(b.name)).toList();

    return new BenchmarkConfig._private(reportPrinter, queue);
  }
}

void _runBenchmarks() {
  _config.benchmarkQueue.forEach((StreamyBenchmark b) {
    b.runAndReport();
  });
}

class StreamyBenchmarkReport {
  static final SCORE_FORMAT = new intl.NumberFormat('#', 'en_US');

  final String name;
  final num score;
  final String unit;

  StreamyBenchmarkReport(this.name, this.score, this.unit);

  factory StreamyBenchmarkReport.subReport(
      StreamyBenchmark benchmark,
      String subName,
      num score,
      String unit) =>
        new StreamyBenchmarkReport(
            '${benchmark.name}-${subName}', score, unit);

  String formatScore() => SCORE_FORMAT.format(score);

  /// Human-readable string.
  toString() => '$name: ${formatScore()} $unit';

  /// Comma-separated.
  toCsv() => '$name, $score, $unit';

  /// Tab-separated (easy to copy&paste into a Google Spreadsheet).
  toTsv() => '$name\t$score\t$unit';
}

class StreamyBenchmark extends BenchmarkBase {

  final String description;
  List<StreamyBenchmarkReport> subReports = [];

  StreamyBenchmark(String name, this.description) : super(name);

  void runAndReport() {
    double score = measure();
    var report = new StreamyBenchmarkReport(name, score, 'us');
    _config.reportPrinter(report);
    subReports.forEach(_config.reportPrinter);
  }
}

int totalFoos = 0;

Foo makePopulatedFoo(int level) {
  totalFoos++;
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
        (_) => makePopulatedFoo(level - 1), growable: false);
  }
  return foo;
}

class DeserializationBenchmark extends StreamyBenchmark {

  var js;

  DeserializationBenchmark() : super(
      'Deserialization',
      'Measures the speed of deserialization from JSON to Streamy entities');

  void run() {
    var foo = new Foo.fromJsonString(js, new NoopTrace());
  }

  void setup() {
    var foo = makePopulatedFoo(LEVEL);
    js = json.stringify(foo);
  }
}

class JsonParseBenchmark extends StreamyBenchmark {

  String js;

  JsonParseBenchmark() : super(
      'JsonParse',
      'Measures the speed of vanilla JSON parser, giving us a bottom line to '
      'target for Streamy\'s deserialization.');

  void run() {
    var foo = json.parse(js);
  }

  void setup() {
    var foo = makePopulatedFoo(LEVEL);
    js = json.stringify(foo);
    subReports.add(
        new StreamyBenchmarkReport.subReport(this, 'JSON-Length', js.length,
            'chars'));
  }
}

typedef String CruftAccessor(foo);

/**
 * Entities are commonly displayed in tables that allow sorting the rows on
 * columns. Popular sorting algorithms tend to do a lot of reads of properties
 * while sorting. It is therefore a great benchmark for property accessors.
 */
class EntitySortBenchmark extends StreamyBenchmark {

  final CruftAccessor cruftAccessor;
  final bool withSort;
  final Function initialListMaker;

  List _initialList;

  EntitySortBenchmark.noSort() :
    this.streamy('NoSort',
        'Does not do any sorting. Only here as a baseline that measures the '
        'overhead of list copying.', null, withSort: false);

  EntitySortBenchmark.shallowSort() :
    this.streamy('ShallowSort',
        'Uses a first-level property of a Streamy entity.',
        (Foo foo) => foo.cruft);

  EntitySortBenchmark.plainSortShallow() :
    this('PlainShallowSort',
        'Uses a first-level property of a plain Dart object. Used for '
        'comparison. This is likey the fastest possible accessor type.',
        (PlainFoo foo) => foo.cruft, makePlainList);

  EntitySortBenchmark.plainSort() :
    this('PlainSort',
        'Uses a fifth-level property in a chain of Streamy entities.',
        (PlainFoo foo) => foo.bar.foo.bar.foo.cruft, makePlainList);

  EntitySortBenchmark.mapSortShallow() :
    this('MapShallowSort',
        'Uses a first-level property of a map.',
        (Map foo) => foo['cruft'], makeMapList);

  EntitySortBenchmark.mapSort() :
    this('MapSort',
        'Uses a fifth-level property in a chain of maps.',
        (Map foo) => foo['bar']['foo']['bar']['foo']['cruft'],
        makeMapList);

  EntitySortBenchmark.listSort() :
    this('ListSort',
        'Represents entities as lists and sorts on a fifth-level property.',
        (List foo) => foo[1][0][0][0][0], makeListOfLists);

  EntitySortBenchmark.listSortShallow() :
    this('ListShallowSort',
        'Represents entities as lists and sorts on a first-level property.',
        (List foo) => foo[0], makeListOfLists);

  EntitySortBenchmark.squareBracket() :
    this.streamy('Bracket',
        'Uses bracket access to a fifth-level property in a chain of Streamy '
        'entities.',
        (Foo foo) => foo['bar.foo.bar.foo.cruft']);

  EntitySortBenchmark.squareBracketShallow() :
    this.streamy('BracketShallow',
        'Uses bracket access to a first-level property in a Streamy entity',
        (Foo foo) => foo['cruft']);

  EntitySortBenchmark.dotProperty() :
    this.streamy('DotProperty',
        'Uses Dart\'s usual dot-property access on a chain of Streamy '
        'entities to access a fifth-level property.',
        (Foo foo) => foo.bar.foo.bar.foo.cruft);

  EntitySortBenchmark.global() :
    this.streamy('Global',
        'Uses dot-property access but via a .global to access a fifth-level '
        'property.',
        (Foo foo) => foo.global['deepCruft']);

  EntitySortBenchmark.memoizedGlobal() :
    this.streamy('MemoizedGlobal',
        'Same as Global but memoized.',
        (Foo foo) => foo.global['deepCruftMemoized']);

  EntitySortBenchmark.memoizedBracketGlobal() :
    this.streamy('MemoizedGlobalBracket',
        'Same as MemoizedGlobal but uses bracket access.',
        (Foo foo) => foo.global['deepCruftMemoizedBracket']);

  EntitySortBenchmark(String name, String description, this.cruftAccessor,
      this.initialListMaker, {this.withSort: true}) :
        super(name, description);

  EntitySortBenchmark.streamy(String name, String description, cruftAccessor,
      {withSort: true}) : this(name, description, cruftAccessor,
          makeStreamyList, withSort: withSort);

  void setup() {
    Foo.addGlobal('deepCruft', (Foo foo) => foo.bar.foo.bar.foo.cruft);
    Foo.addGlobal('deepCruftMemoized', (Foo foo) => foo.bar.foo.bar.foo.cruft,
        memoize: true);
    Foo.addGlobal('deepCruftMemoizedBracket',
        (Foo foo) => foo['bar.foo.bar.foo.cruft'], memoize: true);
    _initialList = initialListMaker();
  }

  void run() {
    // Make a copy of the initial list each time. If we don't we'll be
    // sorting already sorted lists after the first run, which is not very
    // interesting.
    var entities = new List.from(_initialList, growable: false);
    // Initialize list
    if (withSort) {
      // Sort
      entities.sort((a, b) => cruftAccessor(a).compareTo(cruftAccessor(b)));
    }
  }

  // Warms up the VM, etc.
  void warmup() {
    for (int i = 0; i < 20; i++) {
      run();
    }
  }

  // Runs the benchmark enough times that the runtime is measurable.
  void exercise() {
    for (int i = 0; i < 10; i++) {
      run();
    }
  }

  static List makeStreamyList() {
    var l = new List<Foo>(ENTITIES_IN_LIST);
    for (int i = 0; i < ENTITIES_IN_LIST; i++) {
      l[i] =
        new Foo()
          ..cruft = randomString()
          ..bar = (new Bar()
            ..foo = (new Foo()
              ..bar = (new Bar()
                ..foo = (new Foo()
                  ..cruft = randomString()))));
    }
    return l;
  }

  static List makePlainList() {
    var l = new List<PlainFoo>(ENTITIES_IN_LIST);
    for (int i = 0; i < ENTITIES_IN_LIST; i++) {
      l[i] =
        new PlainFoo()
          ..cruft = randomString()
          ..bar = (new PlainBar()
            ..foo = (new PlainFoo()
              ..bar = (new PlainBar()
                ..foo = (new PlainFoo()
                  ..cruft = randomString()))));
    }
    return l;
  }

  static List makeMapList() {
    var l = new List<Map>(ENTITIES_IN_LIST);
    for (int i = 0; i < ENTITIES_IN_LIST; i++) {
      l[i] =
        new Map()
          ..['cruft'] = randomString()
          ..['bar'] = (new Map()
            ..['foo'] = (new Map()
              ..['bar'] = (new Map()
                ..['foo'] = (new Map()
                  ..['cruft'] = randomString()))));
    }
    return l;
  }

  static List makeListOfLists() {
    var l = new List<List>(ENTITIES_IN_LIST);
    for (int i = 0; i < ENTITIES_IN_LIST; i++) {
      l[i] = [
        randomString(),
        [[[[randomString()]]]],
      ];
    }
    return l;
  }

  static String randomString() =>
      new List.generate(random.nextInt(3 + EXPANSION),
          (_) => random.nextInt(10), growable: false).join('');
}

class PlainFoo {
  PlainBar bar;
  String cruft;
}

class PlainBar {
  PlainFoo foo;
}
