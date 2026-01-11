import 'dart:developer';

class BaseIndicatorValue {
  final DateTime dateTime;

  const BaseIndicatorValue({required this.dateTime});
}

// Build SMA chart:
// Map<rollingWindow, List<SMA>>
class SimpleMovingAverage extends BaseIndicatorValue {
  final double? rollingStd;
  final double? rollingMean;
  final BellingersBands? bellingersBands;
  final int? rollingWindow;

  SimpleMovingAverage({required super.dateTime, this.rollingWindow, this.rollingStd, this.rollingMean, this.bellingersBands});

  static SimpleMovingAverage? fromJson(DateTime dateTime, Map<String, dynamic> jsonMap) {
    final value = parseNum(jsonMap['value']);
    final rollingMean = parseNum(jsonMap['rolling_mean']);
    final rollingStd = parseNum(jsonMap['rolling_std']);
    final rollingWindow = parseNum(jsonMap["window"]);
    if (value == null && rollingMean == null && rollingStd == null && rollingWindow == null) {
      return null;
    }

    return SimpleMovingAverage(
      dateTime: dateTime,
      rollingWindow: rollingWindow?.toInt(),
      rollingMean: rollingMean,
      rollingStd: rollingStd,
      bellingersBands: BellingersBands.fromJson(dateTime, jsonMap));
  }
}

// Build Bellingers band charts:
// BB upper band:  Map<rollingWindow, List<BellingerBand>>
// BB lower band:  Map<rollingWindow, List<BellingerBand>>
// BB middle band:  Map<rollingWindow, List<BellingerBand>>
class BellingersBand extends BaseIndicatorValue{
  final double? band;

  BellingersBand({required super.dateTime, this.band});
}

class BellingersBands extends BaseIndicatorValue{
  final double? upperBB;
  final double? lowerBB;
  final double? widthBB;
  final double? percentBB;
  BellingersBands({required super.dateTime, this.upperBB, this.lowerBB, this.widthBB, this.percentBB});

  static BellingersBands? fromJson(DateTime dateTime, Map<String, dynamic> jsonMap) {
    return BellingersBands(
      dateTime: dateTime,
      lowerBB: parseNum(jsonMap['BB_lower']),
      upperBB: parseNum(jsonMap['BB_upper']),
      percentBB: parseNum(jsonMap['BB_percent']),
      widthBB: parseNum(jsonMap['BB_width']));
  }
}

class GoldenCross extends BaseIndicatorValue{
  final int? cross;

  GoldenCross({required super.dateTime, this.cross});
}

class DeathCross extends BaseIndicatorValue{
  final int? cross;

  DeathCross({required super.dateTime, this.cross});
}

class ExponentialMovingAverage extends BaseIndicatorValue{
  final double? ema;
  final int? rollingWindow;

  ExponentialMovingAverage({required super.dateTime, this.ema, this.rollingWindow});
  static ExponentialMovingAverage? fromJson(DateTime dateTime, Map<String, dynamic> jsonMap) {
    final value = parseNum(jsonMap['value']);
    final rollingWindow = parseNum(jsonMap["window"]);
    if (value == null || rollingWindow == null) {
      return null;
    }
    return ExponentialMovingAverage(dateTime: dateTime, ema: value, rollingWindow: rollingWindow.toInt());
  }
}

// Moving Average Convergence/Divergence indicator
enum MACDType {
  MACD_12_26,
  MACD_50_200,
}
MACDType? macdTypeFromString(String value) {
  try {
    return MACDType.values.firstWhere((e) => e.name == value);
  } catch (e) {
    return null; // Return null if no match is found
  }
}

class MACD extends BaseIndicatorValue{
  final double? macd;
  final double? signal;
  final double? hist;
  final MACDType type;

  MACD({required super.dateTime, required this.type, this.macd, this.signal, this.hist});

  factory MACD.fromType(DateTime dateTime, MACDType type, {macd = double, signal = double, hist = double}) {
    return MACD(dateTime: dateTime, type: type, macd: macd, signal: signal, hist: hist);
  }

