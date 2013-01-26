import 'dart:async';
import 'dart:html';
import 'package:bot/bot.dart';
import 'package:web_ui/web_ui.dart';
import 'package:widget/effects.dart';
import 'package:widget/widget.dart';

// TODO: esc and click outside to collapse
// https://github.com/kevmoo/widget.dart/issues/14

class Dropdown extends WebComponent implements ShowHideComponent {
  static final ShowHideEffect _effect = new FadeEffect();
  static const int _duration = 100;

  bool _isShown = false;

  bool get isShown => _isShown;

  void set isShown(bool value) {
    if(value != _isShown) {
      _isShown = value;
      final action = _isShown ? ShowHideAction.SHOW : ShowHideAction.HIDE;

      final wrapper = this.query('x-dropdown > .dropdown');

      if(wrapper != null) {
        if(_isShown) {
          wrapper.classes.add('open');
        } else {
          wrapper.classes.remove('open');
        }
      }

      final contentDiv = this.query('x-dropdown > .dropdown-menu');
      if(contentDiv != null) {
        ShowHide.begin(action, contentDiv, effect: _effect);
      }
      ShowHideComponent.dispatchToggleEvent(this);
    }
  }

  Stream<Event> get onToggle => ShowHideComponent.toggleEvent.forTarget(this);

  void hide() {
    isShown = false;
  }

  void show() {
    isShown = true;
  }

  void toggle() {
    isShown = !isShown;
  }

  @protected
  void created() {
    this.onClick.listen(_onClick);
  }

  void _onClick(MouseEvent event) {
    if(!event.defaultPrevented) {
      final Element target = event.target as Element;
      if(target != null && target.dataAttributes['toggle'] == 'dropdown') {
        toggle();
        event.preventDefault();
      }
    }
  }
}
