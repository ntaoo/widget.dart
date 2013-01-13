import 'dart:html';
import 'package:web_ui/web_ui.dart';
import 'package:widget/effects.dart';

class Accordion extends WebComponent {
  static final ShowHideEffect _effect = null; // = new ShrinkEffect();
  static const String _groupIdKey = 'groupId';

  static int _groupId = 0;

  void created() {
    this.on.click.add(_click);
  }

  void inserted() {
  }

  void removed() {
  }

  void _click(MouseEvent e) {
    final target = e.target as Element;

  }

  void _show(int groupId) {
  }
}
