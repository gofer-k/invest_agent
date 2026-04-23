import 'dart:developer';
import 'dart:math' hide log;

import 'analysis_period.dart';

class BaseIndicatorValue {
  final DateTime dateTime;

  const BaseIndicatorValue({required this.dateTime});
}

// Build SMA chart:
// Map<rollingWindow, List<SMA>>
class SimpleMovingAverage extends BaseIndicatorValue {
  final double? rollingStd;
  final double? rollingMean;
  final BellingerBands? bellingersBands;
  final int? rollingWindow;

  SimpleMovingAverage({required super.dateTime, this.rollingWindow, this.rollingStd, this.rollingMean, this.bellingersBands});

  static SimpleMovingAverage? fromJson(DateTime dateTime, Map<String, dynamic> jsonMap) {
    final rollingMean = parseNum(jsonMap['rolling_mean']);
    final rollingStd = parseNum(jsonMap['rolling_std']);
    final rollingWindow = parseNum(jsonMap["window"]);
    if (rollingMean == null && rollingStd == null && rollingWindow == null) {
      return null;
    }

    return SimpleMovingAverage(
      dateTime: dateTime,
      rollingWindow: rollingWindow?.toInt(),
      rollingMean: rollingMean,
      rollingStd: rollingStd,
      bellingersBands: BellingerBands.fromJson(dateTime, jsonMap));
  }

  Map<String, dynamic> toJson() => {
    "rolling_mean": rollingMean,
    "rolling_std": rollingStd,
    "window": rollingWindow,
    ...?bellingersBands?.toJson(),
  };
}

// Build Bellingers band charts:
// BB upper band:  Map<rollingWindow, List<BellingerBand>>
// BB lower band:  Map<rollingWindow, List<BellingerBand>>
// BB middle band:  Map<rollingWindow, List<BellingerBand>>
class BellingerBandEntry extends BaseIndicatorValue{
  final double? stdValue;

  BellingerBandEntry({required super.dateTime, this.stdValue});
}

typedef BellingerBand = List<BellingerBandEntry>;

enum BollingerBandType {
  lowerBB,
  upperBB,
  middleBB,
}

class BellingerBands extends BaseIndicatorValue{
  final double? upperBB;
  final double? lowerBB;
  final double? widthBB;
  final double? percentBB;
  BellingerBands({required super.dateTime, this.upperBB, this.lowerBB, this.widthBB, this.percentBB});

  static BellingerBands? fromJson(DateTime dateTime, Map<String, dynamic> jsonMap) {
    return BellingerBands(
      dateTime: dateTime,
      lowerBB: parseNum(jsonMap['BB_lower']),
      upperBB: parseNum(jsonMap['BB_upper']),
      percentBB: parseNum(jsonMap['BB_percent']),
      widthBB: parseNum(jsonMap['BB_width']));
  }

  Map<String, dynamic> toJson() => {
    "BB_lower": lowerBB,
    "BB_upper": upperBB,
    "BB_percent": percentBB,
    "BB_width": widthBB,
  };
}

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

  Map<String, dynamic> toJson() => {
    "value": ema,
    "window": rollingWindow,
  };
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
  final double macd;
  final double signal;
  final double hist;
  final MACDType type;

  MACD({required super.dateTime, required this.type, required this.macd, required this.signal, required this.hist});

  factory MACD.fromType(DateTime dateTime, MACDType type, {macd = double, signal = double, hist = double}) {
    return MACD(dateTime: dateTime, type: type, macd: macd, signal: signal, hist: hist);
  }

  static MACD? fromJson(DateTime dateTime, Map<String, dynamic> jsonMap, String jsonMacdType) {
    final macdType = macdTypeFromString(jsonMacdType);
    if (macdType == null) {
      return null;
    }
    final macd = parseNum(jsonMap['value']);
    final signal = parseNum(jsonMap['signal']);
    final hist = parseNum(jsonMap['hist']);
    if (macd != null && signal != null && hist != null) {
      return MACD(
          dateTime: dateTime,
          type: macdType,
          macd: macd,
          signal: signal,
          hist: hist
      );
    }
    return null;
  }

  Map<String, dynamic> toJson() => {
    "value": macd,
    "signal": signal,
    "hist": hist,
  };
}

