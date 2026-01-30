import 'package:flutter/cupertino.dart';

import '../overlay_chart.dart';

class TooltipItem {
  final OverlayType overlayType;
  final DateTime time;
  final double? value;
  final Map<String, double> extras;

  TooltipItem({
    required this.overlayType,
    required this.time,
    this.value,
    this.extras = const {},
  });
}

class TooltipData {
  final Offset position;
  final DateTime time;
  final List<TooltipItem> data;
  TooltipData({required this.position, required this.time, this.data = const[]});
}

class CrosshairController extends ChangeNotifier {
  TooltipData? data;

  void update(TooltipData? d) {
    if (d == null) return;
    data = d;
    notifyListeners();
  }

  void clear() {
    data = null;
    notifyListeners();
  }
}
