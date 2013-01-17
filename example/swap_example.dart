import 'dart:html';
import 'package:widget/effects.dart';

final ShowHideEffect _effect = new SlideEffect(xStart: HorizontalAlignment.LEFT);
final ShowHideEffect _hideEffect = new SlideEffect(xStart: HorizontalAlignment.RIGHT);
final int _duration = null;

void main() {
  _updateButtons();
}

void _updateButtons() {
  final buttonDiv = query('.buttons');
  buttonDiv.children.clear();

  final demoContent = queryAll('.demo > *');
  for(var i = 0; i < demoContent.length; i++) {
    buttonDiv.children.add(_makeButtonElement(i));
  }
}

void _clickButton(int index) {
  final host = query('.demo');
  if(host.children.length <= index) {
    // out of sync, update
    _updateButtons();
  } else {
    final child = host.children[index];

    Swapper.swap(host, child, effect: _effect, duration: _duration, hideEffect: _hideEffect)
      .then((bool complete) {
        print('worked? $complete');
      });
  }
}

Element _makeButtonElement(int index) {
  final button = new ButtonElement()
    ..text = (index+1).toString()
    ..style.padding = '5px 12px'
    ..style.margin = '3px 8px'
    ..style.fontSize = '100%';

  button.on.click.add((_) => _clickButton(index));

  return button;
}
