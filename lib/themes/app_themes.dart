import 'package:flutter/material.dart';

class AppThemes {
  static final ThemeData lightTheme = ThemeData(
    brightness: Brightness.light,
    primarySwatch: Colors.blue,
    // Define other standard theme properties for light mode
    // e.g., scaffoldBackgroundColor, appBarTheme, etc.
    extensions: const <ThemeExtension<dynamic>>[
      AppTheme(
        // ... define other custom properties for the light theme
        priceBarColor: Colors.black26,
        tooltipDateColor: Colors.lightGreen,
        tooltipPriceColor: Colors.orange,
        tooltipVolumeColor: Colors.blueAccent,
        etfTitleColor: Colors.white,
        etfTitleShadowColor: Colors.black54
      ),
    ],
  );

  static final ThemeData darkTheme = ThemeData(
    brightness: Brightness.dark,
    primarySwatch: Colors.blue,
    // Define other standard theme properties for dark mode
    extensions: const <ThemeExtension<dynamic>>[
      AppTheme(
        // ... define other custom properties for the dark theme
        priceBarColor: Colors.white70,
        tooltipDateColor: Colors.lightGreen,
        tooltipPriceColor: Colors.orange,
        tooltipVolumeColor: Colors.blueAccent,
        etfTitleColor: Colors.white54,
        etfTitleShadowColor: Colors.black12,
      ),
    ],
  );
}

///
class AppTheme extends ThemeExtension<AppTheme> {
  final Color? bullishBarColor;
  final Color? bearishBarColor;
  final Color? priceBarColor;
  final Color? tooltipDateColor;
  final Color? tooltipPriceColor;
  final Color? tooltipVolumeColor;
  final Color? etfTitleColor;
  final Color? etfTitleShadowColor;

  // Optional: Add a static method to easily access the extension from context
  static AppTheme of(BuildContext context) {
    return Theme.of(context).extension<AppTheme>()!;
  }

  const AppTheme({
    this.bullishBarColor = Colors.green,
    this.bearishBarColor = Colors.red,
    required this.priceBarColor,
    required this.tooltipDateColor,
    required this.tooltipPriceColor,
    required this.tooltipVolumeColor,
    this.etfTitleColor,
    this.etfTitleShadowColor,
  });

  @override
  AppTheme copyWith({
    Color? bullishBarColor,
    Color? bearishBarColor,
    Color? priceBarColor,
    Color? tooltipDateColor,
    Color? tooltipPriceColor,
    Color? tooltipVolumeColor,
    Color? etfTitleColor,
    Color? etfTitleShadowColor,
  }) {
    return AppTheme(
      bullishBarColor: bullishBarColor,
      bearishBarColor: bearishBarColor,
      priceBarColor: priceBarColor,
      tooltipDateColor: tooltipDateColor,
      tooltipPriceColor: tooltipPriceColor,
      tooltipVolumeColor: tooltipVolumeColor,
      etfTitleColor: etfTitleColor,
      etfTitleShadowColor: etfTitleShadowColor,
    );
  }

  @override
  ThemeExtension<AppTheme> lerp(ThemeExtension<AppTheme>? other, double t) {
    if (other is! AppTheme) {
      return this;
    }
    return AppTheme(
      bullishBarColor: Color.lerp(bullishBarColor, other.bullishBarColor, t),
      bearishBarColor: Color.lerp(bearishBarColor, other.bearishBarColor, t),
      priceBarColor: Color.lerp(priceBarColor, other.priceBarColor, t),
      tooltipDateColor: Color.lerp(tooltipDateColor, other.tooltipDateColor, t),
      tooltipPriceColor: Color.lerp(tooltipPriceColor, other.tooltipPriceColor, t),
      tooltipVolumeColor: Color.lerp(tooltipVolumeColor, other.tooltipVolumeColor, t),
      etfTitleColor: Color.lerp(etfTitleColor, other.etfTitleColor, t),
      etfTitleShadowColor: Color.lerp(etfTitleShadowColor, other.etfTitleShadowColor, t),
    );
  }
}