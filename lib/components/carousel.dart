import 'dart:html';
import 'package:web_ui/web_ui.dart';
import 'package:bot/bot.dart';
import 'package:widget/effects.dart';

// TODO: option to enable/disable wrapping. Disable buttons if the end is hit...
// TODO: cleaner about having requests pile up...handle the pending change cleanly

class Carousel extends WebComponent {
  static const _activeClass = 'active';
  static const _figuresQuery = 'x-carousel > .content > figure';
  static final _activeFiguresQuery = _figuresQuery.concat('.active');
  static final _controlsQuery = 'x-carousel > a.carousel-control';
  static const _dirClassNext = 'next', _dirClassPrev = 'prev';

  final ShowHideEffect _fromTheLeft = new SlideEffect(xStart: HorizontalAlignment.LEFT);
  final ShowHideEffect _fromTheRight = new SlideEffect(xStart: HorizontalAlignment.RIGHT);

  void inserted() {
    _initialize();
  }

  Future<bool> next() => _moveDelta(true);

  Future<bool> previous() => _moveDelta(false);

  Future<bool> _moveDelta(bool doNext) {
    assert(doNext != null);
    final delta = doNext ? 1 : -1;

    ShowHideEffect showEffect, hideEffect;
    if(doNext) {
      showEffect = _fromTheRight;
      hideEffect = _fromTheLeft;
    } else {
      showEffect = _fromTheLeft;
      hideEffect = _fromTheRight;
    }

    final allFigures = this.queryAll(_figuresQuery);
    if(allFigures.isEmpty) {
      // nothing to show...so
      return new Future.immediate(false);
    }

    final activeFigure = $(allFigures).singleOrDefault((e) => e.classes.contains(_activeClass));
    assert(activeFigure != null);
    final activeIndex = allFigures.indexOf(activeFigure);
    assert(activeIndex >= 0);

    final newIndex = (activeIndex + delta) % allFigures.length;
    final newActive = allFigures[newIndex];

    _removeTransitionClasses([activeFigure, newActive]);

    activeFigure.classes.add(_dirClassPrev);
    activeFigure.classes.remove(_activeClass);

    newActive.classes.add(_dirClassNext);
    newActive.classes.add(_activeClass);

    return Swapper.swap(_getFigureHost(), newActive, effect: showEffect, hideEffect: hideEffect)
        ..onComplete((future) {
          _removeTransitionClasses([activeFigure, newActive]);
          if(!future.hasValue) {
            print("Exception! ${future.exception} -- ${future.stackTrace}");
          }
        });
  }

  void _removeTransitionClasses(List<Element> elements) {
    final dirClasses = [_dirClassNext, _dirClassPrev];
    elements.forEach((e) {
      dirClasses.forEach(e.classes.remove);
    });
  }

  Element _getFigureHost() => this.query('x-carousel > .content');

  void _initialize() {
    final figures = this.queryAll(_figuresQuery);

    // if there are any elements, make sure one and only one is 'active'
    final activeFigures = new List<Element>.from(figures.filter((e) => e.classes.contains(_activeClass)));
    if(activeFigures.length == 0) {
      if(figures.length > 0) {
        // marke the first of the figures as active
        figures[0].classes.add(_activeClass);
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
    figures.forEach((f) => ShowHide.getState(f));
  }
}
