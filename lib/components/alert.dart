import 'dart:html';
import 'package:web_ui/web_ui.dart';
import 'package:bot/bot.dart';
import 'package:widget/effects.dart';

class Alert extends WebComponent {
  @protected
  void created() {
    this.onClick.listen(_onClick);
  }

  void _onClick(MouseEvent event) {
    if(!event.defaultPrevented) {
      final Element target = event.target as Element;
      if(target != null && target.dataAttributes['dismiss'] == 'alert') {
        dismiss();
      }
    }
  }

  void dismiss() {
    ShowHide.hide(this, effect: new ScaleEffect());
  }
}
