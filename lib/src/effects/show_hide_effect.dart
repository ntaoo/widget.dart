part of effects;

class ShowHideEffect {

  const ShowHideEffect();

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

  static ShowHideEffect _orDefault(ShowHideEffect effect) {
    return effect == null ? const ShowHideEffect() : effect;
  }
}
