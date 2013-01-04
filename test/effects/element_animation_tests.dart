part of effects_tests;

void registerElementAnimationTests() {
  group('ElementAnimation', () {
    setUp(() {
      setupTestTimeManager();
      _createPlayground();
    });

    tearDown(() {
      tearDownTestTimeManager();
      _cleanUpPlayground();
    });

    test('height to 0', () {
      final pg = _getPlayground();
      pg.appendHtml("<style scoped>div.foo { height: 50px; background: pink; }</style><div class='foo'>content</div>");

      pg.appendHtml('<strong>this is strong!</strong>');

      final fooDiv = query('div.playground div.foo');
      expect(fooDiv, isNotNull);

      final styleComplete = expectAsync1((CssStyleDeclaration style) {
        expect(style.height, equals('50px'));
        expect(fooDiv.style.height, equals(''));
      });
      fooDiv.computedStyle.then(styleComplete);

      final animation = new ElementAnimation(fooDiv, 'height', '0px');

      expect(animation.duration, equals(400));
      expect(fooDiv.style.height, equals(''));

      final wait1 = expectAsync0(() {
        _timeManagerInstance.tick(40);
        expect(animation.percentComplete, 0.1);
        expect(fooDiv.style.height, equals('45px'));

        _timeManagerInstance.tick(320);
        expect(animation.percentComplete, 0.9);
        expect(fooDiv.style.height, equals('5px'));
      });

      window.setTimeout(wait1, 1);
    });

  });
}

void _waitOne() {
  window.setTimeout(expectAsync0(() {
    print("wait one...");
  }), 1000);
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
