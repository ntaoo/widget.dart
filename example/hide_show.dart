library hide_show;

import 'dart:html';
import 'package:bot/bot.dart';
import 'package:widget/effects.dart';

void main() {
  query('#show').on.click.add(_show);
  query('#hide').on.click.add(_hide);
  query('#toggle').on.click.add(_toggle);
}

final _showHide = new ShowHide();

void _show(args) {
  print('show');
  _forAllContent(_showHide.show);
}

void _hide(args) {
  print('hide');
  _forAllContent(_showHide.hide);
}

void _toggle(args) {
  print('toggle');
  _forAllContent(_showHide.toggle);
}

void _forAllContent(Func1<Element, Future> action) {
  queryAll('.content').forEach((e) => _applyAnimation(e, action));
}

void _applyAnimation(Element element, Func1<Element, Future> action) {
  print('starting the thing');

  action(element)
    ..transform((foo) => print(foo))
    ..transformException((foo) => print(foo));
}
