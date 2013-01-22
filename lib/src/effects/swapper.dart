part of effects;

/**
 * [effect] is used as the [hideEffect] unless [hideEffect] is provided.
 */
class Swapper {

  static Future<bool> swap(Element host, Element child,
      {ShowHideEffect effect, int duration, EffectTiming effectTiming, ShowHideEffect hideEffect}) {

    assert(host != null);

    if(?effect && !?hideEffect) {
      hideEffect = effect;
    }

    if(child == null) {
      // hide everything
      // NOTE: all visible items will have the same animation run, which might be weird
      //       hmm...
      return _hideEverything(host, hideEffect, duration, effectTiming);
    }

    if(child.parent != host) {
      throw 'host is not the parent of the provided child';
    }

    // ensure at most one child of the host is visible before beginning
    return _ensureOneShown(host)
        .then((Element currentlyVisible) {
          if(currentlyVisible == null) {
            return new Future.immediate(false);
          } else if(currentlyVisible == child) {
            // target element is already shown
            return new Future.immediate(true);
          }

          child.style.zIndex = '2';
          final showFuture = ShowHide.show(child, effect: effect, duration: duration, effectTiming: effectTiming);

          currentlyVisible.style.zIndex = '1';
          final hideFuture = ShowHide.hide(currentlyVisible, effect: hideEffect, duration: duration, effectTiming: effectTiming);

          return Future.wait([showFuture, hideFuture])
              .then((List<ShowHideResult> results) {
                [child, currentlyVisible].forEach((e) => e.style.zIndex = '');
                return results.every((a) => a.isSuccess);
              });
        });
  }

  static Future<bool> _hideEverything(Element host, ShowHideEffect effect, int duration, EffectTiming effectTiming) {
    final futures = host.children.mappedBy((e) => ShowHide.hide(e, effect: effect, duration: duration, effectTiming: effectTiming)).toList();
    return Future.wait(futures)
        .then((List<ShowHideResult> successList) {
          return successList.every((v) => v.isSuccess);
        });
  }

  static Future<Element> _ensureOneShown(Element host) {
    assert(host != null);
    if(host.children.length == 0) {
      // no elements to show
      return new Future.immediate(null);
    } else if(host.children.length == 1) {
      final child = host.children[0];
      return ShowHide.show(child)
          .then((ShowHideResult result) {
            if(result.isSuccess) {
              return child;
            } else {
              return null;
            }
          });
    }
    // NOTE: there is *no* way, with async computerStyle APis, to do this
    // in a way that ensures the host child collection doesn't change while
    // we're figuring things out. FYI.

    // 1 - get states of all children
    final futures = host.children
        .mappedBy(ShowHide.getState).toList();

    int shownIndex = null;

    return Future.wait(futures)
        .then((List<ShowHideState> states) {
          // paranoid sanity check that at lesat the count of items
          // before and after haven't changed
          assert(states.length == host.children.length);

          // See how many of the items are actually shown
          final showIndicies = new List<int>();
          for(int i=0; i<states.length;i++) {
            if(states[i].isShow) {
              showIndicies.add(i);
            }
          }

          if(showIndicies.length == 0) {
            // show last item -> likely the visible one
            shownIndex = host.children.length-1;

            return ShowHide.show(host.children[shownIndex]);
          } else if(showIndicies.length > 1) {
            // if more than one is shown, hide all but the last one
            final toHide = showIndicies
                .getRange(0, showIndicies.length - 1)
                .mappedBy((int index) => host.children[index]).toList();
            shownIndex = showIndicies[showIndicies.length - 1];
            return _hideAll(toHide);
          } else {
            assert(showIndicies.length == 1);
            shownIndex = showIndicies[0];
            // only one is shown...so...leave it
            return new Future.immediate(true);
          }
        })
        .then((bool success) {
          assert(success == true || success == false);
          assert(shownIndex != null);
          if(success) {
            return host.children[shownIndex];
          } else {
            return null;
          }
        });
  }

  static Future<bool> _hideAll(List<Element> elements) {
    final futures = elements.mappedBy((Element e) => ShowHide.hide(e)).toList();
    return Future.wait(futures)
        .then((List<ShowHideResult> successValues) => successValues.every((v) => v.isSuccess));
  }
}
