library crazy;

import 'dart:io';
import 'package:bot/bot.dart';
import '/usr/local/Cellar/dart-editor/17594/dart-sdk/lib/_internal/compiler/implementation/mirrors/mirrors.dart';
import 'util.dart' as util;

void main() {
  const componentPath = r'lib/components/';
  final libPath = new Path(r'/usr/local/Cellar/dart-editor/17594/dart-sdk/');
  final packageRoot = new Path(r'packages/');

  final componentPaths = util.getDartFilePaths(componentPath).toList();
  final componentLibraryNames = componentPaths.mappedBy((p) => p.filename).toList();


  final targetPaths = componentPaths.mappedBy((Path p) => p.toNativePath());

  final compilation = new Compilation.library(targetPaths, libPath, packageRoot, ['--preserve-comments']);

  final mirrors = compilation.mirrors;

  final componentLibraries = mirrors.libraries.values.where((LibraryMirror lm) {
    return componentLibraryNames.contains(lm.simpleName);
  }).toList();

  for(final library in componentLibraries) {
    for(final componentClass in library.classes.values) {

      print(componentClass.simpleName);

      final CommentInstanceMirror classComment = componentClass.metadata
          .firstMatching((m) => m is CommentInstanceMirror && m.isDocComment, orElse: () => null);

      if(classComment == null) {
        print(' * no comment');
      } else {
        print(classComment.trimmedText);
      }
    }
  }
}
