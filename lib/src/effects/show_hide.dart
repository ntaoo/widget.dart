part of effects;

class ShowHideAction extends _Enum {
  static const ShowHideAction SHOW = const ShowHideAction._internal("show");
  static const ShowHideAction HIDE = const ShowHideAction._internal('hide');
  static const ShowHideAction TOGGLE = const ShowHideAction._internal('toggle');

  const ShowHideAction._internal(String name) : super(name);
}

class ShowHide {
  static const int _defaultDuration = 400;
  static final Map<String, String> _defaultDisplays = new Map<String, String>();
  static final Expando<_ShowHideValues> _values = new Expando<_ShowHideValues>('_ShowHideValues');

  static Future<ShowHideState> getState(Element element) {
    assert(element != null);

    final values = _values[element];
    if(values == null) {
      return _populateState(element);
    } else {
      return new Future.immediate(values.currentState);
    }
  }

  static Future<bool> show(Element element,
      {ShowHideEffect effect, int duration, EffectTiming effectTiming}) {
    return begin(ShowHideAction.SHOW, element, effect: effect, duration: duration, effectTiming: effectTiming);
  }

  static Future<bool> hide(Element element,
      {ShowHideEffect effect, int duration, EffectTiming effectTiming}) {
    return begin(ShowHideAction.HIDE, element, effect: effect, duration: duration, effectTiming: effectTiming);
  }

  static Future<bool> toggle(Element element,
      {ShowHideEffect effect, int duration, EffectTiming effectTiming}) {
    return begin(ShowHideAction.TOGGLE, element, effect: effect, duration: duration, effectTiming: effectTiming);
  }

  static Future<bool> begin(ShowHideAction action, Element element,
      {ShowHideEffect effect, int duration, EffectTiming effectTiming}) {
    assert(action != null);
    assert(element != null);
    return getState(element)
        .transform(((oldState) => _getToggleState(action, oldState)))
        .chain((bool doShow) =>
            _requestEffect(doShow, element, duration, effect, effectTiming));
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

  static bool _getToggleState(ShowHideAction action, ShowHideState state) {
    switch(action) {
      case ShowHideAction.SHOW:
        return true;
      case ShowHideAction.HIDE:
        return false;
      case ShowHideAction.TOGGLE:
        switch(state) {
          case ShowHideState.HIDDEN:
          case ShowHideState.HIDING:
            return true;
          case ShowHideState.SHOWING:
          case ShowHideState.SHOWN:
            return false;
          default:
            throw new DetailedArgumentError('state', 'Value of $state is not supported');
        }
        break;
      default:
        throw new DetailedArgumentError('action', 'Value of $action is not supported');
    }
  }

  static Future<bool> _requestEffect(bool doShow, Element element, int desiredDuration,
      ShowHideEffect effect, EffectTiming effectTiming) {

    //
    // clean up possible null or invalid values
    //
    if(desiredDuration == null) {
      desiredDuration = _defaultDuration;
    } else if(desiredDuration < 0) {
      desiredDuration = 0;
    }

    effect = ShowHideEffect._orDefault(effect);

    if(effectTiming == null) {
      effectTiming = EffectTiming.defaultTiming;
    }

    //
    // do the transform
    //
    if(doShow) {
      return _requestShow(element, desiredDuration, effect, effectTiming);
    } else {
      return _requestHide(element, desiredDuration, effect, effectTiming);
    }
  }

  static Future<bool> _requestShow(Element element, int desiredDuration,
      ShowHideEffect effect, EffectTiming effectTiming) {
    assert(element != null);
    assert(desiredDuration != null);
    assert(effect != null);
    assert(effectTiming != null);
    final values = _values[element];

    switch(values.currentState) {
      case ShowHideState.SHOWING:
        // no op - let the current animation finish
        assert(_AnimatingValues.isAnimating(element));
        return new Future.immediate(true);
      case ShowHideState.SHOWN:
        // no op. If shown leave it.
        assert(!_AnimatingValues.isAnimating(element));
        return new Future.immediate(true);
      case ShowHideState.HIDING:
        _AnimatingValues.cancelAnimation(element);
        break;
      case ShowHideState.HIDDEN:
        // handeled below with a fall-through
        break;
      default:
        throw new DetailedArgumentError('oldState', 'the provided value ${values.currentState} is not supported');
    }

    assert(!_AnimatingValues.isAnimating(element));
    _finishShow(element);
    final durationMS = effect.startShow(element, desiredDuration, effectTiming);
    if(durationMS > 0) {

      // _finishShow sets the currentState to shown, but we know better since we're animating
      assert(values.currentState == ShowHideState.SHOWN);
      values.currentState = ShowHideState.SHOWING;
      return _AnimatingValues.scheduleCleanup(durationMS, element, effect.clearAnimation, _finishShow);
    } else {
      assert(values.currentState == ShowHideState.SHOWN);
    }
    return new Future.immediate(true);
  }

  static void _finishShow(Element element) {
    final values = _values[element];
    assert(!_AnimatingValues.isAnimating(element));
    element.style.display = _getShowDisplayValue(element);
    values.currentState = ShowHideState.SHOWN;
  }

  static Future<bool> _requestHide(Element element, int desiredDuration,
      ShowHideEffect effect, EffectTiming effectTiming) {
    assert(element != null);
    assert(desiredDuration != null);
    assert(effect != null);
    assert(effectTiming != null);
    final values = _values[element];

    switch(values.currentState) {
      case ShowHideState.HIDING:
        // no op - let the current animation finish
        assert(_AnimatingValues.isAnimating(element));
        return new Future.immediate(true);
      case ShowHideState.HIDDEN:
        // it's possible we're here because the inferred calculated value is 'none'
        // this hard-wires the local display value to 'none'...just to be clear
        _finishHide(element);
        return new Future.immediate(true);
      case ShowHideState.SHOWING:
        _AnimatingValues.cancelAnimation(element);
        break;
      case ShowHideState.SHOWN:
        // handeled below with a fall-through
        break;
      default:
        throw new DetailedArgumentError('oldState', 'the provided value ${values.currentState} is not supported');
    }

    assert(!_AnimatingValues.isAnimating(element));
    final durationMS = effect.startHide(element, desiredDuration, effectTiming);
    if(durationMS > 0) {
      _values[element].currentState = ShowHideState.HIDING;
      return _AnimatingValues.scheduleCleanup(durationMS, element, effect.clearAnimation, _finishHide);
    } else {
      _finishHide(element);
      assert(values.currentState == ShowHideState.HIDDEN);
    }
    return new Future.immediate(true);
  }

  static void _finishHide(Element element) {
    final values = _values[element];
    assert(!_AnimatingValues.isAnimating(element));
    element.style.display = 'none';
    values.currentState = ShowHideState.HIDDEN;
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
      if(values.initialLocalDisplay == '' || values.initialLocalDisplay == 'inherit') {
        // it was originally visible and the local value was empty
        // so returning the local value to '' should ensure it's visible
        return values.initialLocalDisplay;
      } else {
        // it was initially visible, cool
        return values.initialComputedDisplay;
      }
    }
  }
}

