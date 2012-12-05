import 'package:web_components/web_components.dart';

class CounterComponent extends WebComponent {
  int count = 0;
  void increment() { count++; }
}
