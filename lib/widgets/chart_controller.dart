import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';

/*
Controller class stores domain window: minX, maxX
Pan = shift window
Zoom = scale window around a focal point
Crosshair = shared domain x
All charts read from the same controller
*/
class ChartInteractionController extends ChangeNotifier {
  double _minX;
  double _maxX;

  double? _crosshairX; // null = hidden

  // Optional: hard bounds of your data
  final double dataMinX;
  final double dataMaxX;

  ChartInteractionController({
    required double initialMinX,
    required double initialMaxX,
    required this.dataMinX,
    required this.dataMaxX,
  })  : _minX = initialMinX,
        _maxX = initialMaxX;

  double get minX => _minX;
  double get maxX => _maxX;
  double? get crosshairX => _crosshairX;

  double get windowWidth => _maxX - _minX;

  void panDomain(double dxDomain) {
    final newMin = _minX + dxDomain;
    final newMax = _maxX + dxDomain;

    // clamp to data bounds
    final clampedMin = max(dataMinX, newMin);
    final clampedMax = min(dataMaxX, newMax);

    // avoid shrinking window when clamped
    if (clampedMax - clampedMin < windowWidth) {
      _minX = clampedMin;
      _maxX = clampedMin + windowWidth;
    } else {
      _minX = clampedMin;
      _maxX = clampedMax;
    }
    notifyListeners();
  }

  /// factor > 1 => zoom in, factor < 1 => zoom out
  /// focalXDomain is the domain value around which to zoom (e.g. candle index or timestamp)
  void zoom(double factor, double focalXDomain, {double minWindow = 10}) {
    final currentWidth = windowWidth;
    final newWidth = (currentWidth / factor).clamp(minWindow, dataMaxX - dataMinX);

    final t = ((focalXDomain - _minX) / currentWidth).clamp(0.0, 1.0);
    final newMin = focalXDomain - newWidth * t;

    _minX = newMin.clamp(dataMinX, dataMaxX - newWidth);
    _maxX = _minX + newWidth;

    notifyListeners();
  }

  void setCrosshair(double? xDomain) {
    if (xDomain == _crosshairX) return;
    _crosshairX = xDomain;
    notifyListeners();
  }

  double pixelToDomain(double pixelX, double width) {
    final t = (pixelX / width).clamp(0.0, 1.0);
    return _minX + t * windowWidth;
  }

  double domainToPixel(double domainX, double width) {
    final t = ((domainX - _minX) / windowWidth);
    return t * width;
  }
}



