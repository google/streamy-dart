/// Runtime library used by all generated APIs.
library streamy.runtime;

import 'dart:async';
import 'dart:json';

import 'package:meta/meta.dart';
import 'package:fixnum/fixnum.dart';
import 'package:perf_api/perf_api.dart';
import 'package:streamy/collections.dart';

part 'runtime/entity/base.dart';
part 'runtime/entity/empty.dart';
part 'runtime/entity/raw.dart';
part 'runtime/entity/util.dart';
part 'runtime/entity/wrapper.dart';
part 'runtime/cache.dart';
part 'runtime/error.dart';
part 'runtime/metadata.dart';
part 'runtime/multiplexer.dart';
part 'runtime/proxy.dart';
part 'runtime/request.dart';
part 'runtime/transforms.dart';
part 'runtime/util.dart';