  static MACD? fromJson(DateTime dateTime, Map<String, dynamic> jsonMap) {
    final strType = jsonMap.keys.first;
    final macdType = macdTypeFromString(strType);
    if (macdType == null) {
      return null;
    }
    final macd = parseNum(jsonMap['value']);
    final signal = parseNum(jsonMap['signal']);
    final hist = parseNum(jsonMap['hist']);
    if (macd == null && signal == null && hist == null) {
      return null;
    }
    return MACD(
      dateTime: dateTime,
      type: macdType,
      macd: macd,
      signal: signal,
      hist: hist
    );
  }
}

enum IndicatorType {
  EMA,
  SMA,
  MACD
}

IndicatorType? indicatorTypeFromString(String value) {
  try {
    return IndicatorType.values.firstWhere((e) => e.name.contains(value));
  } catch (e) {
    return null; // Return null if no match is found
  }
}

class Indicators {
  final Map<int, SimpleMovingAverage> sma;  // [rollingWindow -> value]
  final Map<int, ExponentialMovingAverage> ema;  // [rollingWindow -> value]
  final List<MACD> macd;

  Indicators(this.macd, this.sma, this.ema);

  static Indicators? fromJson(DateTime dateTime, IndicatorType indType, Map<String, dynamic> jsonMap) {
    final jsonSMa = jsonMap["SMA"] as List<dynamic>;
    Map<int, SimpleMovingAverage> sma = <int, SimpleMovingAverage>{};
    for (var element in jsonSMa) {
      final jsonValues = element as Map<String, dynamic>;
      final smaIndicator = SimpleMovingAverage.fromJson(dateTime, jsonValues);
      if (smaIndicator != null && smaIndicator.rollingWindow != null) {
        sma.putIfAbsent(smaIndicator.rollingWindow!, () => smaIndicator);
      }
    }

    final jsonEMa = jsonMap["EMA"] as List<dynamic>;
    Map<int, ExponentialMovingAverage> ema = <int, ExponentialMovingAverage>{};
    for (var element in jsonEMa) {
      final jsonValues = element as Map<String, dynamic>;
      final emaIndicator = ExponentialMovingAverage.fromJson(dateTime, jsonValues);
      if (emaIndicator != null && emaIndicator.rollingWindow != null) {
        ema.putIfAbsent(emaIndicator.rollingWindow!, () => emaIndicator);
      }
    }

    List<MACD> macd = [];
    final macdTypes = ["MACD_12_26", "MACD_50_200"];
    for (String macdType in macdTypes) {
      final jsonMACD = jsonMap[macdType] as Map<String, dynamic>;
      final macdIndicator = MACD.fromJson(dateTime, jsonMACD);
      if (macdIndicator != null) {
        macd.add(macdIndicator);
      }
    }
    return Indicators(macd, sma, ema);
  }
}

enum CandleDetectorType {
  hammer,
  doji,
  engulfing,
  harami,
  inverted_hammer,
  shooting_star,
}
CandleDetectorType? candleDetectorTypeFromString(String value) {
  try {
    return CandleDetectorType.values.firstWhere((e) => e.name.contains(value));
  } catch (e) {
    return null; // Return null if no match is found
  }
}

class CandleDetector {
  final CandleDetectorType type;
  final double? price;
  final double? strength;
  const CandleDetector({required this.type, this.price, this.strength}) : assert(strength == null || (strength >= 0.0 && strength <= 1.0),
  'Strength must be null or between 0.0 and 1.0');

  static CandleDetector? fromJson(CandleDetectorType type, jsonMap) {
    final price = jsonMap['price'] as double?;
    final strength = jsonMap['strength'] as double?;
    if (price == null || strength == null) {
      return null;
    }
    return CandleDetector(type: type, price: price, strength: strength);
  }
}

class CandleStickItem extends BaseIndicatorValue {
  final double? openPrice;
  final double? closePrice;
  final double? highPrice;
  final double? lowPrice;
  final double? volume;
  final List<CandleDetector> detectors;

