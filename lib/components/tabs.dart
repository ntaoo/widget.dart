import 'dart:html';
import 'package:web_ui/web_ui.dart';
import 'package:bot/bot.dart';
import 'package:widget/effects.dart';
import 'package:widget/widget.dart';

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
    final tabs = _getAllTabs();

    final matchingTab = $(tabs).singleOrDefault((e) => e == tabElement);
    if(matchingTab != null) {
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

  List<Element> _getAllTabs() => this.queryAll('x-tabs > .tabs > x-tab');

  SwapComponent get _swap => this.query('x-tabs > x-swap').xtag;

  void _ensureAtMostOneTabActive() {
    final tabs = _getAllTabs();
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
    final items = _swap.items;

    final targetItem = $(items).firstOrDefault((e) => e.id == target);
    _swap.showItem(targetItem);
  }
}
