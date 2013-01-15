import 'dart:io';
import 'package:html5lib/dom.dart';
import 'package:html5lib/parser.dart';
import 'package:html5lib/dom_parsing.dart';
import 'package:web_ui/component_build.dart';

void main() {
  final input = 'web/index_source.html';
  final output = 'web/index.html';

  _transform(input, output).then((bool value) {
    if(value) {
      print('doing build');
      build(new Options().arguments, [output]);
    } else {
      print('nothing changed');
    }
  });
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

void _tweakDocument(Document document) {
  assert(document.body.elements.length == 1);
  final container = document.body.elements[0];
  final componentDivs = container.elements.filter((Element e) {
    return e.tagName == 'section' && e.attributes['class'] == 'component';
  });
  componentDivs.forEach(_tweakComponentSection);
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
