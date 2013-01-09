part of effects_tests;

void registerShowHideTests() {
  group('ShowHide', () {
    final displayValues = ['block', 'inline-block', 'inline', 'none', 'inherit', ''];

    for(final tag in ['div', 'span']) {
      for(final inheritedStyle in displayValues) {
        for(final inlineStyle in displayValues) {
          _registerTest(tag, inheritedStyle, inlineStyle);
        }
      }
    }
  });
}

// intentionally picking a 'weird' value that neither the style nor the element
// ever has defined
final String _playgroundWrapperDisplay = 'list-item';

void _registerTest(String tag, String sheetStyle, String inlineStyle) {
  final title = '[$tag~${_getEmptyText(sheetStyle)}~${_getEmptyText(inlineStyle)}]';
  group(title, () {
    setUp(() {
      _createShowHidePlayground(tag, sheetStyle, inlineStyle);
    });

    tearDown(_cleanUpPlayground);

    test('initial state', () {

      final sampleElement = query('.sample');

      final futureTuple = _getValues(tag, sheetStyle, inlineStyle, sampleElement);

      expectFutureComplete(futureTuple, (Tuple3<String, String, ShowHideState> tuple) {
        final defaultTagValue = tuple.item1;
        final calculatedDisplayValue = tuple.item2;
        final calculatedState = tuple.item3;

        final expectedDisplayValue = _getExpectedInitialCalculatedValue(defaultTagValue, sheetStyle, inlineStyle);

        expect(expectedDisplayValue, isNot(isEmpty), reason: 'Expected value should not be empty string');
        expect(calculatedDisplayValue, expectedDisplayValue);

        final expectedState = _getState(calculatedDisplayValue);

        expect(calculatedState, isNotNull);
        expect(calculatedState, expectedState);
      });
    });

    final actions = ['show', 'hide', 'toggle'];

    for(final a1 in actions) {

      test(a1, () {
        final element = query('.sample');
        final action = _getAction(a1);

        String initialCalculatedValue;

        final futureTuple = element.getComputedStyle('')
            .chain((css) {
              initialCalculatedValue = css.display;
              return action(element);
            })
            .chain((_) => _getValues(tag, sheetStyle, inlineStyle, element));

        expectFutureComplete(futureTuple, (Tuple3<String, String, ShowHideState> tuple) {
          final defaultTagValue = tuple.item1;
          final calculatedDisplayValue = tuple.item2;

          final calculatedState = tuple.item3;

          final initialDisplayValue = _getExpectedInitialCalculatedValue(defaultTagValue, sheetStyle, inlineStyle);
          final initialState = _getState(initialDisplayValue);


          final expectedState = _getActionResult(a1, initialState);

          expect(calculatedState, expectedState);

          final expectedCalculatedDisplay = _getExpectedCalculatedDisplay(tag, sheetStyle, inlineStyle, calculatedState, defaultTagValue);
          expect(expectedCalculatedDisplay, isNot(''), reason: 'calculated display should never be empty string');
          expect(calculatedDisplayValue, expectedCalculatedDisplay, reason: 'The calculated display value is off');

          final localDisplay = element.style.display;
          final expectedLocalDisplay = _getExpectedLocalDisplay(tag, sheetStyle, inlineStyle, calculatedState, defaultTagValue,
              initialCalculatedValue);
          expect(localDisplay, expectedLocalDisplay, reason: 'The local display value is off');
        });

      });
    }
  });
}

String _getExpectedLocalDisplay(String tag, String sheetStyle, String inlineStyle, ShowHideState state, String tagDefault, String initialCalculatedValue) {
  switch(state) {
    case ShowHideState.HIDDEN:
      return 'none';
    case ShowHideState.SHOWN:
      if(inlineStyle == 'none') {
        return tagDefault;
      } else if(inlineStyle == '' && sheetStyle == 'none') {
        return tagDefault;
      } else if(inlineStyle == 'inherit') {
        return initialCalculatedValue;
      } else if(inlineStyle != '') {
        return inlineStyle;
      }
      return '';
    default:
      throw 'no clue about $state';
  }
}

String _getExpectedCalculatedDisplay(String tag, String sheetStyle, String inlineStyle, ShowHideState state, String tagDefault) {
  switch(state) {
    case ShowHideState.HIDDEN:
      return 'none';
    case ShowHideState.SHOWN:
      if (inlineStyle == '') {
        if(sheetStyle == 'inherit') {
          return _playgroundWrapperDisplay;
        }
        else if(sheetStyle != 'none' && sheetStyle != '') {
          return sheetStyle;
        }
      } else if(inlineStyle == 'inherit') {
        return _playgroundWrapperDisplay;
      } else if(inlineStyle != 'none' && inlineStyle != 'inherit') {
        return inlineStyle;
      }
      return tagDefault;
    default:
      throw 'no clue about $state';
  }
}

ShowHideState _getActionResult(String action, ShowHideState initial) {
  switch(action) {
    case 'show':
      return ShowHideState.SHOWN;
    case 'hide':
      return ShowHideState.HIDDEN;
    case 'toggle':
      switch(initial) {
        case ShowHideState.HIDDEN:
          return ShowHideState.SHOWN;
        case ShowHideState.SHOWN:
          return ShowHideState.HIDDEN;
        default:
          throw 'boo!';
      }
      break;
    default:
      throw 'no clue how to party on $action';
  }
}

Future<Tuple3<String, String, ShowHideState>> _getValues(String tag, String sheetStyle, String inlineStyle, Element element) {
  final futureDefaultDisplay = Tools.getDefaultDisplay(tag);

  final futureCalculatedDisplayValue = element.getComputedStyle('')
      .transform((css) => css.display);

  final futureShowHide = ShowHide.getState(element);

  return Futures.wait([futureDefaultDisplay, futureCalculatedDisplayValue, futureShowHide])
      .transform((list) => new Tuple3(list[0], list[1], list[2]));
}

Func1<Element, Future> _getAction(String action) {
  switch(action) {
    case 'show':
      return ShowHide.instance.show;
    case 'hide':
      return ShowHide.instance.hide;
    case 'toggle':
      return ShowHide.instance.toggle;
    default:
      throw 'action "$action" is not supported';
  }
}

ShowHideState _getState(String calculatedDisplay) {
  return calculatedDisplay == 'none' ? ShowHideState.HIDDEN : ShowHideState.SHOWN;
}

String _getEmptyText(String text) {
  assert(text != null);
  return text.isEmpty ? 'empty' : text;
}

String _getExpectedInitialCalculatedValue(String defaultTagValue, String sheetStyle, String inlineStyle) {
  switch(inlineStyle) {
    case 'inherit':
      return _playgroundWrapperDisplay;
    case '':
      switch(sheetStyle) {
        case 'inherit':
          return _playgroundWrapperDisplay;
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
  pg.style.display = _playgroundWrapperDisplay;

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
