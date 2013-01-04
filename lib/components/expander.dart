import 'dart:html';
import 'package:web_ui/web_ui.dart';

class Expander extends WebComponent {
  const String _expanderDivSelector = '#-x-expander-container';

  bool _isExpanded = true;
  DivElement _expanderDiv;

  bool get isExpanded => _isExpanded;

  String get header => attributes['header'];

  void set header(String value) {
    attributes['header'] = value;
  }

  void inserted() {
    assert(_expanderDiv == null);
    _expanderDiv = query(_expanderDivSelector);
    assert(_expanderDiv != null);
  }

  void removed() {
    assert(_expanderDiv != null);
    _expanderDiv = null;
  }

  void _toggle() {
    assert(_expanderDiv != null);
    if(_isExpanded) {
      _expanderDiv.style.display = 'none';
    } else {
      _expanderDiv.style.display = '';
    }
    _isExpanded = !_isExpanded;
  }
}