class _ShowHideValues {
  final String initialComputedDisplay;
  final String initialLocalDisplay;
  ShowHideState currentState;

  _ShowHideValues(this.initialComputedDisplay, this.initialLocalDisplay, this.currentState);
}

class _AnimatingValues {
  static final Expando<_AnimatingValues> _aniValues = new Expando<_AnimatingValues>('_AnimatingValues');

  final Element _element;
  final Action1<Element> _cleanupAction;
  final Action1<Element> _finishFunc;
  final Completer<bool> _completer = new Completer<bool>();

  int _setTimeoutHandle;

  _AnimatingValues._internal(this._element, this._cleanupAction, this._finishFunc) {
    assert(_aniValues[_element] == null);
    _aniValues[_element] = this;
  }

  Future<bool> _start(int durationMS) {
    assert(durationMS > 0);
    assert(_setTimeoutHandle == null);
    _setTimeoutHandle = window.setTimeout(_complete, durationMS);
    return _completer.future;
  }

  void _cancel() {
    assert(_setTimeoutHandle != null);
    window.clearTimeout(_setTimeoutHandle);
    _cleanup();
    _completer.complete(false);
  }

  void _complete() {
    _cleanup();
    _finishFunc(_element);
    _completer.complete(true);
  }

  void _cleanup() {
    assert(_aniValues[_element] != null);
    _cleanupAction(_element);
    _aniValues[_element] = null;
  }

  static bool isAnimating(Element element) {
    final values = _aniValues[element];
    return values != null;
  }

  static void cancelAnimation(Element element) {
    final values = _aniValues[element];
    assert(values != null);
    values._cancel();
  }

  static Future<bool> scheduleCleanup(int durationMS, Element element,
                              Action1<Element> cleanupAction,
                              Action1<Element> finishAction) {

    final value = new _AnimatingValues._internal(element, cleanupAction, finishAction);
    return value._start(durationMS);
  }
}
