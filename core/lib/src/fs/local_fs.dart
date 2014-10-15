library streamy.internal.local_filesystem;

import 'dart:async';
import 'dart:io' as io;
import 'package:path/path.dart' as paths;
import 'fs.dart';

class LocalFileSystem implements FileSystem {
  io.Directory _rootDir;

  LocalFileSystem(this._rootDir);

  Future<bool> exists(String path) =>
      _toFullPath(path).exists();

  Stream<List<int>> read(String path) =>
      _toFullPath(path).openRead();

  io.File _toFullPath(String path) =>
      new io.File(paths.join(_rootDir.path, path));
}
