part of effects;

class ElementAnimation extends AnimationCore {
  final Element element;
  final String _property;
  final Object _target;

  String _initialValue;

  ElementAnimation(this.element, this._property, this._target,
      {num duration: 400}) :
        super(duration) {

  }

}
