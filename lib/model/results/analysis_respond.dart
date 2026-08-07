import 'dart:developer';

import '../analysis_period.dart';
import 'indicator/indicator_result.dart';
import 'indicator/price_result.dart';

class GoldenCross extends BaseIndicatorValue{
  final int? cross;

  GoldenCross({required super.dateTime, this.cross});

  static GoldenCross? fromJson(DateTime dateTime, Map<String, dynamic> jsonMap) {
    return GoldenCross(
       dateTime: dateTime,
       cross: int.tryParse(jsonMap['golden_cross']),
    );
  }

  Map<String, dynamic> toJson() => {
    "golden_cross": cross,
  };
}

class DeathCross extends BaseIndicatorValue{
  final int? cross;

  DeathCross({required super.dateTime, this.cross});

  static GoldenCross? fromJson(DateTime dateTime, Map<String, dynamic> jsonMap) {
    return GoldenCross(
      dateTime: dateTime,
      cross: int.tryParse(jsonMap['dead_cross']),
    );
  }

  Map<String, dynamic> toJson() => {
    "dead_cross": cross,
  };
}

enum CandleDetectorType {
  hammer,
  doji,
  engulfing,
  harami,
  invertedHammer,
  shootingStar,
}
CandleDetectorType? candleDetectorTypeFromString(String value) {
  try {
    return CandleDetectorType.values.firstWhere((e) => e.name.contains(value.toLowerCase()), orElse: () => CandleDetectorType.doji);
  } catch (e) {
    return CandleDetectorType.doji;
  }
}

class CandleDetector {
  final String typeName; // Original string for extendability
  final double? price;
  final double? strength;
  const CandleDetector({required this.typeName, this.price, this.strength});

  CandleDetectorType? get type => CandleDetectorType.values.where((e) => e.name == typeName).firstOrNull;

  static CandleDetector? fromJson(String typeName, dynamic jsonMap) {
    if (jsonMap is! Map<String, dynamic>) return null;
    final price = parseNum(jsonMap['price']);
    final strength = parseNum(jsonMap['strength']);
    if (price == null) return null;
    return CandleDetector(typeName: typeName, price: price, strength: strength);
  }

  Map<String, dynamic> toJson() => {
    "price": price,
    "strength": strength,
  };
}

class CandleStickItem extends BaseIndicatorValue {
  final double? openPrice;
  final double? closePrice;
  final double? highPrice;
  final double? lowPrice;
  final double? volume;
  final Map<String, CandleDetector> detectors;

  const CandleStickItem({required super.dateTime, this.openPrice, this.closePrice, this.highPrice, this.lowPrice, this.volume, required this.detectors});

  static CandleStickItem? fromJson(DateTime dateTime, double? openPrice, double? closePrice, double? highPrice, double? lowPrice, double? volume, Map<String, dynamic> jsonMap) {
    if (openPrice == null || closePrice == null || highPrice == null || lowPrice == null || volume == null)  {
      return null;
    }

    final detectors = <String, CandleDetector>{};
    jsonMap.forEach((key, value) {
      final detector = CandleDetector.fromJson(key, value);
      if (detector != null) {
        detectors[key] = detector;
      }
    });

    return CandleStickItem(
      dateTime: dateTime,
      openPrice: openPrice,
      closePrice: closePrice,
      highPrice: highPrice,
      lowPrice: lowPrice,
      volume: volume,
      detectors: detectors
    );
  }

  Map<String, dynamic> toJson() {
    return detectors.map((key, value) => MapEntry(key, value.toJson()));
  }
}

class AnalysisRespond {
  final List<IndexPriceItem> priceData;
  final List<CandleStickItem> candles;
  double maxPrice = 0.0;
  double minPrice = 0.0;
  PeriodType period;

  AnalysisRespond(this.candles, this.priceData, this.period);

  AnalysisRespond copyWith({
    PeriodType? period,
    List<IndexPriceItem>? priceData,
    List<CandleStickItem>? candles,
    double? priceRange, double? maxPrice, double? minPrice}) {
    return AnalysisRespond(
      candles ?? this.candles,
      priceData ?? this.priceData,
      period ?? this.period,
    );
  }

  Future<List<IndexPriceItem>> getRollingVolume(int rollingWindow) async {
    return priceData.sublist(rollingWindow);
  }

  static AnalysisRespond? fromJsonSync(Map<String, dynamic> jsonMap) {
    // final indicators = <Indicators>[];
    final candles = <CandleStickItem>[];
    final List<IndexPriceItem> priceData = [];

    final responseData = jsonMap["respond"] as Map<String, dynamic>;
    responseData.forEach((key, value) {
      try {
        final dateTime = DateTime.parse(key);
        final metaData = value["metadata"] as Map<String, dynamic>;
        final openPrice = parseNum(metaData["Open"]);
        final closePrice = parseNum(metaData["Close"]);
        final highPrice = parseNum(metaData["High"]);
        final lowPrice = parseNum(metaData["Low"]);
        final volume = parseNum(metaData["Volume"]);

        final jsonCandle = value["candlestick"] as Map<String, dynamic>;
        final candleItem = CandleStickItem.fromJson(dateTime, openPrice, closePrice, highPrice, lowPrice, volume, jsonCandle);
        if (candleItem != null) {
          candles.add(candleItem);
        }
      }
      catch (e) {
        log("ETF agent analysis: Error parsing date: $e");
      }
    });

    if(priceData.isNotEmpty) {
      return AnalysisRespond(candles, priceData, PeriodType.max);
    }
    return null;
  }

  static Future<AnalysisRespond?> fromJson(Map<String, dynamic> jsonMap) async {
    return fromJsonSync(jsonMap);
  }

  Map<String, dynamic> toJson() => {
    "respond": {
      for (var i = 0; i < priceData.length; i++)
        priceData[i].dateTime.toIso8601String(): {
          "metadata": {
            "Open": priceData[i].openPrice,
            "Close": priceData[i].closePrice,
            "High": priceData[i].highPrice,
            "Low": priceData[i].lowPrice,
            "Volume": priceData[i].volume,
            "VolumeZscore": [],
          },
          "candlestick": candles[i].toJson(),
        }
    }
  };
}

double? parseNum(dynamic value) {
  if (value == null || value == 'null' || value == 'NaN') return null;
  final cleaned = value.toString().replaceAll(RegExp(r'JS:\d+'), '');
  return double.tryParse(cleaned);
}
