library x_swap;

import 'dart:html';
import 'package:web_ui/web_ui.dart';
import 'package:bot/bot.dart';
import 'package:widget/effects.dart';
import 'package:widget/widget.dart';

// TODO: cleaner about having requests pile up...handle the pending change cleanly

class Swap extends WebComponent implements SwapComponent {
  static const _activeClass = 'active';
  static const _dirClassPrev = 'prev';

  Element _contentElement;

  int get activeItemIndex {
    return items.indexOf(activeItem);
  }

  Element get activeItem {
    return $(items).singleOrDefault((e) => e.classes.contains(_activeClass));
  }

  List<Element> get items => _contentElement.children;

  Future<bool> showItemAtIndex(int index, {ShowHideEffect effect, int duration, EffectTiming effectTiming, ShowHideEffect hideEffect}) {
    // TODO: support hide all if index == null

    final newActive = items[index];
    return showItem(newActive, effect: effect, duration: duration, effectTiming: effectTiming, hideEffect: hideEffect);
  }

  Future<bool> showItem(Element item, {ShowHideEffect effect, int duration, EffectTiming effectTiming, ShowHideEffect hideEffect}) {
    assert(items.contains(item));

    final oldActiveChild = activeItem;
    if(oldActiveChild == item) {
      return new Future<bool>.immediate(true);
    }

    [oldActiveChild, item].forEach((e) => e.classes.remove(_dirClassPrev));

    oldActiveChild.classes.remove(_activeClass);
    oldActiveChild.classes.add(_dirClassPrev);

    item.classes.add(_activeClass);

    return Swapper.swap(_contentElement, item, effect: effect, duration: duration, effectTiming: effectTiming, hideEffect: hideEffect)
        ..onComplete((future) {
          oldActiveChild.classes.remove(_dirClassPrev);
          if(!future.hasValue) {
            // TODO: how to handle such things? Hmm...
            print("Exception! ${future.exception} -- ${future.stackTrace}");
          }
        });
  }

  @protected
  void inserted() {
    _contentElement = this.query('x-swap > .content');
    assert(_contentElement != null);
    _initialize();
  }

  void _initialize() {
    // if there are any elements, make sure one and only one is 'active'
    final activeFigures = new List<Element>.from(items.filter((e) => e.classes.contains(_activeClass)));
    if(activeFigures.length == 0) {
      if(items.length > 0) {
        // marke the first of the figures as active
        items[0].classes.add(_activeClass);
      }
    } else {
      activeFigures.getRange(1, activeFigures.length - 1)
        .forEach((e) => e.classes.remove(_activeClass));
    }

    // A bit of a hack. Because we call Swap w/ two displayed items:
    // one marked 'prev' and one marked 'next', Swap tries to hide one of them
    // this only causes a problem when clicking right the first time, since all
    // times after, the cached ShowHideState of the item is set
    // So...we're going to walk the showHide states of all children now
    // ...and ignore the result...but just to populate the values
    items.forEach((f) => ShowHide.getState(f));
  }
}
