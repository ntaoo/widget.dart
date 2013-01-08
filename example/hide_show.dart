library hide_show;

import 'dart:html';
import 'package:bot/bot.dart';

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

void _forAllContent(Action1<Element> action) {
  queryAll('.content').forEach(action);
}

class ShowHide {
  void show(Element element) {
    print('showing $element');
  }
  void hide(Element element) {
    print('hiding $element');
  }
  void toggle(Element element) {
    print('toggling $element');
  }
}
