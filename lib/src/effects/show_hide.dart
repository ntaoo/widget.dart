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

  static Future<ShowHideState> getState(Element element) {
    assert(element != null);

    final values = _values[element];
    if(values == null) {
      return _populateState(element);
    } else {
      return new Future.immediate(values.currentState);
    }
  }

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

  static Future<ShowHideState> _populateState(Element element) {
    assert(_values[element] == null);

    return Futures.wait([element.getComputedStyle(''), Tools.getDefaultDisplay(element.tagName)])
        .transform((List items) {
          final computedStyle = items[0];
          final tagDefaultDisplay = items[1];

          _defaultDisplays.putIfAbsent(element.tagName, () => tagDefaultDisplay);

          final localDisplay = element.style.display;
          final computedDisplay = computedStyle.display;

          final inferredState = computedDisplay == 'none' ? ShowHideState.HIDDEN : ShowHideState.SHOWN;
          _values[element] = new _ShowHideValues(computedDisplay, localDisplay, inferredState);
          return inferredState;
        });
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
      // if the element was initially invisible, it's tough to know "why"
      // even if the element has a local display value of 'none' it still
      // might have inherited it from a style sheet
      // so we play say and set the local value to the tag default
      final tagDefault = _defaultDisplays[element.tagName];
      assert(tagDefault != null);
      return tagDefault;
    } else {
      if(values.initialLocalDisplay == '') {
        // it was originally visible and the local value was empty
        // so returning the local value to '' should ensure it's visible
        return '';
      } else {
        // it was initially visible, cool
        return values.initialComputedDisplay;
      }
    }
  }
}
