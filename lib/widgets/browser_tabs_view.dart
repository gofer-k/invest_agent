import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:invest_agent/model/asset_config.dart';
import 'package:invest_agent/model/chart_style.dart';
import 'package:invest_agent/model/indicator_schema.dart';
import 'package:invest_agent/model/portfolio_schema.dart';
import 'package:invest_agent/model/results/indicator/price_result.dart';
import 'package:invest_agent/providers/price_controller.dart';
import 'package:invest_agent/providers/tab_window_session.dart';
import 'package:invest_agent/themes/app_themes.dart';
import 'package:invest_agent/widgets/charts/multi_chart.dart';
import 'package:invest_agent/widgets/utils/tabbed_window_type.dart';

class BrowserTabsView extends ConsumerWidget {
  const BrowserTabsView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sessionState = ref.watch(tabWindowSessionProvider());
    final sessionNotifier = ref.read(tabWindowSessionProvider().notifier);
    final tabs = sessionState.tabs.toList();

    if (tabs.isEmpty) {
      return const Center(
        child: Text(
          'No open chart tabs. Select an asset or portfolio and click "Open Tab".',
        ),
      );
    }

    final activeTab = sessionState.activeTab ?? tabs.first;

    return Column(
      children: [
        // Browser-like Tab Bar
        Container(
          height: 38,
          color: Theme.of(context).brightness == Brightness.dark
              ? const Color(0xFF2B2D30)
              : const Color(0xFFE0E0E0),
          child: Row(
            children: [
              Expanded(
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: tabs.length,
                  itemBuilder: (context, index) {
                    final tab = tabs[index];
                    final isActive = activeTab.hashCode == tab.hashCode;
                    final title = tab.type == TabbedWindowType.asset
                        ? (tab.cache as AssetConfig).symbol
                        : (tab.cache as PortfolioConfig).portfolioName;

                    return InkWell(
                      onTap: () => sessionNotifier.updateActiveTab(tab),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: isActive
                              ? (Theme.of(context).brightness == Brightness.dark
                                    ? const Color(0xFF3C3F41)
                                    : Colors.white)
                              : Colors.transparent,
                          border: Border(
                            right: BorderSide(
                              color: Theme.of(context).dividerColor,
                            ),
                            top: isActive
                                ? BorderSide(
                                    color:
                                        AppTheme.of(context).indicatorRate ??
                                        Colors.blue,
                                    width: 2,
                                  )
                                : BorderSide.none,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              tab.type == TabbedWindowType.asset
                                  ? Icons.show_chart
                                  : Icons.account_balance_wallet,
                              size: 14,
                              color: isActive ? Colors.blue : Colors.grey,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              title,
                              style: TextStyle(
                                fontWeight: isActive
                                    ? FontWeight.bold
                                    : FontWeight.normal,
                                fontSize: 12,
                              ),
                            ),
                            const SizedBox(width: 8),
                            InkWell(
                              onTap: () => sessionNotifier.removeTab(tab),
                              child: const Icon(Icons.close, size: 14),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
        // Active Tab Content
        Expanded(child: _buildTabContent(ref, activeTab)),
      ],
    );
  }

  Widget _buildTabContent(WidgetRef ref, TabWindow tab) {
    if (tab.type == TabbedWindowType.asset) {
      final asset = tab.cache as AssetConfig;
      final assetPriceAsync = ref.watch(assetPricesProvider(asset.id));
      return assetPriceAsync.when(
        data: (priceData) {
          if (priceData.isEmpty) {
            return const Center(child: Text("No data available"));
          }
          return LayoutBuilder(
            builder: (context, constraints) {
              final priceResult = IndexPrice(
                priceData: priceData,
                config: Indicator.priceIndicator(),
                style: ChartStyle.line,
              );
              return MultiChartView(
                priceData: priceResult,
                assetConfig: asset,
                chartHeight: constraints.maxHeight,
                prefixDomain: 0,
              );
            },
          );
        },
        error: (error, stackTrace) => Center(child: Text("Error: $error")),
        loading: () => const Center(child: CircularProgressIndicator()),
      );
    } else {
      return Center(
        child: Text(
          'Portfolio Tab: ${(tab.cache as PortfolioConfig).portfolioName}',
        ),
      );
    }
  }
}
