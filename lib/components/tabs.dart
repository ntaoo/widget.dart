import 'dart:html';
import 'package:web_ui/web_ui.dart';
import 'package:widget/effects.dart';
import 'package:bot/bot.dart';

// TODO:TEST: no active tabs -> first is active
// TODO:TEST: 2+ active tabs -> all but first is active
// TODO:TEST: no tabs -> no crash

// TODO: be more careful that the source tab is actually 'ours'

class Tabs extends WebComponent {
  static const String _activeTabAttribute = 'active';
  static const String _targetAttribute = 'target';

  @protected
  void created() {
    this.on.click.add(_clickListener);
  }

  @protected
  void inserted() {
    _ensureAtMostOneTabActive();
  }

  void _clickListener(MouseEvent e) {
    if(!e.defaultPrevented && e.target is Element) {
      final Element target = e.target;
      if(target.tagName.toLowerCase() == 'x-tab') {
        final completed = _tabClick(target);
        if(completed) {
          e.preventDefault();
        }
      }
    }
  }

  bool _tabClick(Element tabElement) {
    assert(tabElement.tagName.toLowerCase() == 'x-tab');

    // it's possible that a nested tab was clicked, which we want to ignore
    // so we're going to go through our 'known' tabs and pick it that way
    final tabs = this.queryAll('x-tabs > .tabs > x-tab');

    final matchingTabs = tabs.filter((e) => e == tabElement);
    assert(matchingTabs.length <= 1);
    if(matchingTabs.length == 1) {
      tabs
        .filter((e) => e != tabElement)
        .forEach((e) {
          e.attributes.remove(_activeTabAttribute);
        });
      tabElement.attributes[_activeTabAttribute] = _activeTabAttribute;
      _updateContentForTab(tabElement);
      return true;
    }
    return false;
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

    _updateContentForTab(activeTab);
  }

  void _updateContentForTab(Element activeTab) {
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
