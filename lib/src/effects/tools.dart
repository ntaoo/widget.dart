part of effects;

class Tools {
  static IFrameElement _iframe;

  static final Map<String, String> _elemDisplay = new Map<String, String>();

  static Future<int> windowWait(int milliseconds) {
    if(milliseconds < 0) {
      return new Future.immediate(0);
    } else {
      final completer = new Completer();

      window.setTimeout(() => completer.complete(milliseconds), milliseconds);

      return completer.future;
    }
  }

  // borrowing from here:
  // https://github.com/jquery/jquery/blob/054daa20afc0e2c84e66f450b155d0253a62aedb/src/css.js#L428

  // Try to determine the default display value of an element
  static Future<String> getDefaultDisplay(String nodeName ) {
    final storedValue = _elemDisplay[nodeName];
    if(storedValue != null) {
      return new Future.immediate(storedValue);
    } else {
      return _css_defaultDisplay(nodeName)
          .chain((String defaultDisplay) {
            assert(defaultDisplay != null);

            if(defaultDisplay == 'none' || defaultDisplay == '') {
              return _defaultDisplayHard(nodeName);
            } else {
              return new Future.immediate(defaultDisplay);
            }
          })
          .transform((String value) {
            assert(value != null);
            assert(value != 'none');
            assert(value != '');
            return value;
          });
    }
  }

  static Future<String> _css_defaultDisplay(String nodeName) {
    final doc = document;

    // skipping crazy iframe dance for now...
    return _actualDisplay(nodeName, document);
  }

  static Future<String> _defaultDisplayHard(String nodeName) {
    if(_iframe == null) {
      _iframe = new Element.tag('iframe')
      ..attributes['frameborder'] = '0'
      ..attributes['width'] = '0'
      ..attributes['height'] = '0'
      ..attributes['style'] = 'display: block !important';
    }

    document.body.children.add(_iframe);

    final frameDoc = _iframe.contentWindow;

    throw 'damn...';

    // TODO: can't make any progress here
    // IFrameElement.contentWindow is a WindowBase
    // which doesn't let me get to the doc.
    // *sigh*
  }

  static Future<String> _actualDisplay(String name, HtmlDocument doc) {
    final elem = new Element.tag(name);
    doc.body.append(elem);

    return elem.getComputedStyle('')
        .transform((CssStyleDeclaration css) {
          final value = css.display;
          elem.remove();
          return value;
        });
  }

}
