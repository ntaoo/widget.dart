library widegt_util;

import 'dart:io';

const DART_FILE_EXTENSION = '.dart';

Iterable<Path> getDartFilePaths(String dirPath) {
  final dir = new Directory(dirPath);
  assert(dir.existsSync());
  return dir.listSync()
      .where((i) => i is File)
      .where((File f) => f.name.endsWith(DART_FILE_EXTENSION))
      .mappedBy((File f) => new Path(f.fullPathSync()));
}
