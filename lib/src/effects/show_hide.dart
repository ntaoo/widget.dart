part of effects;

class ShowHide {
  static const String _initialLocalDisplayValueKey = 'sh_initialLocalDisplay';
  static const String _initialComputedDisplayValueKey = 'sh_initialCalculatedDisplay';
  static const String _currentStateKey = '_sh_currentState';

  Future show(Element element) {
    assert(element != null);
    print('showing $element');
    return _getState(element)
        .transform((oldState) => _setState(element, oldState, ShowHideState.SHOWING));
  }

  Future hide(Element element) {
    assert(element != null);
    print('hiding $element');
    return _getState(element)
        .transform((oldState) => _setState(element, oldState, ShowHideState.HIDING));
  }

  Future toggle(Element element) {
    assert(element != null);
    print('toggling $element');
    return _getState(element)
        .transform((oldState) => _toggleState(element, oldState));
  }

  static Future<ShowHideState> _getState(Element element) {
    assert(element != null);

    return element.getComputedStyle('')
        .transform((css) => _getStateSync(element, css));
  }

  static ShowHideState _getStateSync(Element element, CssStyleDeclaration computedCss) {
    final computedDisplay = computedCss.display;

    //
    // Storing some initial values -- allows us to know how to accurately show/hide
    //
    element.dataset.putIfAbsent(_initialComputedDisplayValueKey, () => computedDisplay);
    element.dataset.putIfAbsent(_initialLocalDisplayValueKey, () => element.style.display);

    final inferredState = computedDisplay == 'none' ? ShowHideState.HIDDEN : ShowHideState.SHOWN;

    final storedStateName = element.dataset.putIfAbsent(_currentStateKey, () => inferredState.name);
    final storedState = ShowHideState.byName(storedStateName);
    assert(storedState != null);

    // TODO: could provide some asserts here around consistency...later

    return storedState;
  }

  static void _toggleState(Element element, ShowHideState oldState) {
    ShowHideState newState;
    if(oldState == ShowHideState.HIDDEN || oldState == ShowHideState.HIDING) {
      newState = ShowHideState.SHOWING;
    } else if(oldState == ShowHideState.SHOWING || oldState == ShowHideState.SHOWN) {
      newState = ShowHideState.HIDING;
    } else {
      throw 'provided oldState - $oldState - is not understood';
    }
    assert(newState != null);
    _setState(element, oldState, newState);
  }

  static void _setState(Element element, ShowHideState oldState, ShowHideState newState) {
    assert(newState == ShowHideState.HIDING || newState == ShowHideState.SHOWING);

    switch(newState) {
      case ShowHideState.HIDING:
        element.style.display = 'none';
        break;
      case ShowHideState.SHOWING:
        // TODO: need to remember this some how? hmm...
        element.style.display = 'block';
        break;
      default:
        throw 'provided state - $newState - not supported';
    }
  }
}
