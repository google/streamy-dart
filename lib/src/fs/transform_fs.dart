library streamy.internal.transform_filesystem;

import 'dart:async';
import 'package:barback/barback.dart';
import 'fs.dart';

class TransformFileSystem implements FileSystem {

  final Transform _transform;

  TransformFileSystem(this._transform);

  Future<bool> exists(String path) =>
      _transform.hasInput(_toAssetId(path));

  Stream<List<int>> read(String path) =>
      _transform.readInput(_toAssetId(path));

  AssetId _toAssetId(String path) {
    return new AssetId(_transform.primaryInput.id.package,
      '${prefixFrom(_transform.primaryInput.id)}$path');
  }
}

/// Similar to UNIX dirname
String prefixFrom(AssetId asset) =>
  (asset.path.split('/')..removeLast()..add('')).join('/');
