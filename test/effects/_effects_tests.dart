library effects_tests;

import 'dart:html';
import 'package:unittest/unittest.dart';
import 'package:widget/effects.dart';
import 'package:bot/bot.dart';

part 'animation_core_tests.dart';
part 'element_animation_tests.dart';
part 'test_time_manager.dart';

void registerTests() {
  group('effects', () {
    test('asserts should be enabled', () {
      expect(() { assert(false); }, throwsAssertionError);
      expect(() { assert(true); }, returnsNormally);
    });

    registerAnimationCoreTests();
    registerElementAnimationTests();
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

void _createPlayground() {
  final existing = _getPlayground();
  assert(existing == null);
  // assert no playground exists
  final pg = new DivElement();
  pg.classes.add('playground');
  document.body.append(pg);
  // insert it
}

void _cleanUpPlayground() {
  final existing = _getPlayground();
  assert(existing != null);
  existing.remove();
}

DivElement _getPlayground() => query('div.playground');
