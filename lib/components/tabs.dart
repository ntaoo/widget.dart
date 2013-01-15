import 'dart:html';
import 'package:web_ui/web_ui.dart';
import 'package:widget/effects.dart';
import 'package:bot/bot.dart';

// TODO:TEST: no active tabs -> first is active
// TODO:TEST: 2+ active tabs -> all but first is active
// TODO:TEST: no tabs -> no crash

class Tabs extends WebComponent {
  static const String _activeTabAttribute = 'active';
  static const String _targetAttribute = 'target';

  @protected
  void inserted() {
    _ensureAtMostOneTabActive();
  }

  void _ensureAtMostOneTabActive() {
    final tabs = this.queryAll('x-tabs > .tabs > x-tab');
    Element activeTab = null;
    tabs.forEach((Element tab) {
      if(tab.attributes.containsKey(_activeTabAttribute)) {
        if(activeTab == null) {
          activeTab = tab;
        } else {
          tab.attributes.remove(_activeTabAttribute);
        }
      }
    });

    if(activeTab == null && !tabs.isEmpty) {
      activeTab = tabs[0];
      activeTab.attributes[_activeTabAttribute] = _activeTabAttribute;
    }

    String target = null;
    if(activeTab != null && activeTab.attributes.containsKey(_targetAttribute)) {
      target = activeTab.attributes[_targetAttribute];
    }
    _updateContent(target);
  }

  void _updateContent(String target) {
    final content = this.queryAll('x-tabs > .content > *');

    Element targetContent = null;
    content.forEach((Element contentElement) {
      if(contentElement.id == target && targetContent == null) {
        targetContent = contentElement;
        targetContent.classes.add(_activeTabAttribute);
      } else {
        contentElement.classes.remove(_activeTabAttribute);
      }
    });
  }
}
