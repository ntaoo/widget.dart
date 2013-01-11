library hide_show;

import 'dart:html';
import '../packages/bot/bot.dart';
import '../lib/effects.dart';

const int _duration = null;

final element = query('.content');

final actions = {
  'Show': (Element element, ShowHideEffect effect, int duration) => ShowHide.show(element, effect: effect, duration: duration),
  'Hide': (Element element, ShowHideEffect effect, int duration) => ShowHide.hide(element, effect: effect, duration: duration),
  'Toggle': (Element element, ShowHideEffect effect, int duration) => ShowHide.toggle(element, effect: effect, duration: duration)
};

void main() {
  final effects =
    {
     'Default' : null,
     'Fade': new FadeEffect(),
     'Scale': new ScaleEffect(),
     'Spin': new SpinEffect()
  };

  final effectsDiv = query('#effects');
  effects.forEach((name, effect) {
    effectsDiv.append(_createEffectDiv(name, effect));
  });
}

Element _createEffectDiv(String name, ShowHideEffect effect) {
  final row = new DivElement();
  row.append(new SpanElement()..appendText(name));


  final div = new DivElement()
    ..classes.add('btn-group');

  actions.forEach((actionName, action) {
    final button = new ButtonElement()
      ..appendText(actionName)
      ..classes.add('btn')
      ..on.click.add((_) => action(element, effect, _duration));

    div.append(button);
  });

  row.append(div);

  return row;

}

final ShowHideEffect _effect = new ScaleEffect();

void _show(args) {
  _forAllContent((e) => ShowHide.show(e, duration: _duration, effect: _effect));
}

void _hide(args) {
  _forAllContent((e) => ShowHide.hide(e, duration: _duration, effect: _effect));
}

void _toggle(args) {
  _forAllContent((e) => ShowHide.toggle(e, duration: _duration, effect: _effect));
}

void _forAllContent(Func1<Element, Future> action) {
  queryAll('.content').forEach((e) => _applyAnimation(e, action));
}

void _applyAnimation(Element element, Func1<Element, Future> action) {
  action(element)
    ..transformException((ex) => print(ex));
}
