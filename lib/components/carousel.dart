import 'dart:async';
import 'package:polymer/polymer.dart';
import 'package:widget/effects.dart';
import 'package:widget/widget.dart';

// TODO: option to enable/disable wrapping. Disable buttons if the end is hit...

/**
 * [CarouselWidget] allows moving back and forth through a set of child elements.
 *
 * It is based on a [similar component](http://twitter.github.com/bootstrap/javascript.html#carousel)
 * in Bootstrap.
 *
 * [CarouselWidget] leverages the [Swap] component to render the transition between items.
 */
@CustomTag('carousel-widget')
class CarouselWidget extends PolymerElement {

  static const _duration = 1000;

  final ShowHideEffect _fromTheLeft = new SlideEffect(xStart: HorizontalAlignment.LEFT);
  final ShowHideEffect _fromTheRight = new SlideEffect(xStart: HorizontalAlignment.RIGHT);
  
  bool get applyAuthorStyles => true;

  Future<bool> _pendingAction = null;

  Future<bool> next() => _moveDelta(true);

  Future<bool> previous() => _moveDelta(false);

  void _next(event, detail, target) {
    next();
  }

  void _previous(event, detail, target) {
    previous();
  }

  SwapComponent get _swap =>
      getShadowRoot('carousel-widget').query('.carousel > swap-widget').xtag;

  Future<bool> _moveDelta(bool doNext) {
    if (_pendingAction != null) {
      // Ignore all calls to moveDelta until the current pending action is
      // complete to avoid ugly janky UI.
      return _pendingAction.then((_) => false);
    }

    final swap = _swap;
    assert(swap != null);
    if (swap.items.length == 0) {
      return new Future.value(false);
    }

    assert(doNext != null);
    final delta = doNext ? 1 : -1;

    ShowHideEffect showEffect, hideEffect;
    if (doNext) {
      showEffect = _fromTheRight;
      hideEffect = _fromTheLeft;
    } else {
      showEffect = _fromTheLeft;
      hideEffect = _fromTheRight;
    }

    final activeIndex = _swap.activeItemIndex;

    final newIndex = (activeIndex + delta) % _swap.items.length;

    _pendingAction = _swap.showItemAtIndex(newIndex, effect: showEffect,
        hideEffect: hideEffect, duration: _duration);
    _pendingAction.whenComplete(() { _pendingAction = null; });
    return _pendingAction;
  }
}
