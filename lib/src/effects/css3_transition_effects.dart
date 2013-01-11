part of effects;

class FadeEffect extends Css3TransitionEffect {
  FadeEffect() : super('opacity', '0', '1');
}

class ShrinkEffect extends Css3TransitionEffect {
  ShrinkEffect() : super('max-height', '0', '500px', {'overflow': 'hidden'});
}

class ScaleEffect extends Css3TransitionEffect {
  ScaleEffect() : super('-webkit-transform', 'scale(0, 0)', 'scale(1, 1)');
}

class SpinEffect extends Css3TransitionEffect {
  SpinEffect() : super('-webkit-transform', 'perspective(600px) rotateX(90deg)', 'perspective(600px) rotateX(0deg)');
}

class DoorEffect extends Css3TransitionEffect {
  DoorEffect() : super('-webkit-transform', 'perspective(1000px) rotateY(90deg)', 'perspective(1000px) rotateY(0deg)',
      {'-webkit-transform-origin': '0% 50%'} );
}

// TODO: this also needs overflow: hidden to be set
// Perhaps some other model for 'helper' properties to be set? Hmm...
class VerticalScaleEffect extends Css3TransitionEffect {
  VerticalScaleEffect() : super('max-height', '0', '720px', {"overflow" : "hidden"} );
}
