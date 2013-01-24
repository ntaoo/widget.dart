import 'dart:html';
import 'package:web_ui/web_ui.dart';
import 'package:bot/bot.dart';
import 'package:widget/effects.dart';
import 'package:widget/widget.dart';

// TODO: keyboard support for ESC and such
// TODO: backdrop

class Modal extends WebComponent implements ShowHideComponent {
  final _effect = new ScaleEffect();

  @protected
  void created() {
    this.onClick.listen(_onClick);
  }

  void _onClick(MouseEvent event) {
    if(!event.defaultPrevented) {
      final Element target = event.target as Element;
      if(target != null && target.dataAttributes['dismiss'] == 'modal') {
        hide();
      }
    }
  }

  void show() {
    ShowHide.show(this, effect: _effect);
  }

  void hide() {
    ShowHide.hide(this, effect: _effect);
  }
}
