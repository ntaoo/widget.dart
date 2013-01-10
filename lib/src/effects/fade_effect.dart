part of effects;

class FadeEffect extends ShowHideEffect {
  static const int _ms = 2000;
  final Expando<int> _timeoutHandle = new Expando<int>("timeout handle");

  int startShow(Element element) {
    assert(_timeoutHandle[element] == null);
    element.style.opacity = '0';
    element.style.transitionProperty = 'opacity';
    element.style.transitionDuration = '${_ms}ms';

    _timeoutHandle[element] = window.setTimeout(
        () => _setShowValue(element), 1);
    return _ms;
  }

  int startHide(Element element) {
    assert(_timeoutHandle[element] == null);
    element.style.transitionProperty = 'opacity';
    element.style.transitionDuration = '${_ms}ms';
    element.style.opacity = '0';
    return _ms;
  }

  void clearAnimation(Element element) {
    final timeoutHandle = _timeoutHandle[element];
    if(timeoutHandle != null) {
      window.clearTimeout(timeoutHandle);
      _timeoutHandle[element] = null;
    }

    element.style.transitionProperty = '';
    element.style.transitionDuration = '';
    element.style.opacity = '';
  }

  void _setShowValue(Element element) {
    assert(_timeoutHandle[element] != null);
    _timeoutHandle[element] = null;
    element.style.opacity = '1';
  }
}
