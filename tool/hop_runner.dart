import 'dart:async';
import 'dart:io';
import 'package:bot/bot.dart';
import 'package:bot/hop.dart';
import 'package:bot/hop_tasks.dart';
import 'util.dart' as util;

void main() {
  _assertKnownPath();

  final buildTask = createProcessTask('dart', args: ['build.dart'],
      description: "execute the project's build.dart file");
  addTask('build', buildTask);

  final paths = ['web/out/index.html_bootstrap.dart'];
  addTask('dart2js', createDart2JsTask(paths,
      minify: true, liveTypeAnalysis: true, rejectDeprecatedFeatures: true));

  addTask('test_dart2js', createDart2JsTask(['test/browser_test_harness.dart']));

  //
  // gh_pages
  //
  addAsyncTask('pages', (ctx) =>
      branchForDir(ctx, 'master', 'example', 'gh-pages'));

  //
  // populate components into example dir
  //
  addAsyncTask('copy_components', (ctx) => startProcess(ctx, './bin/copy_out.sh'));


  addTask('docs', getCompileDocsFunc('docs', 'packages/', () => new Future.immediate(_getLibraryPaths())));

  runHopCore();
}

List<String> _getLibraryPaths() {
  final libLocations = [r'lib/', r'lib/components'];
  return CollectionUtil.selectMany(libLocations, (libLoc) {
    return util.getDartFilePaths(libLoc);
  })
  .mappedBy((Path p) => p.toString())
  .toList();
}

void _assertKnownPath() {
  // since there is no way to determine the path of 'this' file
  // assume that Directory.current() is the root of the project.
  // So check for existance of /bin/hop_runner.dart
  final thisFile = new File('tool/hop_runner.dart');
  assert(thisFile.existsSync());
}
