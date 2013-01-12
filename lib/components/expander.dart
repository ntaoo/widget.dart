import 'dart:html';
import 'package:web_ui/web_ui.dart';
import 'package:widget/effects.dart';

class Expander extends WebComponent {
  const String _expanderDivSelector = '#expander-content-x';
  static final ShowHideEffect _effect = new ShrinkEffect();

  bool _isExpanded = true;
  DivElement _expanderDiv;
  Element _header;

  bool get isExpanded => _isExpanded;

  void inserted() {
    assert(_expanderDiv == null);
    _expanderDiv = this.query(_expanderDivSelector);
    assert(_expanderDiv != null);

    assert(_header == null);
    _header = this.query('header');
    if(_header != null) {
      _header.on.click.add((_) => _toggle());
    }
  }

  void removed() {
    assert(_expanderDiv != null);
    _expanderDiv = null;

    // TODO: some how remove the click handler?
    _header = null;
  }

  void _toggle() {
    assert(_expanderDiv != null);
    final action = _isExpanded ? ShowHideAction.HIDE : ShowHideAction.SHOW;
    ShowHide.begin(action, _expanderDiv, effect: _effect);
    _isExpanded = !_isExpanded;
  }
}
