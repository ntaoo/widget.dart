library widegt_util;

import 'dart:io';

const _dartFileExtension = '.dart';

Iterable<String> getDartLibraryPaths() {
  return _getDartFilePaths([r'lib/', r'lib/components/']);
}

Iterable<String> _getDartFilePaths(List<String> dirPaths) {
  return dirPaths.expand((String dirPath) {
    final dir = new Directory(dirPath);
    assert(dir.existsSync());
    return dir.listSync()
        .where((i) => i is File)
        .where((File f) => f.path.endsWith(_dartFileExtension))
        .map((File f) => f.fullPathSync());
  });
}
