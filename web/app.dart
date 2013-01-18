import 'dart:html';

void main() {
  window.on.hashChange.add(_onNavigate);
}

void _onNavigate(HashChangeEvent e) {
  final matches = _hashBitRegEx.firstMatch(e.newUrl);
  if(matches != null) {
    final elementId = matches[1];

    final element = query('#$elementId');
    if(element != null) {
      _flashElement(element);
    }
  }
}

void _flashElement(Element element) {
  element.classes.add(_highlightedClass);
  window.setTimeout(() => element.classes.remove(_highlightedClass), 1000);
}

const _highlightedClass = 'highlighted';

// these are the rules applied by build.dart
final _hashBitRegEx = new RegExp(r'.*#([a-z_]+)');
