import 'package:invest_agent/model/portfolio_schema.dart';
import 'package:invest_agent/providers/price_controller.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../model/chart_style.dart';
import '../model/indicator_schema.dart';
import '../model/results/indicator/price_result.dart';
import 'analysis_notifier.dart';
import 'cache_notifier.dart';
import 'load_database_provider.dart';
import 'model_config.dart';

part 'portfolio_provider.g.dart';

@riverpod
class PortfolioNotifier extends _$PortfolioNotifier
    with AnalysisNotifierMixin<PortfolioConfig, PortfolioConfigSchema> {
  @override
  Future<AnalysisState<PortfolioConfig>> build([
    CacheKeyType? type,
    bool? keepAlive,
  ]) async {
    if (keepAlive == true) ref.keepAlive();

    // Initialize mixin properties
    mixinSchema = const PortfolioConfigSchema();
    mixinCacheKeyType = type ?? CacheKeyType.analysisCache;

    // Await prerequisites
    final dbPathResult = await ref.watch(
      loadDatabaseProvider(mixinCacheKeyType).future,
    );
    final assets = await ref.watch(assetsLoaderProvider.future);

    mixinDbPath = dbPathResult;
    // Watch the underlying cache provider to react to database changes automatically
    final items = await ref.watch(
      cacheProvider<PortfolioConfig, PortfolioConfigSchema>(
        mixinSchema,
        mixinDbPath,
      ).future,
    );

    // Fill strategy objects with asset metadata
    final filledItems = items.map((s) => s.fillAssets(assets)).toList();
    return AnalysisState(cachedConfig: filledItems);
  }

  @override
  Future<List<PortfolioConfig>> fetchAll() async {
    final items = await super.fetchAll();
    if (!ref.mounted) return items;
    final assets = ref.read(assetsLoaderProvider).value ?? const [];
    return items.map((s) => s.fillAssets(assets)).toList();
  }
}

@riverpod
Future<IndexPrice?> portfolioPriceDomain(
  Ref ref,
  PortfolioConfig portfolio,
) async {
  final assets = portfolio.strategy?.getAssetAllocations() ?? [];
  if (assets.isNotEmpty) {
    return ref
        .watch(
          assetPricesPeriodProvider(
            assets.first.asset.id,
            portfolio.startDateTime,
            portfolio.endDateTime,
          ),
        )
        .when(
          data: (priceData) {
            return IndexPrice(
              priceData: priceData,
              style: ChartStyle.line,
              config: Indicator.priceIndicator(),
            );
          },
          error: (error, stackTrace) => null,
          loading: () => null,
        );
  }

  return null;
}

@riverpod
Future<List<IndexPrice>> portfolioAssetsPriceData(
  Ref ref,
  PortfolioConfig portfolio,
) async {
  final assets = portfolio.strategy?.getAssetAllocations() ?? [];
  final List<IndexPrice> prices = [];

  for (final allocation in assets) {
    final priceData = await ref.watch(
      assetPricesPeriodProvider(
        allocation.asset.id,
        portfolio.startDateTime,
        portfolio.endDateTime,
      ).future,
    );

    prices.add(
      IndexPrice(
        priceData: priceData,
        config: Indicator.priceIndicator(),
        style: ChartStyle.line,
      ),
    );
  }

  return prices;
}
