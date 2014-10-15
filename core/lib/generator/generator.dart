library streamy.generator.generator;

import 'package:mustache/mustache.dart' as mustache;
import 'package:streamy/generator/config.dart';
import 'package:streamy/generator/dart.dart';
import 'package:streamy/generator/ir.dart';

/// Carries the state of a single run of the emitter.
abstract class EmitterContext {
  Config get config;
  Map<String, mustache.Template> get templates;
  Api get api;
  String get libPrefix;

  DartLibrary get rootFile;
  DartFile get resourceFile;
  DartFile get requestFile;
  DartFile get objectFile;
  DartFile get dispatchFile;

  String get rootPrefix;
  String get resourcePrefix;
  String get requestPrefix;
  String get objectPrefix;
  String get dispatchPrefix;
}

/// Emits a specific implementation of a marshaller into a given
/// [EmitterContext].
abstract class MarshallerEmitter {
  /// Emits a marshaller class.
  void emit();

  /// Adds marshalling code to a [requestClass].
  void decorateRequestClass(Method method, DartClass requestClass);
}
