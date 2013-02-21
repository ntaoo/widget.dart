library widegt_util;

import 'dart:io';
import 'package:bot/bot.dart';

const _dartFileExtension = '.dart';

Iterable<Path> getDartLibraryPaths() {
  return _getDartFilePaths([r'lib/', r'lib/components/']);
}

Iterable<Path> _getDartFilePaths(List<String> dirPaths) {
  return dirPaths.expand((String dirPath) {
    final dir = new Directory(dirPath);
    assert(dir.existsSync());
    return dir.listSync()
        .where((i) => i is File)
        .where((File f) => f.name.endsWith(_dartFileExtension))
        .map((File f) => new Path(f.fullPathSync()));
  });
}
