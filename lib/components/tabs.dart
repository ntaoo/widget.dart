import 'dart:html';
import 'package:web_ui/web_ui.dart';
import 'package:bot/bot.dart';
import 'package:widget/effects.dart';
import 'package:widget/widget.dart';

// TODO:TEST: no active tabs -> first is active
// TODO:TEST: 2+ active tabs -> all but first is active
// TODO:TEST: no tabs -> no crash

// TODO: be more careful that the source tab is actually 'ours'
// TODO: support click on child elements with data-toggle="tab"

class Tabs extends WebComponent {
  @protected
  void created() {
    this.on.click.add(_clickListener);
  }

  @protected
  void inserted() {
    _ensureAtMostOneTabActive();
  }

  void _clickListener(MouseEvent e) {
    if(!e.defaultPrevented && _getAllTabs().contains(e.target)) {
      final Element target = e.target;
      final completed = _tabClick(target);
      if(completed) {
        e.preventDefault();
      }
    }
  }

  bool _tabClick(Element tabElement) {
    assert(tabElement.tagName.toLowerCase() == 'header');

    // it's possible that a nested tab was clicked, which we want to ignore
    // so we're going to go through our 'known' tabs and pick it that way
    final tabs = _getAllTabs();

    final matchingTab = $(tabs).singleMatching((e) => e == tabElement);
    if(matchingTab != null) {
      tabs
        .where((e) => e != tabElement)
        .forEach((e) {
          e.dataAttributes.remove('active');
        });
      tabElement.dataAttributes['active'] = 'active';
      _updateContentForTab(tabElement);
      return true;
    }
    return false;
  }

  List<Element> _getAllTabs() => this.queryAll('x-tabs > .tabs > header');

  SwapComponent get _swap => this.query('x-tabs > x-swap').xtag;

  void _ensureAtMostOneTabActive() {
    final tabs = _getAllTabs();
    Element activeTab = null;
    tabs.forEach((Element tab) {
      if(tab.dataAttributes['active'] == 'active') {
        if(activeTab == null) {
          activeTab = tab;
        } else {
          tab.dataAttributes.remove('active');
        }
      }
    });

    if(activeTab == null && !tabs.isEmpty) {
      activeTab = tabs[0];
      activeTab.dataAttributes['active'] = 'active';
    }

    _updateContentForTab(activeTab);
  }

  void _updateContentForTab(Element activeTab) {
    String target = null;
    if(activeTab != null && activeTab.dataAttributes['target'] != null) {
      target = activeTab.dataAttributes['target'];
    }
    _updateContent(target);
  }

  void _updateContent(String target) {
    final items = _swap.items;

    final targetItem = $(items).firstMatching((e) => e.id == target);
    _swap.showItem(targetItem);
  }
}
