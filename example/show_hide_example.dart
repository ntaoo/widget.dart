library hide_show;

import 'dart:html';
import 'package:bot/bot.dart';
import 'package:widget/effects.dart';

void main() {
  query('#show').on.click.add(_show);
  query('#hide').on.click.add(_hide);
  query('#toggle').on.click.add(_toggle);
}

final _showHide = new ShowHide(new FadeEffect());

void _show(args) {
  _forAllContent(_showHide.show);
}

void _hide(args) {
  _forAllContent(_showHide.hide);
}

void _toggle(args) {
  _forAllContent(_showHide.toggle);
}

void _forAllContent(Func1<Element, Future> action) {
  queryAll('.content').forEach((e) => _applyAnimation(e, action));
}

void _applyAnimation(Element element, Func1<Element, Future> action) {
  _updateThing('starting...');
  action(element)
    ..then(_updateThing)
    ..transformException((ex) => print(ex));
}

void _updateThing(value) {
  if(value == null) {
    value = '~null~';
  }
  query('#lastValue').innerHtml = value.toString();
}
