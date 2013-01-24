import 'dart:html';
import 'package:web_ui/web_ui.dart';
import 'package:bot/bot.dart';
import 'package:widget/effects.dart';
import 'package:widget/widget.dart';

// TODO: ESC to close

class Modal extends WebComponent implements ShowHideComponent {
  final _effect = new ScaleEffect();

  @protected
  void created() {
    this.style.display = 'none';
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
    ModalManager.show(this, effect: _effect, backdropClickHandler: _onBackdropClicked);
  }

  void hide() {
    ModalManager.hide(this, effect: _effect);
  }

  void _onBackdropClicked() {
    // TODO: ignoring some edge cases here
    // like what if this element has been removed from the tree before the backdrop is clicked
    // ...etc
    hide();
  }
}
