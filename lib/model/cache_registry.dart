import 'package:invest_agent/model/portfolio_config.dart';
import 'package:invest_agent/model/user_account.dart';
import 'package:invest_agent/model/analysis_schema.dart';

import 'asset_config.dart';
import 'results/indicator/price_result.dart';
import 'indicator_schema.dart';
import 'multi_chart_schema.dart';

typedef CacheFactory<T> = T Function(List<Object?> item);

class CacheRegistry {
  // A map that links Types to their specific factory functions
  static final Map<Type, CacheFactory<Object>> _factories = {
    PortfolioConfig: (item) => PortfolioConfig.from(item),
    AssetConfig: (item) => AssetConfig.from(item),
    UserAccount: (item) => UserAccount.fromList(item),
    IndexPriceItem: (item) => IndexPriceItem.from(item),
    AnalysisEntry: (item) => AnalysisEntry.from(item),
    Indicator: (item) => Indicator.from(item),
    MultiChartConfig: (item) => MultiChartConfig.from(item),
  };

  static T create<T>(List<Object?> item) {
    final factory = _factories[T];
    if (factory == null) {
      throw Exception("Factory for $T not found. Did you register it?");
    }
    return factory(item) as T;
  }
}
