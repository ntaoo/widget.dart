import 'dart:html';
import 'package:bot/bot.dart';
import 'package:web_ui/web_ui.dart';
import 'package:widget/effects.dart';
import 'package:widget/widget.dart';

// TODO: support click on child elements of header with data-toggle="dropdown"

class Dropdown extends WebComponent implements ShowHideComponent {
  static final ShowHideEffect _effect = new FadeEffect();
  static const int _duration = 100;

  bool _isExpanded = false;

  bool get isExpanded => _isExpanded;

  void set isExpanded(bool value) {
    if(value != _isExpanded) {
      _isExpanded = value;
      final action = _isExpanded ? ShowHideAction.SHOW : ShowHideAction.HIDE;

      final headerContainer = this.query('x-dropdown > .button-container-x');

      if(headerContainer != null) {
        if(_isExpanded) {
          headerContainer.classes.add('open');
        } else {
          headerContainer.classes.remove('open');
        }
      }

      final contentDiv = this.query('x-dropdown > .dropdown-content-x');
      if(contentDiv != null) {
        ShowHide.begin(action, contentDiv, effect: _effect);
      }
    }
  }

  void hide() {
    isExpanded = false;
  }

  void show() {
    isExpanded = true;
  }

  void toggle() {
    isExpanded = !isExpanded;
  }

  @protected
  void created() {
    this.onClick.listen(_onClick);
  }

  void _onClick(MouseEvent event) {
    final button = this.query('x-dropdown > .button-container-x > button');
    print(button);
    print(event.target);
    if(event.target == button && !event.defaultPrevented) {
      toggle();
      event.preventDefault();
    }
  }
}