  const CandleStickItem({required super.dateTime, this.openPrice, this.closePrice, this.highPrice, this.lowPrice, this.volume, required this.detectors});

  static CandleStickItem? fromJson(DateTime dateTime, double? openPrice, double? closePrice, double? highPrice, double? lowPrice, double? volume, Map<String, dynamic> jsonMap) {
    if (openPrice == null || closePrice == null || highPrice == null || lowPrice == null || volume == null)  {
      return null;
    }

    final jsonHammer = jsonMap["hammer"] as Map<String, dynamic>;
    final jsonInvertedHammer = jsonMap["inverted_hammer"] as Map<String, dynamic>;
    final jsonDoji = jsonMap["doji"] as Map<String, dynamic>;
    final jsonEngulfing = jsonMap["engulfing"] as Map<String, dynamic>;
    final jsonHarami = jsonMap["harami"] as Map<String, dynamic>;
    final jsonShootingStar = jsonMap["shooting_star"] as Map<String, dynamic>;

    final detectors = <CandleDetector>[];
    final hammer = CandleDetector.fromJson(CandleDetectorType.hammer, jsonHammer);
    if (hammer != null) {
        detectors.add(hammer);
    }
    final invertedHammer = CandleDetector.fromJson(CandleDetectorType.inverted_hammer, jsonInvertedHammer);
    if (invertedHammer != null) {
        detectors.add(invertedHammer);
    }
    final doji = CandleDetector.fromJson(CandleDetectorType.doji, jsonDoji);
    if (doji != null) {
      detectors.add(doji);
    }
    final engulfing = CandleDetector.fromJson(CandleDetectorType.engulfing, jsonEngulfing);
    if (engulfing != null) {
      detectors.add(engulfing);
    }
    final harami = CandleDetector.fromJson(CandleDetectorType.harami, jsonHarami);
    if (harami != null) {
      detectors.add(harami);
    }
    final shootingStar = CandleDetector.fromJson(CandleDetectorType.shooting_star, jsonShootingStar);
    if (shootingStar != null) {
      detectors.add(shootingStar);
    }
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
}

class PriceData {
  final DateTime dateTime;
  final double openPrice;
  final double closePrice;
  final double highPrice;
  final double lowPrice;
  final double volume;

  PriceData({required this.dateTime, required this.openPrice, required this.closePrice, required this.highPrice, required this.lowPrice, required this.volume});
}

class AnalysisRespond {
  final List<PriceData> priceData;
  final List<Indicators> indicators;
  final List<CandleStickItem> candles;

  AnalysisRespond(this.indicators, this.candles, this.priceData);

  static Future<AnalysisRespond?> fromJson(Map<String, dynamic> jsonMap) async {
    final indicators = <Indicators>[];
    final candles = <CandleStickItem>[];
    final List<PriceData> priceData = [];

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
        if (openPrice != null && closePrice != null && highPrice != null && lowPrice != null && volume != null) {
          priceData.add(PriceData(dateTime: dateTime,
            openPrice: openPrice,
            closePrice: closePrice,
            highPrice: highPrice,
            lowPrice: lowPrice,
            volume: volume));
        }

        final jsonCandle = value["candlestick"] as Map<String, dynamic>;
        final candleItem = CandleStickItem.fromJson(dateTime, openPrice, closePrice, highPrice, lowPrice, volume, jsonCandle);
        if (candleItem != null) {
          candles.add(candleItem);
        }

        final jsonIndicators = value["indicators"] as Map<String, dynamic>;
        final indicator = Indicators.fromJson(dateTime, IndicatorType.SMA, jsonIndicators);
        if (indicator != null) {
          indicators.add(indicator);
        }
      }
      catch (e) {
        log("ETF agent analysis: Error parsing date: $e");
      }
    });

    if(priceData.isNotEmpty) {
      return AnalysisRespond(indicators, candles, priceData);
    }
    return null;
  }
}

double? parseNum(dynamic value) {
  if (value == null || value == 'null' || value == 'NaN') return null;
  final cleaned = value.toString().replaceAll(RegExp(r'JS:\d+'), '');
  return double.tryParse(cleaned);
}