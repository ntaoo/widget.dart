import 'dart:html';
import 'package:web_ui/web_ui.dart';
import 'package:bot/bot.dart';
import 'package:widget/effects.dart';
import 'package:widget/widget.dart';

class Alert extends WebComponent implements ShowHideComponent {
  @protected
  void created() {
    this.onClick.listen(_onClick);
  }

  void _onClick(MouseEvent event) {
    if(!event.defaultPrevented) {
      final Element target = event.target as Element;
      if(target != null && target.dataAttributes['dismiss'] == 'alert') {
        hide();
      }
    }
  }

  void hide() {
    _animate(ShowHideAction.HIDE);
  }

  void show() {
    _animate(ShowHideAction.SHOW);
  }

  void toggle() {
    _animate(ShowHideAction.TOGGLE);
  }

  void _animate(ShowHideAction action) {
    ShowHide.begin(action, this, effect: new ScaleEffect());
  }
}
