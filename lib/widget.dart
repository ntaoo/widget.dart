library widget;

import 'dart:html';
import 'package:web_ui/web_ui.dart';
import 'package:widget/effects.dart';

abstract class SwapComponent {

  int get activeItemIndex;
  Element get activeItem;
  List<Element> items;

  Future<bool> showItemAtIndex(int index, {ShowHideEffect effect, int duration, EffectTiming effectTiming, ShowHideEffect hideEffect});
  Future<bool> showItem(Element item, {ShowHideEffect effect, int duration, EffectTiming effectTiming, ShowHideEffect hideEffect});
}
