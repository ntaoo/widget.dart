part of effects;

class ShowHideEffect {

  @protected
  int startShow(Element element, int desiredDuration) {
    return 0;
  }

  @protected
  int startHide(Element element, int desiredDuration) {
    return 0;
  }

  @protected
  void clearAnimation(Element element) {
    // no op here
  }
}
