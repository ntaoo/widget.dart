import 'dart:html';
import 'package:bot/bot.dart';
import 'package:web_ui/web_ui.dart';
import 'package:widget/effects.dart';

class Expander extends WebComponent {
  static const String _openName = 'open';
  static const String _expanderDivSelector = '#expander-content-x';
  static final ShowHideEffect _effect = new ShrinkEffect();

  EventListenerList _onOpen;

  bool _isExpanded = true;
  DivElement _expanderDiv;
  Element _header;

  bool get isExpanded => _isExpanded;

  void set isExpanded(bool value) {
    if(value != _isExpanded) {
      _isExpanded = value;
      _updateElements();

      if(_isExpanded) {
        _raiseOpen();
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
    assert(_expanderDiv != null);
    isExpanded = !isExpanded;
  }

  @protected
  void inserted() {
    assert(_expanderDiv == null);
    _expanderDiv = this.query(_expanderDivSelector);
    assert(_expanderDiv != null);
    _updateElements(true);

    assert(_header == null);
    _header = this.query('header');
    if(_header != null) {
      _header.on.click.add((_) => toggle());
    }
  }

  @protected
  void removed() {
    assert(_expanderDiv != null);
    _expanderDiv = null;

    // TODO: some how remove the click handler?
    _header = null;
  }

  // DARTBUG:
  // TODO: Need a way to dispatch my own events
  void _raiseOpen() {
    onOpen.dispatch(new Event(_openName));
  }

  void _updateElements([bool skipAnimation = false]) {
    if(_expanderDiv != null) {
      final action = _isExpanded ? ShowHideAction.SHOW : ShowHideAction.HIDE;
      final effect = skipAnimation ? null : _effect;
      ShowHide.begin(action, _expanderDiv, effect: effect);
    }
  }
}
