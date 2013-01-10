part of effects;

class _ShowHideValues {
  final String initialComputedDisplay;
  final String initialLocalDisplay;
  ShowHideState currentState;

  _ShowHideValues(this.initialComputedDisplay, this.initialLocalDisplay, this.currentState);
}

class ShowHide {
  static final Map<String, String> _defaultDisplays = new Map<String, String>();
  static final Expando<_ShowHideValues> _values = new Expando<_ShowHideValues>('_ShowHideValues');

  const ShowHide();

  static const ShowHide instance = const ShowHide();

  Future<ShowHideState> show(Element element) {
    assert(element != null);
    return getState(element)
        .transform((oldState) => _setState(element, oldState, ShowHideState.SHOWING));
  }

  Future<ShowHideState> hide(Element element) {
    assert(element != null);
    return getState(element)
        .transform((oldState) => _setState(element, oldState, ShowHideState.HIDING));
  }

  Future<ShowHideState> toggle(Element element) {
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

    //
    // Storing some initial values -- allows us return element to original state
    //
    var values = _values[element];
    if(values == null) {
      final localDisplay = element.style.display;
      final computedDisplay = computedCss.display;

      final inferredState = computedDisplay == 'none' ? ShowHideState.HIDDEN : ShowHideState.SHOWN;
      _values[element] = new _ShowHideValues(computedDisplay, localDisplay, inferredState);
      return inferredState;
    } else {
      // TODO: could provide some asserts here around consistency...later
      return values.currentState;
    }
  }

  static ShowHideState _toggleState(Element element, ShowHideState oldState) {
    final newState = _getToggleState(oldState);
    assert(newState != null);
    return _setState(element, oldState, newState);
  }

  static ShowHideState _getToggleState(ShowHideState state) {
    switch(state) {
      case ShowHideState.HIDDEN:
      case ShowHideState.HIDING:
        return ShowHideState.SHOWING;
      case ShowHideState.SHOWING:
      case ShowHideState.SHOWN:
        return ShowHideState.HIDING;
      default:
        throw new DetailedArgumentError('state', 'Value of $state is not supported');
    }
  }

  static ShowHideState _setState(Element element, ShowHideState oldState, ShowHideState newState) {
    assert(newState == ShowHideState.HIDING || newState == ShowHideState.SHOWING);

    switch(newState) {
      case ShowHideState.HIDING:
        element.style.display = 'none';
        return _values[element].currentState = ShowHideState.HIDDEN;
      case ShowHideState.SHOWING:
        element.style.display = _getShowDisplayValue(element);
        return _values[element].currentState = ShowHideState.SHOWN;
      default:
        throw 'provided state - $newState - not supported';
    }
  }

  static String _getShowDisplayValue(Element element) {
    final values = _values[element];

    if(values.initialComputedDisplay == 'none') {
      final tagDefault = _defaultDisplays[element.tagName];
      assert(tagDefault != null);
      return tagDefault;
    } else {
      if(values.initialLocalDisplay == '') {
        return '';
      }

      // it was initially visible, cool
      return values.initialComputedDisplay;
    }
  }
}
