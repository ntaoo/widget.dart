library effects_tests;

import 'dart:html';
import 'package:unittest/unittest.dart';
import 'package:widget/effects.dart';
import 'package:bot/bot.dart';

part 'animation_core_tests.dart';
part 'test_time_manager.dart';

void registerTests() {
  group('effects', () {
    test('asserts should be enabled', () {
      expect(() { assert(false); }, throwsAssertionError);
      expect(() { assert(true); }, returnsNormally);
    });
    registerAnimationCoreTests();
  });
}

void setupTestTimeManager() {
  AnimationQueue.timeManagerFactory = () {
    assert(_timeManagerInstance == null);
    return _timeManagerInstance = new TestTimeManager();
  };
}

void tearDownTestTimeManager() {
  AnimationQueue.disposeInstance();
  if(_timeManagerInstance != null) {
    assert(_timeManagerInstance.isDisposed);
    _timeManagerInstance = null;
  }
}

TestTimeManager _timeManagerInstance;

// TODO: put these in BOT test
final Matcher throwsAssertionError =
  const Throws(const _AssertionErrorMatcher());

class _AssertionErrorMatcher extends TypeMatcher {
  const _AssertionErrorMatcher() : super("AssertMatcher");
  bool matches(item, MatchState matchState) => item is AssertionError;
}
