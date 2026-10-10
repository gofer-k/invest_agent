import 'package:invest_agent/model/results/strategies/strategy_schema.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'analysis_notifier.dart';
import 'cache_notifier.dart';
import 'load_database_provider.dart';
import 'model_config.dart';

part 'strategy_provider.g.dart';

@riverpod
class StrategyNotifier extends _$StrategyNotifier with AnalysisNotifierMixin<Strategy, StrategySchema> {
  
  @override
  Future<AnalysisState<Strategy>> build([CacheKeyType? type, bool? keepAlive]) async {
    if (keepAlive == true) ref.keepAlive();
    
    // Initialize mixin properties
    mixinSchema = const StrategySchema();
    mixinCacheKeyType = type ?? CacheKeyType.analysisCache;

    // Await prerequisites
    final dbPathResult = await ref.watch(loadDatabaseProvider(mixinCacheKeyType).future);
    final assets = await ref.watch(assetsLoaderProvider.future);

    mixinDbPath = dbPathResult;

    // Watch the underlying cache provider to react to database changes automatically
    final items = await ref.watch(cacheProvider<Strategy, StrategySchema>(mixinSchema, mixinDbPath).future);
    
    // Fill strategy objects with asset metadata
    final filledItems = items.map((s) => s.fillAssets(assets)).toList();
    return AnalysisState(cachedConfig: filledItems);
  }

  @override
  Future<List<Strategy>> fetchAll() async {
    // Manual fetch logic (delegates to the underlying provider via super)
    final items = await super.fetchAll();

    if (!ref.mounted) return items;

    final assets = ref.read(assetsLoaderProvider).value ?? const [];
    return items.map((s) => s.fillAssets(assets)).toList();
  }
}