enum IndicatorType {
  EMA,
  SMA,
  MACD,
  RSI
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
  final RSI rsi;
  final Map<String, dynamic> other; // For extendability

  Indicators(this.macd, this.sma, this.ema, this.rsi, {this.other = const {}});

  static Indicators? fromJson(DateTime dateTime, Map<String, dynamic> jsonMap) {
    final jsonSMa = (jsonMap["SMA"] ?? []) as List<dynamic>;
    Map<int, SimpleMovingAverage> sma = <int, SimpleMovingAverage>{};
    for (var element in jsonSMa) {
      final jsonValues = element as Map<String, dynamic>;
      final smaIndicator = SimpleMovingAverage.fromJson(dateTime, jsonValues);
      if (smaIndicator != null && smaIndicator.rollingWindow != null) {
        sma.putIfAbsent(smaIndicator.rollingWindow!, () => smaIndicator);
      }
    }

    final jsonEMa = (jsonMap["EMA"] ?? []) as List<dynamic>;
    Map<int, ExponentialMovingAverage> ema = <int, ExponentialMovingAverage>{};
    for (var element in jsonEMa) {
      final jsonValues = element as Map<String, dynamic>;
      final emaIndicator = ExponentialMovingAverage.fromJson(dateTime, jsonValues);
      if (emaIndicator != null && emaIndicator.rollingWindow != null) {
        ema.putIfAbsent(emaIndicator.rollingWindow!, () => emaIndicator);
      }
    }

    final jsonRSI = parseNum(jsonMap["RSI"]);
    final rsi = RSI(dateTime: dateTime, rsi: jsonRSI ?? 0.0);

    List<MACD> macd = [];
    final macdTypes = ["MACD_12_26", "MACD_50_200"];
    for (String macdType in macdTypes) {
      final jsonMACD = jsonMap[macdType] as Map<String, dynamic>?;
      if (jsonMACD != null) {
        final macdIndicator = MACD.fromJson(dateTime, jsonMACD, macdType);
        if (macdIndicator != null) {
          macd.add(macdIndicator);
        }
      }
    }

    // Capture other fields
    final knownFields = {"SMA", "EMA", "RSI", ...macdTypes};
    final other = Map<String, dynamic>.from(jsonMap)..removeWhere((key, value) => knownFields.contains(key));

    return Indicators(macd, sma, ema, rsi, other: other);
  }

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{
      "SMA": sma.values.map((e) => e.toJson()).toList(),
      "EMA": ema.values.map((e) => e.toJson()).toList(),
      ...rsi.toJson(),
      ...other,
    };
    for (var m in macd) {
      map[m.type.name] = m.toJson();
    }
    return map;
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

class PriceData extends BaseIndicatorValue {
  final double openPrice;
  final double closePrice;
  final double highPrice;
  final double lowPrice;
  final double volume;
  final double volumeZscore;

  PriceData({required super.dateTime,
    required this.openPrice,
    required this.closePrice,
    required this.highPrice,
    required this.lowPrice,
    required this.volume,
    required this.volumeZscore});
}

class AnalysisRespond {
  final List<PriceData> priceData;
  final List<Indicators> indicators;
  final List<CandleStickItem> candles;
  double priceRange = 0.0;
  double maxPrice = 0.0;
  double minPrice = 0.0;
  PeriodType period;

  AnalysisRespond(this.indicators, this.candles, this.priceData, this.period);

  void changePeriod(PeriodType period) {
    this.period = period;
    _reset();
  }

  double getMaxPrice(DateTime? startDate, DateTime? endDate) {
    if (priceData.isEmpty) {
      return 0.0;
    }

    final priceDataFiltered = (startDate != null && endDate != null) ? getPriceDataFiltered(0, startDate, endDate) : priceData;
    final maxPriceItem = priceDataFiltered.reduce(
          (currentItem, nextItem) =>
      currentItem.closePrice > nextItem.closePrice ? currentItem : nextItem,
    );
    maxPrice = maxPriceItem.closePrice;
    return maxPrice;
  }

