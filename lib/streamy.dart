/// Runtime library used by all generated APIs.
library streamy.runtime;

import 'dart:async';
import 'dart:json';
import 'dart:mirrors';

import 'package:meta/meta.dart';
import 'package:streamy/collections.dart';

part 'runtime/entity/base.dart';
part 'runtime/entity/dynamic.dart';
part 'runtime/entity/empty.dart';
part 'runtime/entity/raw.dart';
part 'runtime/entity/util.dart';
part 'runtime/entity/wrapper.dart';
part 'runtime/cache.dart';
part 'runtime/local.dart';
part 'runtime/multiplexer.dart';
part 'runtime/proxy.dart';
part 'runtime/request.dart';
part 'runtime/transforms.dart';
part 'runtime/util.dart';
// The fixnum library (temporarily included as part of Streamy).
// TODO(arick): Export int{x,32,64} when fixnum becomes a pub package.
part 'runtime/fixnum/intx.dart';
part 'runtime/fixnum/int32.dart';
part 'runtime/fixnum/int64.dart';
