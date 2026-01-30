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
}

class GoldenCross extends BaseIndicatorValue{
  final int? cross;

  GoldenCross({required super.dateTime, this.cross});
}

class DeathCross extends BaseIndicatorValue{
  final int? cross;

  DeathCross({required super.dateTime, this.cross});
}

class RSI extends BaseIndicatorValue {
  final double rsi;

  RSI({required super.dateTime, required this.rsi});
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

  Indicators(this.macd, this.sma, this.ema, this.rsi);

  static Indicators? fromJson(DateTime dateTime, Map<String, dynamic> jsonMap) {
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

    final jsonRSI = parseNum(jsonMap["RSI"]);
    final rsi = RSI(dateTime: dateTime, rsi: jsonRSI ?? 0.0);

    List<MACD> macd = [];
    final macdTypes = ["MACD_12_26", "MACD_50_200"];
    for (String macdType in macdTypes) {
      final jsonMACD = jsonMap[macdType] as Map<String, dynamic>;
      final macdIndicator = MACD.fromJson(dateTime, jsonMACD, macdType);
      if (macdIndicator != null) {
        macd.add(macdIndicator);
      }
    }
    return Indicators(macd, sma, ema, rsi);
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
    if (strength != null && (strength < 0.0 || strength > 1.0)) {
      return null;
    }
    if (price == null) {
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
  
  Future<double> getPriceRangeAsync() async {
    return getPriceRange();
  }

  double getPriceRange() {
    if (priceData.isEmpty) {
      return 0.0;
    }
    if (priceRange != 0.0) {
      return priceRange;
    }
    
    maxPrice = getMaxPrice();
    minPrice = getMinPrice();
    priceRange = (maxPrice - minPrice).abs();
    return priceRange;
  }

  Future<double> getMaxPriceAsync() async {
    return getMaxPrice();
  }

  double getMaxPrice() {
    if (priceData.isEmpty) {
      return 0.0;
    }
    if (maxPrice != 0.0) {
      return maxPrice;
    }
    
    final maxPriceItem = priceData.reduce(
          (currentItem, nextItem) =>
      currentItem.closePrice > nextItem.closePrice ? currentItem : nextItem,
    );
    maxPrice = maxPriceItem.closePrice;
    return maxPrice;
  }

  Future<double> getMinPriceAsync() async {
    return getMinPrice();
  }

  double getMinPrice() {
    if (priceData.isEmpty) {
      return 0.0;
    }
    if (minPrice != 0.0) {
      return minPrice;
    }
    final minPriceItem = priceData.reduce(
          (currentItem, nextItem) =>
      currentItem.closePrice <= nextItem.closePrice ? currentItem : nextItem,
    );
    minPrice = minPriceItem.closePrice;
    return minPrice;
  }

  double getMinVolume() {
    return priceData.reduce((value, element) => value.volume <= element.volume ? value : element).volume;
  }

  double getMaxVolume() {
    return priceData.reduce((value, element) => value.volume > element.volume ? value : element).volume;
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

  List<PriceData> getPriceData(int prefixWindow) {
    return priceData.sublist(prefixWindow);
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

  double getMinMACD(MACDType macdType) {
    final macdData = getMacd(macdType);
    final minMacd = macdData.reduce((value, element) => value.macd <= element.macd ? value : element).macd;
    final minSignal = macdData.reduce((value, element) => value.signal <= element.signal ? value : element).signal;
    return min(minMacd, minSignal);
  }

  double getMaxMACD(MACDType macdType) {
    final macdData = getMacd(macdType);
    final maxMacd = macdData.reduce((value, element) => value.macd > element.macd ? value : element).macd;
    final maxSignal = macdData.reduce((value, element) => value.signal > element.signal ? value : element).signal;
    return max(maxMacd, maxSignal);
  }

  List<RSI> getRsi() {
    final rsi = <RSI>[];
    for (var indicator in indicators) {
      rsi.add(indicator.rsi);
    }
    return rsi;
  }

  double getMinRsi() {
    final data = getRsi();
    return data.reduce((value, element) => value.rsi <= element.rsi ? value : element).rsi;
  }

  double getMaxRsi() {
    final data = getRsi();
    return data.reduce((value, element) => value.rsi > element.rsi ? value : element).rsi;
  }
  
  void _reset() {
    priceRange = 0.0;
    maxPrice = 0.0;
    minPrice = 0.0;
  }

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
}

double? parseNum(dynamic value) {
  if (value == null || value == 'null' || value == 'NaN') return null;
  final cleaned = value.toString().replaceAll(RegExp(r'JS:\d+'), '');
  return double.tryParse(cleaned);
}