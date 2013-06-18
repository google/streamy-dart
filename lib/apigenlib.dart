library apigen;

import "dart:json" as json;
import "dart:io" as io;
import "package:third_party/dart/mustache/lib/mustache.dart" as mus;

part "discovery.dart";
part "generator.dart";
part "default.dart";

/// Used to report all sorts of problems during API generation.
class ApigenException implements Exception {
  String _msg;
  ApigenException(this._msg);
  String toString() => _msg;
}
