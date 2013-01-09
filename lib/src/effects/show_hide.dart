part of effects;

class _ShowHideValues {
  final String initialComputedDisplay;
  ShowHideState currentState;

  _ShowHideValues(this.initialComputedDisplay, this.currentState);
}

class ShowHide {
  static final Map<String, String> _defaultDisplays = new Map<String, String>();
  static final Expando<_ShowHideValues> _values = new Expando<_ShowHideValues>('_ShowHideValues');

  const ShowHide();

  static const ShowHide instance = const ShowHide();

  Future show(Element element) {
    assert(element != null);
    return getState(element)
        .transform((oldState) => _setState(element, oldState, ShowHideState.SHOWING));
  }

  Future hide(Element element) {
    assert(element != null);
    return getState(element)
        .transform((oldState) => _setState(element, oldState, ShowHideState.HIDING));
  }

  Future toggle(Element element) {
    assert(element != null);
    return getState(element)
        .transform((oldState) => _toggleState(element, oldState));
  }

  static Future<ShowHideState> getState(Element element) {
    assert(element != null);

    return Futures.wait([element.getComputedStyle(''), Tools.getDefaultDisplay(element.tagName)])
        .transform((List items) => _getStateSync(element, items[0], items[1]));
  }

  static ShowHideState _getStateSync(Element element, CssStyleDeclaration computedCss, String tagDefaultDisplay) {
    _defaultDisplays.putIfAbsent(element.tagName, () => tagDefaultDisplay);

    final computedDisplay = computedCss.display;
    final inferredState = computedDisplay == 'none' ? ShowHideState.HIDDEN : ShowHideState.SHOWN;

    //
    // Storing some initial values -- allows us to know how to accurately show/hide
    //
    var values = _values[element];
    if(values == null) {
      _values[element] = new _ShowHideValues(computedDisplay, inferredState);
      return inferredState;
    } else {
      // TODO: could provide some asserts here around consistency...later
      return values.currentState;
    }
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
        _values[element].currentState = ShowHideState.HIDDEN;
        element.style.display = 'none';
        break;
      case ShowHideState.SHOWING:
        _values[element].currentState = ShowHideState.SHOWN;
        element.style.display = _getShowDisplayValue(element);
        break;
      default:
        throw 'provided state - $newState - not supported';
    }
  }

  static String _getShowDisplayValue(Element element) {
    final initialComputedDisplay = _values[element].initialComputedDisplay;

    if(initialComputedDisplay == 'none') {

      final tagDefault = _defaultDisplays[element.tagName];
      assert(tagDefault != null);
      return tagDefault;
    } else {
      // it was initially visible, cool
      return initialComputedDisplay;
    }
  }
}
