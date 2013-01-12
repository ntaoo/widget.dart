import 'dart:html';
import 'package:web_ui/web_ui.dart';
import 'package:widget/effects.dart';

class Accordion extends WebComponent {
  static final ShowHideEffect _effect = null; // = new ShrinkEffect();
  static const String _groupClass = 'accordion-group-x';
  static const String _headerClass = 'accordion-heading-x';
  static const String _bodyClass = 'accordion-body-x';
  static const String _toggleClass = 'accordion-toggle-x';
  static const String _groupIdKey = 'groupId';

  static int _groupId = 0;

  void created() {
    _swapChildren();
    this.on.click.add(_click);
  }

  void inserted() {
  }

  void removed() {
  }

  void _click(MouseEvent e) {
    final target = e.target as Element;

    if(target != null && target.classes.contains(_toggleClass)) {
      final groupId = int.parse(target.dataAttributes[_groupIdKey]);
      _show(groupId);
    }
  }

  void _show(int groupId) {
    final bodies = this.queryAll('.$_bodyClass');
    bodies.forEach((Element e) {
      final localId = int.parse(e.dataAttributes[_groupIdKey]);
      if(localId == groupId) {
        ShowHide.show(e, effect: _effect);
      } else {
        ShowHide.hide(e, effect: _effect);
      }
    });
  }

  void _swapChildren() {
    // TODO: if filter or similiar in the future returns an iterable
    // one might want to copy everything to a new list before swapping
    // since swap will change the contents of this.children

    final toSwap = this.children.filter((Element e) =>
        e.tagName.toLowerCase() == 'item')
        .forEach(_swapChild);
  }

  void _swapChild(UnknownElement element) {
    String header = element.attributes['header'];
    if(header == null || header.isEmpty) {
      header = 'no header provided';
    }

    final children = new List<Element>.from(element.children);

    final newNode = _createAccordionElement(header, children);
    element.replaceWith(newNode);
  }

  // TODO: at some point, support header as an element, too
  Element _createAccordionElement(String header, List<Element> content) {
    final groupId = (++_groupId).toString();

    final groupDiv = new DivElement()
      ..classes.add(_groupClass);

    final headingLink = new AnchorElement()
      ..appendText(header)
      ..href = '#'
      ..classes.add(_toggleClass)
      ..dataAttributes[_groupIdKey] = groupId;

    final headerDiv = new DivElement()
      ..classes.add(_headerClass)
      ..append(headingLink);

    groupDiv.append(headerDiv);

    final contentDiv = new DivElement()
      ..dataAttributes[_groupIdKey] = groupId
      ..classes.add(_bodyClass)
      ..children.addAll(content);

    groupDiv.append(contentDiv);

    return groupDiv;
  }
}
