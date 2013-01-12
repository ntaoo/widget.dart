import 'dart:html';
import 'package:web_ui/web_ui.dart';
import 'package:widget/effects.dart';

class Dropdown extends WebComponent {
  const String _dropdownDivSelector = '#dropdown-content-x';
  const String _headerOpenClass = 'dropdown-toggle-x';

  static final ShowHideEffect _effect = new FadeEffect();
  static const int _duration = 100;

  bool _isExpanded = false;
  DivElement _expanderDiv;
  Element _headerElem;

  bool get isExpanded => _isExpanded;

  void set isExpanded(bool value) {
    if(value != _isExpanded) {
      _isExpanded = value;
      final action = _isExpanded ? ShowHideAction.SHOW : ShowHideAction.HIDE;

      if(_isExpanded) {
        _headerElem.classes.add(_headerOpenClass);
      } else {
        _headerElem.classes.remove(_headerOpenClass);
      }

      ShowHide.begin(action, _expanderDiv, effect: _effect);
    }
  }

  void toggle() {
    assert(_expanderDiv != null);
    isExpanded = !isExpanded;
  }

  String get header => attributes['header'];

  void set header(String value) {
    attributes['header'] = value;
  }

  void inserted() {
    assert(_expanderDiv == null);
    assert(_headerElem == null);
    _expanderDiv = this.query(_dropdownDivSelector);
    _headerElem = this.query('header');
    assert(_expanderDiv != null);
    assert(_headerElem != null);
  }

  void removed() {
    assert(_expanderDiv != null);
    assert(_headerElem != null);
    _expanderDiv = null;
    _headerElem = null;
  }
}
