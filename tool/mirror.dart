library mirror;

import 'dart:io';
import 'package:bot/bot.dart';
import '/usr/local/Cellar/dart-editor/17594/dart-sdk/lib/_internal/compiler/implementation/mirrors/mirrors.dart';
import '/usr/local/Cellar/dart-editor/17594/dart-sdk/lib/_internal/dartdoc/lib/markdown.dart' as md;
import 'package:html5lib/dom.dart' as dom;
import 'package:html5lib/parser.dart';
import 'package:html5lib/dom_parsing.dart';
import 'util.dart' as util;

const _htmlToHack = r'web/index_source.html';

String getHtml(String className, String markdown) {
  md.setImplicitLinkResolver((name) {
    if(name == className) {
      return new md.Element.text('strong', name);
    } else {
      final anchor = new md.Element.text('a', name);
      anchor.attributes['href'] = '#${name.toLowerCase()}';
      return anchor;
    }
  });

  final blocks = _getBlocks(markdown);

  return md.renderToHtml(blocks);
}

List<md.Node> _getBlocks(String markdown) {
  final document = new md.Document();

  // Replace windows line endings with unix line endings, and split.
  final lines = markdown.replaceAll('\r\n','\n').split('\n');

  document.parseRefLinks(lines);
  return document.parseLines(lines);
}


void main() {
  final classes = _getTargetClasses();

  final htmlFile = new File(_htmlToHack);
  assert(htmlFile.existsSync());

  final originalContent = htmlFile.readAsStringSync();

  final parser = new HtmlParser(originalContent, generateSpans: true);
  final document = parser.parse();

  for(final componentClass in classes) {

    final classSimpleName = componentClass.simpleName;


    final CommentInstanceMirror classComment = componentClass.metadata
        .firstMatching((m) => m is CommentInstanceMirror && m.isDocComment, orElse: () => null);

    if(classComment == null) {
      print('*** $classSimpleName - no comment');
    } else {
      print('* ${componentClass.simpleName}');
      _writeClassComment(document, componentClass.simpleName, classComment.trimmedText);
    }
  }

  // Now document has been updated
  final updatedContent = document.outerHTML;
  if(updatedContent != originalContent) {
    // we should write!
    print("updating $_htmlToHack");
    htmlFile.writeAsStringSync(updatedContent);
  }
}

List<ClassMirror> _getTargetClasses() {
  final currentLibraryPath = new Directory.current().path;
  final libPath = new Path(r'/usr/local/Cellar/dart-editor/17594/dart-sdk/');
  final packageRoot = new Path(r'packages/');

  final componentPaths = util.getDartLibraryPaths().toList();
  final componentLibraryNames = componentPaths.mappedBy((p) => p.filename).toList();


  final targetPaths = componentPaths.mappedBy((Path p) => p.toNativePath());

  final compilation = new Compilation.library(targetPaths, libPath, packageRoot, ['--preserve-comments']);

  final mirrors = compilation.mirrors;

  final componentLibraries = mirrors.libraries.values.where((LibraryMirror lm) {
    final uri = lm.location.sourceUri;
    return uri.scheme == 'file' && uri.path.startsWith(currentLibraryPath);
  }).toList();

  return CollectionUtil.selectMany(componentLibraries, (LibraryMirror lm) {
    return lm.classes.values;
  }).toList();
}

void _writeClassComment(dom.Document doc, String className, String markdownCommentContent) {

  final htmlContent = getHtml(className, markdownCommentContent);
  assert(htmlContent != null);

  // find the rigth quote block...right?

  final bq = _getBlockQuoteElement(doc, className);

  if(bq != null) {
    bq.innerHTML = htmlContent;
    print(' * updated blockquote');
  }
}

dom.Element _getBlockQuoteElement(dom.Document doc, String className) {
  return doc.queryAll('blockquote')
      .firstMatching((e) => _isRightBlockQuote(e, className), orElse: () => null);
}

bool _isRightBlockQuote(dom.Element element, String className) {
  if(element.attributes['class'] != 'comments') {
    return false;
  }

  final parent = element.parent;
  if(parent == null) {
    return false;
  }

  if(parent.elements.indexOf(element) != 1) {
    return false;
  }

  // this should be an h2
  final firstChild = parent.elements.first;

  return firstChild.tagName == 'h2' && firstChild.innerHTML == className;
}

