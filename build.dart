import 'dart:io';
import 'package:html5lib/dom.dart';
import 'package:html5lib/parser.dart';
import 'package:html5lib/dom_parsing.dart';
import 'package:web_ui/component_build.dart';
import 'package:bot/bot.dart';

final _whitespaceRegex = new RegExp(r'\s+');

void main() {
  final input = 'web/index_source.html';
  final output = 'web/index.html';

  _transform(input, output).then((bool value) {
    if(value) {
      print('updated $output');
    } else {
      print('no change to $output');
    }
  });
  build(new Options().arguments, [output]);
}

Future<bool> _transform(String input, String output) {
  final file = new File(input);
  assert(file.existsSync());
  return file.readAsString()
      .chain((String contents) {
        var parser = new HtmlParser(contents, generateSpans: true);
        var document = parser.parse();
        _tweakDocument(document);
        return _updateIfChanged(output, document.outerHTML);
      });
}

Future<bool> _updateIfChanged(String filePath, String newContent) {
  final file = new File(filePath);
  return file.exists()
      .chain((bool exists) {
        if(exists) {
          return file.readAsString()
              .transform((String content) => content != newContent);
        } else {
          return new Future.immediate(true);
        }
      }).chain((bool shouldUpdate) {
        if(shouldUpdate) {
          return file.writeAsString(newContent)
            .transform((_) => true);
        } else {
          return new Future.immediate(false);
        }
      });
}

// TODO: crazy hack. Really need select recursive
//       or propery query support...whichever
List<Element> _findElements(Element element, Func1<Element, bool> predicate, [List<Element> target]) {
  if(target == null) {
    target = new List<Element>();
  }

  if(predicate(element)) {
    target.add(element);
  }

  element.elements.forEach((e) => _findElements(e, predicate, target));

  return target;
}

void _tweakDocument(Document document) {
  document.queryAll('section')
      .filter((s) => s.attributes['class'] == 'component')
      .forEach((s) {
        _tweakComponentSection(s);
      });

  final sectionHeaders = _findElements(document.body, (e) {
    return e.tagName == 'h1' || e.tagName == 'h2';
  });

  //
  // TOC fun!
  //
  final tocUls = document.queryAll('ul')
      .filter((e) => e.attributes['class'] != null && e.attributes['class'].contains('nav-list'));

  assert(tocUls.length == 1);
  final Element tocUl = $(tocUls).first();

  sectionHeaders.forEach((h) {
    final headerText = htmlSerializeEscape(h.innerHTML);
    final headerId = headerText.toLowerCase().replaceAll(_whitespaceRegex, '_');

    final link = new Element.tag('a')
      ..attributes['href'] = '#$headerId'
      ..attributes['class'] = h.tagName
      ..innerHTML = headerText;

    final li = new Element.tag('li')
      ..elements.add(link);

    tocUl.elements.add(li);


    h.attributes['id'] = headerId;
  });
}

void _tweakComponentSection(Element element) {
  // find demo section
  final demoSections = element.elements.filter((e) {
    return e.attributes['class'] == 'demo';
  });

  Element demoSection = null;
  if(demoSections.length == 1) {
    demoSection = demoSections[0];
  }

  // find code section
  final codeSections = element.elements.filter((e) {
    return e.attributes['class'] == 'code';
  });

  Element codeSection = null;
  if(demoSections.length == 1) {
    codeSection = codeSections[0];
  }

  // if we have both, take content of demo section, html encode and put it in demo
  if(demoSection != null && codeSection != null) {
    final demoMarkup = demoSection.innerHTML;
    codeSection.innerHTML = _cleanUpCode(demoMarkup);
  }
}

String _cleanUpCode(String input) {
  input = htmlSerializeEscape(input);

  var lines = input.split('\n')
      .filter((String line) {
        return line.trim().length > 0;
      });

  final regex = new RegExp(r'^([ ]*).*$');

  int minPrefix = null;
  lines.forEach((String line) {
    final match = regex.firstMatch(line);
    assert(match.groupCount == 1);
    final g = match.group(1);

    if(minPrefix == null) {
      minPrefix = g.length;
    } else if(minPrefix > g.length) {
      minPrefix = g.length;
    }
  });

  for(var i = 0; i < lines.length; i++) {
    lines[i] = lines[i].substring(minPrefix);
  }

  input = Strings.join(lines, '\n');

  return input;
}
