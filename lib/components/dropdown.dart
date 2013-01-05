import 'dart:html';
import 'package:web_ui/web_ui.dart';

class Dropdown extends WebComponent {
  const String _dropdownDivSelector = '#-x-dropdown-container';

  bool _isExpanded = false;
  DivElement _expanderDiv;
  Element _headerElem;

  bool get isExpanded => _isExpanded;

  void set isExpanded(bool value) {
    if(value != _isExpanded) {
      _isExpanded = value;
      if(_isExpanded) {
        _expanderDiv.style.display = '';
        _headerElem.style.background = '#EEE';
      } else {
        _expanderDiv.style.display = 'none';
        _headerElem.style.background = 'lightgray';
      }
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
