import 'dart:html';
import 'package:web_ui/web_ui.dart';
import 'package:widget/effects.dart';

class Expander extends WebComponent {
  const String _expanderDivSelector = '#expander-content-x';
  static final ShowHideEffect _effect = new ShrinkEffect();

  bool _isExpanded = true;
  DivElement _expanderDiv;

  bool get isExpanded => _isExpanded;

  String get header => attributes['header'];

  void set header(String value) {
    attributes['header'] = value;
  }

  void inserted() {
    assert(_expanderDiv == null);
    _expanderDiv = this.query(_expanderDivSelector);
    assert(_expanderDiv != null);
  }

  void removed() {
    assert(_expanderDiv != null);
    _expanderDiv = null;
  }

  void _toggle() {
    assert(_expanderDiv != null);
    if(_isExpanded) {
      ShowHide.hide(_expanderDiv, effect: _effect);
    } else {
      ShowHide.show(_expanderDiv, effect: _effect);
    }
    _isExpanded = !_isExpanded;
  }
}
