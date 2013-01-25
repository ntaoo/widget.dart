import 'dart:async';
import 'dart:html';
import 'package:bot/bot.dart';
import 'package:web_ui/web_ui.dart';
import 'package:widget/effects.dart';
import 'package:widget/widget.dart';

// TODO: support click on child elements of header with data-toggle="dropdown"

class Dropdown extends WebComponent implements ShowHideComponent {
  static final ShowHideEffect _effect = new FadeEffect();
  static const int _duration = 100;

  bool _isShown = false;

  bool get isShown => _isShown;

  void set isShown(bool value) {
    if(value != _isShown) {
      _isShown = value;
      final action = _isShown ? ShowHideAction.SHOW : ShowHideAction.HIDE;

      final headerContainer = this.query('x-dropdown > .button-container-x');

      if(headerContainer != null) {
        if(_isShown) {
          headerContainer.classes.add('open');
        } else {
          headerContainer.classes.remove('open');
        }
      }

      final contentDiv = this.query('x-dropdown > .dropdown-content-x');
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
    final button = this.query('x-dropdown > .button-container-x > button');
    if(event.target == button && !event.defaultPrevented) {
      toggle();
      event.preventDefault();
    }
  }
}
