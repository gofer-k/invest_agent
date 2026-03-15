import 'package:invest_agent/model/portfolio_config.dart';

import 'asset_config.dart';

typedef CacheFactory<T> = T Function(List<Object?> item);

class CacheRegistry {
  // A map that links Types to their specific factory functions
  static final Map<Type, CacheFactory<Object>> _factories = {
    PortfolioConfig: (item) => PortfolioConfig.from(item),
    AssetConfig: (item) => AssetConfig.from(item),
    // Add other models here:
  };

  static T create<T>(List<Object?> item) {
    final factory = _factories[T];
    if (factory == null) {
      throw Exception("Factory for $T not found. Did you register it?");
    }
    return factory(item) as T;
  }
}