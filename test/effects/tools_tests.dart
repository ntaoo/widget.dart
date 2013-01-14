part of effects_tests;

void registerToolsTests() {
  group('Tools', () {
    setUp(() {
      _createPlayground();
    });

    tearDown(() {
      _cleanUpPlayground();
    });

    samples.forEach((css, result) {
      test(css, () {

        final pg = _getPlayground();

        pg.appendHtml('''
            <style scoped>div.foo { $css }</style>
            <div class='foo'>content</div>
        ''');

        final expectCallback = expectAsync1((Size size) {
          expect(size, result);
        });

        pg.query('div.foo').getComputedStyle('')
        .transform((css) => Tools.getOuterSize(css))
        .then(expectCallback);

      });
    });
  });
}

final samples =
{
 'width: 20px; height: 20px;': new Size(20, 20),
 'width: 10px; height: 5.5px;': new Size(10, 5.5),
 'width: 10px; height: 8px; border: 1px;': new Size(10, 8),
 'width: 10px; height: 8px; border: 1px solid;': new Size(12, 10),
 'width: 10px; height: 8px; padding: 2px;': new Size(14, 12),
 'width: 10px; height: 8px; padding: 2px; border: 1px;': new Size(14, 12),
 'width: 10px; height: 8px; padding: 2px; border: 1px solid;': new Size(16, 14)
};
