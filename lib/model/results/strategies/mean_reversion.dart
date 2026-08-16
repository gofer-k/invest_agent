import 'package:invest_agent/model/asset_config.dart';
import 'package:invest_agent/model/indicator_schema.dart';
import 'package:invest_agent/model/results/strategies/strategy_schema.dart';
import 'package:sealed_currencies/sealed_currencies.dart';

import '../../cache_schema.dart';
import '../../period_type.dart';

class MeanReversionConfig extends Strategy {
  final AssetConfig asset;
  final Indicator indicator;

  MeanReversionConfig({
    super.type = StrategyType.meanReversion,
    required super.id,
    required super.name,
    required super.cash,
    required super.currency,
    required super.analysisPeriod,
    required super.beginDate,
    required super.endDate,
    required this.asset,
    required this.indicator});

  CacheUniqueKey get uniqueKey {
    return "$name-$type--${asset.toDetailString()} ${indicator.uniqueKey}".hashCode;
  }

  factory MeanReversionConfig.emptyStrategy() {
    final epoch = DateTime.fromMillisecondsSinceEpoch(0);
    return MeanReversionConfig(
      id: Strategy.defaultId,
      asset: AssetConfig.defaultAsset(),
      type: StrategyType.meanReversion,
      indicator: Indicator.emptyIndicator(),
      name: '',
      cash: 10000.0,
      currency: const FiatCurrency.pln(),
      analysisPeriod: PeriodType.year,
      beginDate: epoch,
      endDate: epoch);
  }

  /*
  {
    "asset": 20,
    "cash"; 10000.0
    "currency|; "pln",
    "analysisPeriod"; "year",
    "beginDate"; "2023-01-01",
    "endDate|; "2023-12-31",
    "indicator": [
      {
        "sma": {
          "window": {
            "value": "50",
            "edit": "1",
            "type": "int",
            "visible": "1"
          },
          "chart": {
            "value": "#FF34BBE6",
            "edit": "1",
            "type": "color",
            "visible": "1"
          },
          "golden_cross": {
            "value": "#FFF7D038",
            "edit": "1",
            "type": "color",
            "visible": "0"
          },
          "death_cross": {
            "value": "#FFE6261F",
            "edit": "1",
            "type": "color",
            "visible": "0"
          }
        }
      }
    ]
  }
   */
  @override
  factory MeanReversionConfig.fromMap(int id, String name,
      double cash,
      FiatCurrency currency,
      PeriodType analysisPeriod,
      DateTime beginDate, DateTime endDate,
      Map<String, dynamic> params) {

    final assetId = params['asset'] as int? ?? 0;
    final List<dynamic> indicatorList = params['indicator'] ?? [];

    Indicator indicator;
    if (indicatorList.isNotEmpty) {
      // Access the first element safely
      final Map<dynamic, dynamic> firstEntry = indicatorList.first ?? {};

      if (firstEntry.isNotEmpty) {
        // The key is the indicator type (e.g., 'sma')
        final String typeStr = firstEntry.keys.first.toString();

        // Use safe casting or 'Map.from' to avoid Type errors
        final Map<String, dynamic> innerParams = Map<String, dynamic>.from(firstEntry[typeStr] ?? {});

        indicator = Indicator(
          id: 0, // Or extract if available
          name: typeStr.toUpperCase(),
          type: IndicatorType.values.firstWhere(
                  (e) => e.name == typeStr,
              orElse: () => IndicatorType.undefined
          ),
          parameters: innerParams,
        );
      } else {
        indicator = Indicator.emptyIndicator();
      }
    } else {
      indicator = Indicator.emptyIndicator();
    }

    return MeanReversionConfig(
      id: id,
      name: name,
      cash: cash,
      currency: currency,
      analysisPeriod: analysisPeriod,
      beginDate: beginDate,
      endDate: endDate,
      asset: AssetConfig.of(id: assetId),
      indicator: indicator,
    );
  }

  MeanReversionConfig copyWith({
    int? newId,
    String? newName,
    StrategyType? newType,
    AssetConfig? newAsset,
    double? newCash,
    FiatCurrency? newCurrency,
    PeriodType? newAnalysisPeriod,
    DateTime? newBeginDate,
    DateTime? newEndDate,
    Indicator? newIndicator}) {
    return MeanReversionConfig(
        id: newId ?? id,
        asset: newAsset ?? asset,
        type: StrategyType.meanReversion,
        indicator: newIndicator ?? indicator,
        name: newName ?? name,
        cash: newCash ?? cash,
        currency: newCurrency ?? currency,
        analysisPeriod: newAnalysisPeriod ?? analysisPeriod,
        beginDate: newBeginDate ?? beginDate,
        endDate: newEndDate ?? endDate);
  }

  @override
  Map<String, dynamic> toMap() => {
    ...super.toMap(),
    "asset": asset.id,
    "indicator": indicator.parameters.isNotEmpty
      ? [{indicator.type.shortName.toLowerCase(): indicator.parameters}]
      : []
  };

  @override
  bool operator ==(Object other) =>
    (identical(this, other)) ||
    (other is MeanReversionConfig &&
      runtimeType == other.runtimeType &&
      asset == other.asset &&
      indicator == other.indicator &&
      super == other);

  @override
  int get hashCode => Object.hash(
    super.hashCode,
    asset,
    indicator);

  @override
  List<Object?> get props => [...super.props, asset, indicator];
}