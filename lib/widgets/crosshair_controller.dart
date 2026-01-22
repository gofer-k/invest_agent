import 'dart:core';

import 'package:flutter/cupertino.dart';

class CrosshairController extends ChangeNotifier {
  DateTime? _time;
  double? _val;

  DateTime? get time => _time;
  double? get val => _val;

  void update(DateTime? time,  double? val) {
    _time = time;
    _val = val;
    notifyListeners();
  }

  void clear() => update(null, null);
}