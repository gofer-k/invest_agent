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
        etfTitleShadowColor: Colors.black54,
        bullishBarColor: Colors.green,
        bearishBarColor: Colors.red,
        indicatorSignalColor: Colors.orange,
        indicatorRate: Colors.blueAccent,
        buttonOutlineColor: Color.fromRGBO(216, 168, 247, 1.0),
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
        bullishBarColor: Colors.green,
        bearishBarColor: Colors.red,
        indicatorSignalColor: Colors.orange,
        indicatorRate: Colors.blueAccent
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
  final Color? indicatorSignalColor;
  final Color? indicatorLowerBand;
  final Color? indicatorUpperBand;
  final Color? indicatorMiddleBand;
  final Color? indicatorRate;
  final Color? buttonOutlineColor;
  final EdgeInsets? paddingOverlayChart;

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
    this.indicatorSignalColor = Colors.orange,
    this.indicatorLowerBand = Colors.redAccent,
    this.indicatorUpperBand = Colors.greenAccent,
    this.indicatorMiddleBand = Colors.orange,
    this.indicatorRate = Colors.blueAccent,
    this.buttonOutlineColor = const Color.fromRGBO(216, 168, 247, 1.0), // Colors.deepPurpleAccent,
    this.paddingOverlayChart = const EdgeInsets.only(
      top: 12, left: 48 + 12, right: 48 + 12, bottom: 56),
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
    Color? indicatorSignalColor,
    Color? indicatorRate,
    Color? indicatorLowerBand,
    Color? indicatorUpperBand,
    Color? indicatorMiddleBand,
    Color? buttonOutlineColor,
    EdgeInsets? paddingOverlayChart,
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
      indicatorSignalColor: indicatorSignalColor,
      indicatorRate: indicatorRate,
      paddingOverlayChart: paddingOverlayChart,
      indicatorLowerBand: indicatorLowerBand,
      indicatorUpperBand: indicatorUpperBand,
      buttonOutlineColor: buttonOutlineColor,
      indicatorMiddleBand: indicatorMiddleBand,
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
      indicatorSignalColor: Color.lerp(indicatorSignalColor, other.indicatorSignalColor, t),
      indicatorRate: Color.lerp(indicatorRate, other.indicatorRate, t),
      paddingOverlayChart: EdgeInsets.lerp(paddingOverlayChart, other.paddingOverlayChart, t),
      indicatorLowerBand: Color.lerp(indicatorLowerBand, other.indicatorLowerBand, t),
      indicatorUpperBand: Color.lerp(indicatorUpperBand, other.indicatorUpperBand, t),
      indicatorMiddleBand: Color.lerp(indicatorMiddleBand, other.indicatorMiddleBand, t),
      buttonOutlineColor: Color.lerp(buttonOutlineColor, other.buttonOutlineColor, t),
    );
  }
}