import 'dart:developer';

import '../analysis_period.dart';
import '../indicator_result.dart';
import 'price_result.dart';

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

class RSI extends BaseIndicatorValue {
  final double rsi;

  RSI({required super.dateTime, required this.rsi});

  static RSI? fromJson(DateTime dateTime, Map<String, dynamic> jsonMap) {
    final value = parseNum(jsonMap['RSI']);
    if (value == null) {
      return null;
    }
    return RSI( dateTime: dateTime, rsi: value);
  }

  Map<String, dynamic> toJson() => {
    "RSI": rsi,
  };
}

// Moving Average Convergence/Divergence indicator
// enum MACDType {
//   MACD_12_26,
//   MACD_50_200,
// }
// MACDType? macdTypeFromString(String value) {
//   try {
//     return MACDType.values.firstWhere((e) => e.name == value);
//   } catch (e) {
//     return null; // Return null if no match is found
//   }
// }
//
// class MACD extends BaseIndicatorValue{
//   final double macd;
//   final double signal;
//   final double hist;
//   final MACDType type;
//
//   MACD({required super.dateTime, required this.type, required this.macd, required this.signal, required this.hist});
//
//   factory MACD.fromType(DateTime dateTime, MACDType type, {macd = double, signal = double, hist = double}) {
//     return MACD(dateTime: dateTime, type: type, macd: macd, signal: signal, hist: hist);
//   }
//
//   static MACD? fromJson(DateTime dateTime, Map<String, dynamic> jsonMap, String jsonMacdType) {
//     final macdType = macdTypeFromString(jsonMacdType);
//     if (macdType == null) {
//       return null;
//     }
//     final macd = parseNum(jsonMap['value']);
//     final signal = parseNum(jsonMap['signal']);
//     final hist = parseNum(jsonMap['hist']);
//     if (macd != null && signal != null && hist != null) {
//       return MACD(
//           dateTime: dateTime,
//           type: macdType,
//           macd: macd,
//           signal: signal,
//           hist: hist
//       );
//     }
//     return null;
//   }
//
//   Map<String, dynamic> toJson() => {
//     "value": macd,
//     "signal": signal,
//     "hist": hist,
//   };
// }

// enum IndicatorType {
//   EMA,
//   SMA,
//   MACD,
//   RSI
// }

// IndicatorType? indicatorTypeFromString(String value) {
//   try {
//     return IndicatorType.values.firstWhere((e) => e.name.contains(value));
//   } catch (e) {
//     return null; // Return null if no match is found
//   }
// }

// class Indicators {
//   // final List<MACD> macd;
//   final RSI rsi;
//   final Map<String, dynamic> other; // For extendability
//
//   Indicators(this.macd, this.sma, this.ema, this.rsi, {this.other = const {}});
//
//   // static Indicators? fromJson(DateTime dateTime, Map<String, dynamic> jsonMap) {
//     final jsonRSI = parseNum(jsonMap["RSI"]);
//     final rsi = RSI(dateTime: dateTime, rsi: jsonRSI ?? 0.0);
//
//     List<MACD> macd = [];
//     final macdTypes = ["MACD_12_26", "MACD_50_200"];
//     for (String macdType in macdTypes) {
//       final jsonMACD = jsonMap[macdType] as Map<String, dynamic>?;
//       if (jsonMACD != null) {
//         final macdIndicator = MACD.fromJson(dateTime, jsonMACD, macdType);
//         if (macdIndicator != null) {
//           macd.add(macdIndicator);
//         }
//       }
//     }
//
//     // Capture other fields
//     final knownFields = {"RSI", ...macdTypes};
//     final other = Map<String, dynamic>.from(jsonMap)..removeWhere((key, value) => knownFields.contains(key));
//
//     return Indicators(macd, rsi, other: other);
//   }
//
//   Map<String, dynamic> toJson() {
//     final map = <String, dynamic>{
//       ...rsi.toJson(),
//       ...other,
//     };
//     for (var m in macd) {
//       map[m.type.name] = m.toJson();
//     }
//     return map;
//   }
// }

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

  // List<MACD> getMacd(MACDType type) {
  //   final macd = <MACD>[];
  //   for (var indicator in indicators) {
  //     final newMacd = indicator.macd.firstWhere((macd) => macd.type == type);
  //     macd.add(newMacd);
  //   }
  //   return macd;
  // }

  // List<MACD> getMacdFiltered(MACDType type, DateTime startDate, DateTime endDate) {
  //   final macd = <MACD>[];
  //   for (var indicator in indicators) {
  //     if (indicator.rsi.dateTime.isAfter(startDate) && indicator.rsi.dateTime.isBefore(endDate)) {
  //       final newMacd = indicator.macd.firstWhere((macd) => macd.type == type);
  //       macd.add(newMacd);
  //     }
  //   }
  //   return macd;
  // }
  
  // double getMinMACD(MACDType macdType, DateTime? startDate, DateTime? endDate) {
  //   final dataFiltered = (startDate != null && endDate != null) ? getMacdFiltered(macdType, startDate, endDate) : getMacd(macdType);
  //   final minMacd = dataFiltered.reduce((value, element) => value.macd <= element.macd ? value : element).macd;
  //   final minSignal = dataFiltered.reduce((value, element) => value.signal <= element.signal ? value : element).signal;
  //   return min(minMacd, minSignal);
  // }
  //
  // double getMaxMACD(MACDType macdType, DateTime? startDate, DateTime? endDate) {
  //   final dataFiltered = (startDate != null && endDate != null) ? getMacdFiltered(macdType, startDate, endDate) : getMacd(macdType);
  //   final maxMacd = dataFiltered.reduce((value, element) => value.macd > element.macd ? value : element).macd;
  //   final maxSignal = dataFiltered.reduce((value, element) => value.signal > element.signal ? value : element).signal;
  //   return max(maxMacd, maxSignal);
  // }

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
