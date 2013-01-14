import 'dart:html';
import 'package:web_ui/web_ui.dart';
import 'package:widget/effects.dart';

class Accordion extends WebComponent {
  void created() {
  }

  void inserted() {
    // collapse all expander children
    this.queryAll('x-expander')
      .map((Element e) => e.xtag)
      .forEach((e) {
        e.isExpanded = false;
      });

    this.on['open'].add(_onOpen);
  }

  void removed() {
  }

  void _onOpen(Event openEvent) {
    assert(openEvent.type == 'open');
    if(openEvent.target is UnknownElement) {
      final UnknownElement target = openEvent.target;
      onExpanderOpen(target.xtag);
    }
  }

  void onExpanderOpen(dynamic expander) {
    this.queryAll('x-expander')
    .map((Element e) => e.xtag)
    .filter((e) => e != expander)
    .forEach((e) {
      e.isExpanded = false;
    });
  }
}
