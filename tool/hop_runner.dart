import 'dart:io';
import 'package:bot/hop.dart';
import 'package:bot/hop_tasks.dart';

void main() {
  _assertKnownPath();

  final buildTask = createProcessTask('dart', args: ['build.dart'],
      description: "execute the project's build.dart file");
  addTask('build', buildTask);

  final paths = ['web/out/index.html_bootstrap.dart'];
  addTask('dart2js', createDart2JsTask(paths));

  runHopCore();
}

void _assertKnownPath() {
  // since there is no way to determine the path of 'this' file
  // assume that Directory.current() is the root of the project.
  // So check for existance of /bin/hop_runner.dart
  final thisFile = new File('tool/hop_runner.dart');
  assert(thisFile.existsSync());
}
