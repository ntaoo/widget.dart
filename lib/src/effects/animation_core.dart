part of effects;

class AnimationCore {
  final num duration;

  // since app-local milliseconds
  num _startTimestamp;
  num _lastTick;
  num _percentComplete;

  AnimationCore(this.duration) {
    assert(isValidNumber(duration));
    assert(duration >= 0);
    AnimationQueue._getInstance()._add(this);
  }

  bool get ended => percentComplete >= 1;

  num get percentComplete => _percentComplete;

  // internal
  void _start(num timestamp) {
    assert(_startTimestamp == null);
    assert(_percentComplete == null);
    assert(isValidNumber(timestamp));
    assert(timestamp >= 0);
    _startTimestamp = timestamp;
    _percentComplete = 0;
  }

  // internal
  // returns true if the animation has finished
  bool _tick(num timestamp) {
    assert(!ended);
    assert(isValidNumber(timestamp));
    assert(_percentComplete >= 0);
    assert(timestamp > _startTimestamp);
    assert(_lastTick == null || timestamp > _lastTick);
    _lastTick = timestamp;

    // calculate the % done
    final pc = math.min(1.0, (timestamp - _startTimestamp) / duration);
    assert(pc > _percentComplete);
    assert(isValidNumber(pc));
    assert(pc <= 1.0);
    _percentComplete = pc;

    // TODO: easing
    // https://github.com/jquery/jquery-ui/blob/da01fb6a346e1ece3fd6dde5556a98f099e0c0e0/ui/jquery.ui.effect.js#L1206

    return ended;
  }
}
