/**
 * Runs Streamy benchmarks in the web browser.
 */
library streamy.benchmarks.html;

import 'dart:html';
import 'benchmark.dart';

main() {
  ButtonElement runBtn = find('#runBtn');
  runBtn.onClick.listen((_) {
    runBtn.style.display = 'none';
    runWithConfig(new BenchmarkConfig(printReport));
  });
}

void printReport(StreamyBenchmarkReport r) {
  find('#log').appendText(r.toTsv() + '\n');
}

Element find(String selector) => document.querySelector(selector);
