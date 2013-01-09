part of effects_tests;

void registerShowHideTests() {
  group('ShowHide', () {
    final displayValues = ['block', 'inline-block', 'inline', 'none', 'inherit', ''];

    for(final tag in ['div', 'span', 'li']) {
      for(final inheritedStyle in displayValues) {
        for(final inlineStyle in displayValues) {
          _registerTest(tag, inheritedStyle, inlineStyle);
        }
      }
    }
  });


}

void _registerTest(String tag, String sheetStyle, String inlineStyle) {
  setUp(() {
    _createShowHidePlayground(tag, sheetStyle, inlineStyle);
  });

  tearDown(_cleanUpPlayground);

  final title = '[$tag-$sheetStyle-$inlineStyle]';
  test(title, () {

    final sampleElement = query('.sample');

    final localDisplay = sampleElement.style.display;

    String expectedValue = null;

    final validateComputerDisplay = expectAsync1((String displayValue) {
      expect(expectedValue, isNot(isEmpty), reason: 'Expected value should not be empty string');
      expect(displayValue, expectedValue);
    });


    Tools.getDefaultDisplay(tag)
      .chain((String defaultTagDisplay) {
        expectedValue = _expectedValue(defaultTagDisplay, sheetStyle, inlineStyle);

        return sampleElement.getComputedStyle('');
      })
      .transform((CssStyleDeclaration css) {
        final computedDisplay = css.display;

        return computedDisplay;
      })
      .chain((value) {
        return Tools.windowWait(0).transform((_) => value);
      })
      .transform(validateComputerDisplay)
      .handleException((exp) => registerException(exp));
  });
}

String _expectedValue(String defaultTagValue, String sheetStyle, String inlineStyle) {
  switch(inlineStyle) {
    case 'inherit':
      return 'block';
    case '':
      switch(sheetStyle) {
        case 'inherit':
          return 'block';
        case '':
          return defaultTagValue;
        default:
          return sheetStyle;
      }
      // DARTBUG: I think this is filed arleady...should figure out this is never
      // hit...hmm...
      break;
    default:
      return inlineStyle;
  }
}

void _createShowHidePlayground(String tag, String sheetStyle, String inlineStyle) {
  _createPlayground();
  final pg = _getPlayground();
  assert(pg != null);
  assert(pg.children.length == 0);

  pg.style.height = '500px';
  pg.style.width = '500px';
  pg.style.padding = '10px';
  pg.style.background = 'pink';

  final styleElement = new StyleElement();
  styleElement.type = 'text/css';
  pg.append(styleElement);

  final CssStyleSheet sheet = styleElement.sheet;
  sheet.addRule('.sample', 'display: $sheetStyle;');


  // text describing our story
  pg.appendHtml('<p>tag: $tag</p>');
  pg.appendHtml('<p>Inherited style: $sheetStyle</p>');
  pg.appendHtml('<p>In-line style: $inlineStyle</p>');

  pg.appendHtml('<hr/>');

  pg.appendText('test before');

  // child element
  final testElement = new Element.tag(tag)
    ..classes.add('sample')
    ..appendText('sample text')
    ..style.margin = '5px'
    ..style.padding = '5px'
    ..style.width = '300px'
    ..style.height = '200px'
    ..style.background = 'gray'
    ..style.display = inlineStyle;

  pg.append(testElement);

  pg.appendText('test after');
}
