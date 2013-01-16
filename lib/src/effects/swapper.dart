part of effects;

// TODO: magic to ensure one and only one item is shown at the begining of a swap
// TODO: remove support for adding new items. Too crazy when you talk about pending swaps
// TODO: support pending swaps: swap 2 will 'wait' till swap 1 is done.
// TODO: ponder SwapResult enum: failed due to element states, swallowed by a
//       swap that started before the requested one finished, etc

/**
 * If [effect] is used as the [hideEffect] unless [hideEffect] is provided.
 */
class Swapper {

  static Future<bool> swap(Element host, Element child,
      {ShowHideEffect effect, int duration, EffectTiming effectTiming, ShowHideEffect hideEffect}) {

    assert(host != null);
    assert(child != null);

    if(?effect && !?hideEffect) {
      hideEffect = effect;
    }

    // we will host a child provided with no existing parent
    if(child.parent == null) {
      host.children.add(child);
    }

    // we will not steal an element from another parent
    if(child.parent != host) {
      return new Future<bool>.immediate(false);
    }

    final futures = host.children.map((Element e) {
      var action = ShowHideAction.HIDE;
      var zIndex = 1;
      var theEffect = hideEffect;

      if(e == child) {
        action = ShowHideAction.SHOW;
        zIndex = 2;
        theEffect = effect;
      }

      e.style.zIndex = zIndex.toString();
      return ShowHide.begin(action, e, effect: theEffect, duration: duration, effectTiming: effectTiming)
          .transform((bool done) {
            e.style.zIndex = '';
            return done;
          });
    });

    return Futures.wait(futures)
        .transform((List<bool> results) => results.every((a) => a));
  }

}
