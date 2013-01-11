library hide_show;

import 'dart:html';
import 'package:bot/bot.dart';
import 'package:widget/effects.dart';

const int _duration = null;
final EffectTiming _timing = null;

void main() {
  final effects =
    {
     'Default' : null,
     'Door': new DoorEffect(),
     'Fade': new FadeEffect(),
     'Scale': new ScaleEffect(),
     'Scale [roll up]': new ScaleEffect(orientation: Orientation.VERTICAL, yOffset: VerticalAlignment.TOP),
     'Scale [corner]': new ScaleEffect(yOffset: VerticalAlignment.TOP, xOffset: HorizontalAlignment.LEFT),
     'Shrink': new ShrinkEffect(),
     'Spin': new SpinEffect()
  };

  final effectsDiv = query('#effects');
  effects.forEach((name, effect) {
    final button = new ButtonElement()
      ..appendText(name)
      ..classes.add('btn')
      ..on.click.add((_) => _toggle(effect));
    effectsDiv.append(button);
  });
}

void _toggle(ShowHideEffect effect) {
  queryAll('.content').forEach((Element e) {
    ShowHide.toggle(e, effect: effect, duration: _duration, effectTiming: _timing);
  });
}
