part of effects_tests;

// TODO: support case where many children, but invalid child called to show
//       need to specify that all of the original children will still be shown

void registerSwapperTests() {
  group('Swapper', () {
    tearDown(_cleanUpPlayground);

    _swapperTest(1, [], 0, true, 0);
    _swapperTest(0, [], -1, false, null);
    _swapperTest(5, [], null, true, null);
    _swapperTest(0, [], null, true, null);
    _swapperTest(1, [], -1, false, 0);
    _swapperTest(5, [], 3, true, 3);
  });
}

/**
 * [childCount] number of children to add to the host
 * [hiddenIndicies] the indicies of children to start hidden
 * [childIndexToShow] the index of the child to to show.
 *    negative number: pass in a new child that is not in the host
 *    null: pass in null
 * [expectedResult] what should the swap future return?
 * [expectedDisplayed] index of child that should be shown when when we're all done?
 *    null implies none is shown...no children
 */
void _swapperTest(int childCount,
                  List<int> hiddenIndicies,
                  int childIndexToShow,
                  bool expectedResult,
                  int expectedDisplayed) {
  assert(childCount != null);
  assert(childCount >= 0);
  assert(hiddenIndicies != null);
  assert(CollectionUtil.allUnique(hiddenIndicies));
  hiddenIndicies.forEach((int index) {
    assert(index >= 0);
    assert(index < childCount);
  });
  assert(expectedResult != null);
  assert(expectedDisplayed == null || (expectedDisplayed >= 0 && expectedDisplayed < childCount));

  // write the title
  final buffer = new StringBuffer('A host with child count: $childCount, with');

  if(hiddenIndicies.length == 0) {
    buffer.add(' no hidden children,');
  } else {
    buffer.add(' hidden children at indicies $hiddenIndicies,');
  }

  buffer.add(' trying to');

  if(childIndexToShow == null) {
    buffer.add(' hide all of the elements,');
  } else if(childIndexToShow < 0) {
    buffer.add(' show an element not in the host,');
  } else {
    buffer.add(' show the child element at index $childIndexToShow,');
  }

  buffer.add(' should');
  if(expectedResult) {
    buffer.add(' succeed');
  } else {
    buffer.add(' fail');
  }

  buffer.add(' with a final shown item');
  if(expectedDisplayed == null) {
    buffer.add(' of nothing');
  } else {
    buffer.add(' at index $expectedDisplayed');
  }

  test(buffer.toString(), () {
    _createPlayground();
    final pg = _getPlayground();

    // add all of the children
    for(var i = 0; i<childCount; i++) {
      // hide the right ones
      final hidden = hiddenIndicies.contains(i);
      _addTestElementToPlayground('Test item $i', hidden);
    }

    Element toShowElement = null;
    if(childIndexToShow == null) {
      // no op
    } else if(childIndexToShow < 0) {
      toShowElement = new DivElement();
    } else {
      toShowElement = pg.children[childIndexToShow];
    }

    Swapper.swap(pg, toShowElement)
      .transform(expectAsync1((bool actualResult) {
        expect(actualResult, expectedResult);
      }))
      .chain((_) => _getDisplayedIndicies(pg))
      .transform(expectAsync1((List<int> displayedIndicies) {
        if(expectedDisplayed == null) {
          expect(displayedIndicies, isEmpty, reason: 'There are no items to display');
        } else {
          expect(displayedIndicies.length, 1, reason: 'there should only be one displayed item');
          expect(displayedIndicies[0], expectedDisplayed);
        }
      }))
      .onComplete((future) {
        if(!future.hasValue) {
          registerException(future.exception, future.stackTrace);
        }
      });
  });
}

/**
 * get the list of all children of [host] that are currently 'shown'
 * assume all animations on all children are finished
 */
Future<List<int>> _getDisplayedIndicies(Element host) {
  final futures = host.children.map(ShowHide.getState);
  return Futures.wait(futures)
      .transform((List<ShowHideState> states) {
        assert(states.length == host.children.length);
        final shownIndicies = new List<int>();
        for(int i= 0; i < states.length; i++) {
          expect(states[i].isFinished, true, reason: 'every item should be done animating by now');
          if(states[i].isShow) {
            shownIndicies.add(i);
          }
        }
        return shownIndicies;
      });
}

void _addTestElementToPlayground(String text, bool hidden) {
  final display = hidden ? 'none' : 'block';
  _getPlayground().children.add(
      new DivElement()
        ..text = text
        ..style.cssText = 'background: pink; width: 100px; height: 100px; display: $display;'
        );
}
