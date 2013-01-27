import 'dart:html';
import 'package:web_ui/web_ui.dart';
import 'package:widget/effects.dart';
import 'package:widget/widget.dart';
import 'package:bot/bot.dart';

/**
 * [Accordion] wraps a set of [Collapse] elements and ensures only one is visible
 * at a time.
 *
 * See [Collapse] for details on how content is interpreted.
 */
class Accordion extends WebComponent {
  @protected
  void created() {
    this.on[ShowHideComponent.TOGGLE_EVENT_NAME].add(_onOpen);
  }

  @protected
  void inserted() {
    // collapse all 'collapse' children
    _getAllCollapseElements()
      .mappedBy((Element e) => e.xtag)
      .forEach((ShowHideComponent e) {
        e.hide();
      });
  }

  List<Element> _getAllCollapseElements() => this.queryAll('x-accordion > x-collapse');

  void _onOpen(Event openEvent) {
    assert(openEvent.type == ShowHideComponent.TOGGLE_EVENT_NAME);
    if(openEvent.target is UnknownElement) {
      final UnknownElement target = openEvent.target;
      final ShowHideComponent shc = target.xtag as ShowHideComponent;
      if(shc != null) {
        _onShowHideToggle(shc);
      }
    }
  }

  void _onShowHideToggle(ShowHideComponent shc) {
    if(shc.isShown) {
      _getAllCollapseElements()
        .mappedBy((Element e) => e.xtag)
        .where((e) => e != shc)
        .forEach((ShowHideComponent e) {
          e.hide();
        });
    }
  }
}
