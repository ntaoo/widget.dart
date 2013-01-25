import 'dart:async';
import 'dart:html';
import 'package:bot/bot.dart';
import 'package:web_ui/web_ui.dart';
import 'package:widget/effects.dart';
import 'package:widget/widget.dart';

// TODO: support click on child elements of header with data-toggle="expander"

class Expander extends WebComponent implements ShowHideComponent {
  static const String _expanderDivSelector = '.expander-body-x';
  static final ShowHideEffect _effect = new ShrinkEffect();

  bool _isShown = true;

  bool get isShown => _isShown;

  void set isShown(bool value) {
    assert(value != null);
    if(value != _isShown) {
      _isShown = value;
      _updateElements();

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
    this.on.click.add(_onClick);
  }

  @protected
  void inserted() {
    _updateElements(true);
  }

  void _onClick(MouseEvent e) {
    if(!e.defaultPrevented) {
      final header = this.query('x-expander > header');
      if(e.target == header) {
        toggle();
        e.preventDefault();
      }
    }
  }

  void _updateElements([bool skipAnimation = false]) {
    final expanderDiv = this.query(_expanderDivSelector);
    if(expanderDiv != null) {
      final action = _isShown ? ShowHideAction.SHOW : ShowHideAction.HIDE;
      final effect = skipAnimation ? null : _effect;
      ShowHide.begin(action, expanderDiv, effect: effect);
    }
  }
}