  double getMinPrice(DateTime? startDate, DateTime? endDate) {
    if (priceData.isEmpty) {
      return 0.0;
    }

    final priceDataFiltered = (startDate != null && endDate != null) ? getPriceDataFiltered(0, startDate, endDate) : priceData;
    final minPriceItem = priceDataFiltered.reduce(
            (currentItem, nextItem) =>
        currentItem.closePrice <= nextItem.closePrice ? currentItem : nextItem);

    minPrice = minPriceItem.closePrice;
    return minPrice;
  }

  double getMinVolume(DateTime? startDate, DateTime? endDate) {
    final priceDataFiltered = (startDate != null && endDate != null) ? getPriceDataFiltered(0, startDate, endDate) : priceData;
    return priceDataFiltered.reduce((value, element) => value.volume <= element.volume ? value : element).volume;
  }

  double getMaxVolume(DateTime? startDate, DateTime? endDate) {
    final priceDataFiltered = (startDate != null && endDate != null) ? getPriceDataFiltered(0, startDate, endDate) : priceData;
    return priceDataFiltered.reduce((value, element) => value.volume > element.volume ? value : element).volume;
  }

  Future<List<SimpleMovingAverage>> getFutureSMA(int rollingWindow) async {
    return getSMA(rollingWindow);
  }

  List<SimpleMovingAverage> getSMA(int rollingWindow) {
    final sma = <SimpleMovingAverage>[];
    final subIndicators = indicators.sublist(rollingWindow);
    for (var indicator in subIndicators) {
      if (indicator.sma.containsKey(rollingWindow)) {
        sma.add(indicator.sma[rollingWindow]!);
      }
    }
    return sma;
  }
  
  Future<BellingerBand> getFutureBollingerBand(BollingerBandType type, int rollingWindow) async {
    return getBollingerBand(type, rollingWindow);
  }

  BellingerBand getBollingerBand(BollingerBandType type, int rollingWindow) {
    final BellingerBand band = [];
    final subIndicators = indicators.sublist(rollingWindow);
    for (var indicator in subIndicators) {
      if (indicator.sma.containsKey(rollingWindow)) {
        final sma = indicator.sma[rollingWindow]!;
        if (sma.bellingersBands != null) {
          final value = switch(type) {
            BollingerBandType.lowerBB => sma.bellingersBands!.lowerBB,
            BollingerBandType.upperBB => sma.bellingersBands!.upperBB,
            BollingerBandType.middleBB => sma.rollingMean,
          };
          band.add(BellingerBandEntry(dateTime: sma.dateTime, stdValue: value));
        }
      }
    }
    return band;
  }

  Future<List<PriceData>> getRollingVolume(int rollingWindow) async {
    return priceData.sublist(rollingWindow);
  }

  List<PriceData> getPriceData(int prefixWindow, DateTime? startDate, DateTime? endDate) {
    return priceData.sublist(prefixWindow);
  }

  List<PriceData> getPriceDataFiltered(int prefixWindow, DateTime startDate, DateTime endDate) {
    final priceDataFiltered =
    priceData.where(
            (element) => element.dateTime.isAfter(startDate)
            && element.dateTime.isBefore(endDate)).toList();
    return priceDataFiltered.sublist(prefixWindow);
  }

  List<DateTime> getDateTimeDomain(int prefixWindow) {
    return priceData.sublist(prefixWindow).map((element) => element.dateTime).toList();
  }

  List<MACD> getMacd(MACDType type) {
    final macd = <MACD>[];
    for (var indicator in indicators) {
      final newMacd = indicator.macd.firstWhere((macd) => macd.type == type);
      macd.add(newMacd);
    }
    return macd;
  }

