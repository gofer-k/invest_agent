import 'package:flutter/cupertino.dart';

class CrosshairController extends ChangeNotifier {
  double? xPosition; // null = hidden

  void update(double? x) {
    xPosition = x;
    notifyListeners();
  }
}
