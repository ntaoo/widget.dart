import 'dart:html';
import 'package:web_ui/web_ui.dart';
import 'package:widget/effects.dart';
import 'package:bot/bot.dart';

class Accordion extends WebComponent {
  @protected
  void created() {
    this.on['open'].add(_onOpen);
  }

  @protected
  void inserted() {
    // collapse all expander children
    this.queryAll('x-expander')
      .mappedBy((Element e) => e.xtag)
      .forEach((e) {
        e.isExpanded = false;
      });
  }

  void _onOpen(Event openEvent) {
    assert(openEvent.type == 'open');
    if(openEvent.target is UnknownElement) {
      final UnknownElement target = openEvent.target;
      _onExpanderOpen(target.xtag);
    }
  }

  void _onExpanderOpen(dynamic expander) {
    this.queryAll('x-accordion > x-expander')
    .mappedBy((Element e) => e.xtag)
    .where((e) => e != expander)
    .forEach((e) {
      e.isExpanded = false;
    });
  }
}
