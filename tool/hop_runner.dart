import 'package:hop/hop.dart';
import 'package:hop/hop_tasks.dart';

import '../test/test_dump_render_tree.dart' as test_drt;

void main() {
  addTask('build', createProcessTask('dart', args: ['build.dart'],
      description: "execute the project's build.dart file"));

  final paths = ['web/out/index.html_bootstrap.dart'];
  addTask('dart2js', createDartCompilerTask(paths,
      minify: true, liveTypeAnalysis: true, rejectDeprecatedFeatures: true));

  addTask('test_dart2js',
      createDartCompilerTask(['test/browser_test_harness.dart']));

  addTask('test', createUnitTestTask(test_drt.testCore));

  //
  // gh_pages
  //
  addAsyncTask('pages', (ctx) =>
      branchForDir(ctx, 'master', 'example', 'gh-pages'));

  //
  // populate components into example dir
  //
  addAsyncTask('copy_components', (ctx) =>
      startProcess(ctx, './bin/copy_out.sh'));

  runHop();
}
