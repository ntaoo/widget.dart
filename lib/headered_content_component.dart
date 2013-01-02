import 'package:web_ui/web_ui.dart';

class HeaderedContentComponent extends WebComponent {
  String get header => attributes['header'];

  void set header(String value) {
    attributes['header'] = value;
  }
}
