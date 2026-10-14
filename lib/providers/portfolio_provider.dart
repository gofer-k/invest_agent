
import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'analysis_notifier.dart';
import 'package:invest_agent/model/portfolio_schema.dart';

import 'cache_notifier.dart';
import 'load_database_provider.dart';
import 'model_config.dart';

part 'portfolio_provider.g.dart';

@riverpod
class PortfolioNotifier extends _$PortfolioNotifier
    with AnalysisNotifierMixin<PortfolioConfig, PortfolioConfigSchema> {

  @override
  Future<AnalysisState<PortfolioConfig>> build([CacheKeyType? type, bool? keepAlive]) async {
    if (keepAlive == true) ref.keepAlive();

    // Initialize mixin properties
    mixinSchema = const PortfolioConfigSchema();
    mixinCacheKeyType = type ?? CacheKeyType.analysisCache;

    // Await prerequisites
    final dbPathResult = await ref.watch(loadDatabaseProvider(mixinCacheKeyType).future);
    final assets = await ref.watch(assetsLoaderProvider.future);

    mixinDbPath = dbPathResult;
// Watch the underlying cache provider to react to database changes automatically
    final items = await ref.watch(cacheProvider<PortfolioConfig,
        PortfolioConfigSchema>(mixinSchema, mixinDbPath).future);

    // Fill strategy objects with asset metadata
    final filledItems = items.map((s) => s.fillAssets(assets)).toList();
    return AnalysisState(cachedConfig: filledItems);
  }
}