  List<MACD> getMacdFiltered(MACDType type, DateTime startDate, DateTime endDate) {
    final macd = <MACD>[];
    for (var indicator in indicators) {
      if (indicator.rsi.dateTime.isAfter(startDate) && indicator.rsi.dateTime.isBefore(endDate)) {
        final newMacd = indicator.macd.firstWhere((macd) => macd.type == type);
        macd.add(newMacd);
      }
    }
    return macd;
  }
  
  double getMinMACD(MACDType macdType, DateTime? startDate, DateTime? endDate) {
    final dataFiltered = (startDate != null && endDate != null) ? getMacdFiltered(macdType, startDate, endDate) : getMacd(macdType);
    final minMacd = dataFiltered.reduce((value, element) => value.macd <= element.macd ? value : element).macd;
    final minSignal = dataFiltered.reduce((value, element) => value.signal <= element.signal ? value : element).signal;
    return min(minMacd, minSignal);
  }

  double getMaxMACD(MACDType macdType, DateTime? startDate, DateTime? endDate) {
    final dataFiltered = (startDate != null && endDate != null) ? getMacdFiltered(macdType, startDate, endDate) : getMacd(macdType);
    final maxMacd = dataFiltered.reduce((value, element) => value.macd > element.macd ? value : element).macd;
    final maxSignal = dataFiltered.reduce((value, element) => value.signal > element.signal ? value : element).signal;
    return max(maxMacd, maxSignal);
  }

  List<RSI> getRsi() {
    final rsi = <RSI>[];
    for (var indicator in indicators) {
      rsi.add(indicator.rsi);
    }
    return rsi;
  }

  List<RSI> getRsiFiltered(int prefixWindow, DateTime startDate, DateTime endDate) {
    final rsi = <RSI>[];
    for (var indicator in indicators) {
      if (indicator.rsi.dateTime.isAfter(startDate) && indicator.rsi.dateTime.isBefore(endDate)) {
        rsi.add(indicator.rsi);
      }
    }
    return rsi;
  }

  double getMinRsi(DateTime? startDate, DateTime? endDate) {
    final data = (startDate != null && endDate != null) ? getRsiFiltered(0, startDate, endDate) : getRsi();
    return data.reduce((value, element) => value.rsi <= element.rsi ? value : element).rsi;
  }

  double getMaxRsi(DateTime? startDate, DateTime? endDate) {
    final data = (startDate != null && endDate != null) ? getRsiFiltered(0, startDate, endDate) : getRsi();
    return data.reduce((value, element) => value.rsi > element.rsi ? value : element).rsi;
  }
  
  void _reset() {
    priceRange = 0.0;
    maxPrice = 0.0;
    minPrice = 0.0;
  }

  static AnalysisRespond? fromJsonSync(Map<String, dynamic> jsonMap) {
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
        final volZscore = parseNum(metaData["VolumeZscore"]);

        if (openPrice != null && closePrice != null && highPrice != null && lowPrice != null && volume != null) {
          priceData.add(PriceData(dateTime: dateTime,
            openPrice: openPrice,
            closePrice: closePrice,
            highPrice: highPrice,
            lowPrice: lowPrice,
            volume: volume,
            volumeZscore: volZscore ?? 0.0
          ));
        }

        final jsonCandle = value["candlestick"] as Map<String, dynamic>;
        final candleItem = CandleStickItem.fromJson(dateTime, openPrice, closePrice, highPrice, lowPrice, volume, jsonCandle);
        if (candleItem != null) {
          candles.add(candleItem);
        }

        final jsonIndicators = value["indicators"] as Map<String, dynamic>;
        final indicator = Indicators.fromJson(dateTime, jsonIndicators);
        if (indicator != null) {
          indicators.add(indicator);
        }
      }
      catch (e) {
        log("ETF agent analysis: Error parsing date: $e");
      }
    });

    if(priceData.isNotEmpty) {
      return AnalysisRespond(indicators, candles, priceData, PeriodType.max);
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
            "VolumeZscore": priceData[i].volumeZscore,
          },
          "indicators": indicators[i].toJson(),
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
