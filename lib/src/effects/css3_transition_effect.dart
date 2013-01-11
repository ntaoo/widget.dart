part of effects;

class Css3TransitionEffect extends ShowHideEffect {
  static const List<String> _reservedProperties = const ['transitionProperty', 'transitionDuration'];
  final String _property;
  final String _hideValue;
  final String _showValue;
  final Map<String, String> _animatingOverrides;

  Css3TransitionEffect(this._property, this._hideValue, this._showValue, [Map<String, String> animatingOverrides]) : _animatingOverrides = animatingOverrides == null ? new Map<String, String>() : new Map<String, String>.from(animatingOverrides) {
    assert(!_animatingOverrides.containsKey(_property));
    assert(!_reservedProperties.contains(_property));
    assert(_reservedProperties.every((p) => !_animatingOverrides.containsKey(p)));
  }

  int startShow(Element element, int desiredDuration) {
    return _startAnimation(element, desiredDuration, _hideValue, _showValue);
  }

  int startHide(Element element, int desiredDuration) {
    return _startAnimation(element, desiredDuration, _showValue, _hideValue);
  }

  int _startAnimation(Element element, int desiredDuration, String startValue, String endValue) {
    assert(desiredDuration > 0);

    final localPropsToKeep = [_property];
    localPropsToKeep.addAll(_animatingOverrides.keys);

    final localValues = _recordProperties(element, localPropsToKeep);

    _animatingOverrides.forEach((p, v) {
      element.style.setProperty(p, v);
    });

    element.style.setProperty(_property, startValue);
    _css3TransitionEffectValues.delayStart(element, localValues,
        () => _setShowValue(element, endValue, desiredDuration));
    return desiredDuration;
  }

  void clearAnimation(Element element) {
    final restorValues = _css3TransitionEffectValues.cleanup(element);

    element.style.transitionProperty = '';
    element.style.transitionDuration = '';

    restorValues.forEach((p, v) {
      element.style.setProperty(p, v);
    });
  }

  void _setShowValue(Element element, String value, int desiredDuration) {
    element.style.transitionProperty = _property;
    element.style.transitionDuration = '${desiredDuration}ms';
    element.style.setProperty(_property, value);
  }

  static Map<String, String> _recordProperties(Element element, Collection<String> properties) {
    final map = new Map<String, String>();

    for(final p in properties) {
      assert(!map.containsKey(p));
      map[p] = element.style.getPropertyValue(p);
    }

    return map;
  }
}

class _css3TransitionEffectValues {
  static final Expando<_css3TransitionEffectValues> _values =
      new Expando<_css3TransitionEffectValues>("_css3TransitionEffectValues");

  final Element element;
  final Map<String, String> originalValues;
  int timeoutHandle = null;

  _css3TransitionEffectValues(this.element, this.originalValues);

  Map<String, String> _cleanup() {
    if(timeoutHandle != null) {
      window.clearTimeout(timeoutHandle);
      timeoutHandle = null;
    }

    return originalValues;
  }

  static void delayStart(Element element, Map<String, String> originalValues, Action0 action) {
    assert(_values[element] == null);

    final value = _values[element] = new _css3TransitionEffectValues(element, originalValues);

    value.timeoutHandle = window.setTimeout(() {
      assert(value.timeoutHandle != null);
      value.timeoutHandle = null;
      action();
    }, 1);

  }

  static Map<String, String> cleanup(Element element) {
    final value = _values[element];
    assert(value != null);
    _values[element] = null;
    return value._cleanup();
  }
}


