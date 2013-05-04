import 'dart:async';
import 'dart:io';
import 'package:bot/bot.dart';
import 'package:hop/hop.dart';
import 'package:hop/hop_tasks.dart';
import 'util.dart' as util;

void main() {
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


  addTask('docs', createDartDocTask(_getLibraryPaths, targetBranch: 'docs'));

  runHop();
}

List<String> _getLibraryPaths() {
  final libLocations = [r'lib/', r'lib/components'];
  return util.getDartLibraryPaths()
    .map((Path p) => p.toString())
    .toList();
}
