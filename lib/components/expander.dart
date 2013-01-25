import 'dart:html';
import 'package:bot/bot.dart';
import 'package:web_ui/web_ui.dart';
import 'package:widget/effects.dart';

// TODO: support click on child elements of header with data-toggle="expander"

class Expander extends WebComponent {
  static const String _openName = 'open';
  static const String _expanderDivSelector = '.expander-body-x';
  static final ShowHideEffect _effect = new ShrinkEffect();

  EventListenerList _onOpen;

  bool _isExpanded = true;

  bool get isExpanded => _isExpanded;

  void set isExpanded(bool value) {
    if(value != _isExpanded) {
      _isExpanded = value;
      _updateElements();

      if(_isExpanded) {
        onOpen.dispatch(new Event(_openName));
      }
    }
  }

  EventListenerList get onOpen {
    if(_onOpen == null) {
      _onOpen = super.on[_openName];
    }
    return _onOpen;
  }

  void toggle() {
    isExpanded = !isExpanded;
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
      final action = _isExpanded ? ShowHideAction.SHOW : ShowHideAction.HIDE;
      final effect = skipAnimation ? null : _effect;
      ShowHide.begin(action, expanderDiv, effect: effect);
    }
  }
}
