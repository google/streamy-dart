library streamy.internal.filesystem;

import 'dart:async';

/// A file-system abstraction that allows us to access
/// local and transform assets in a unified way.
abstract class FileSystem {
  Future<bool> exists(String path);
  Stream<List<int>> read(String path);
}
