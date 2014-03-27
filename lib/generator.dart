library streamy.generator;

import 'dart:io' as io;
import 'package:json/json.dart' as json;
import 'package:mustache/mustache.dart' as mus;

part 'generator/ast.dart';
part 'generator/discovery.dart';
//part 'generator/default.dart';
//part 'generator/discovery.dart';
//part 'generator/emitter.dart';

/// Used to report all sorts of problems during API generation.
class ApigenException implements Exception {
  String _msg;
  ApigenException(this._msg);
  String toString() => _msg;
}
