/// Runtime library used by all generated APIs.
library streamy.runtime;

import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:json/json.dart';
import 'package:fixnum/fixnum.dart';
import 'package:meta/meta.dart';
import 'package:observe/observe.dart';
import 'package:quiver/collection.dart';
import 'package:quiver/iterables.dart';

part 'runtime/entity/base.dart';
part 'runtime/entity/empty.dart';
part 'runtime/entity/raw.dart';
part 'runtime/entity/util.dart';
part 'runtime/entity/wrapper.dart';
part 'runtime/batching_http_service.dart';
part 'runtime/cache.dart';
part 'runtime/error.dart';
part 'runtime/http.dart';
part 'runtime/json.dart';
part 'runtime/metadata.dart';
part 'runtime/multiplexer.dart';
part 'runtime/proxy.dart';
part 'runtime/request.dart';
part 'runtime/transforms.dart';
part 'runtime/util.dart';
