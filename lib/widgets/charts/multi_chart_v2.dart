import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:invest_agent/model/cache_schema.dart';
import 'package:invest_agent/model/results/indicator/price_result.dart';
import 'package:invest_agent/widgets/charts/controllers/time_controller.dart';
import 'package:invest_agent/widgets/charts/sync_chart.dart';

import '../../model/chart_style.dart';
import '../../model/indicator_schema.dart';
import '../../model/multi_chart_schema.dart';
import '../../model/period_type.dart';
import '../../model/portfolio_schema.dart';
import '../../providers/portfolio_provider.dart';
import 'controllers/crosshair_controller.dart';
import 'overlay_price_chart.dart';

class MultiChartView2 extends ConsumerStatefulWidget {
  final Cache featureConfig;
  final double chartHeight;
  final bool showCrosshair;
  final int prefixDomain;

  const MultiChartView2({
    super.key,
    required this.featureConfig,
    required this.chartHeight,
    this.showCrosshair = true,
    this.prefixDomain = 20, // 20 days before visualize a result data.
  });

  @override
  ConsumerState<MultiChartView2> createState() => _MultiChartView2State();
}

class _MultiChartView2State extends ConsumerState<MultiChartView2> {
  TimeController? _chartController;
  CrosshairController? _crosshairController;

  final PeriodType _selectedPeriod = PeriodType.year;
  final ChartStyle _priceChartStyle = ChartStyle.line;
  Cache? _lastFeatureConfig;

  @override
  void didUpdateWidget(MultiChartView2 oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.featureConfig != oldWidget.featureConfig) {
      _chartController?.dispose();
      _chartController = null;
      _crosshairController?.dispose();
      _crosshairController = null;
      _lastFeatureConfig = null;
    }
  }

  @override
  void dispose() {
    _chartController?.dispose();
    _crosshairController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final portfolio = widget.featureConfig as PortfolioConfig;
    final pricesAsync = ref.watch(portfolioAssetsPriceDataProvider(portfolio));
    final priceIndicator = Indicator.priceIndicator();
    final priceChartConfig = ChartConfig(
      mainChart: true,
      chartStyle: _priceChartStyle,
      indicatorConfig: priceIndicator,
    );

    return pricesAsync.when(
      data: (prices) {
        if (prices.isEmpty) {
          return const Center(child: Text('No portfolio data available'));
        }

        if (_chartController == null ||
            _lastFeatureConfig != widget.featureConfig) {
          _chartController?.dispose();
          _chartController = TimeController(
            periodType: _selectedPeriod,
            domain: prices.first.dateTimeDomain(widget.prefixDomain),
          );
          if (widget.showCrosshair && _crosshairController == null) {
            _crosshairController = CrosshairController();
          }
          _lastFeatureConfig = widget.featureConfig;
        }

        final controller = _chartController!;

        return ListView.builder(
          itemCount: prices.length,
          itemBuilder: (context, index) {
            final priceData = prices[index];
            return SizedBox(
              height: widget.chartHeight > 0 ? widget.chartHeight : 300.0,
              child: Container(
                decoration: BoxDecoration(
                  border: BoxBorder.all(color: Colors.transparent, width: 2.0),
                ),
                child: SyncChart(
                  controller: controller,
                  crosshairController: _crosshairController,
                  mainChartConfig: priceChartConfig,
                  minFunc: (startDate, endDate) => _getMinValue(
                    priceData,
                    controller.visibleStart,
                    controller.visibleEnd,
                  ),
                  maxFunc: (startDate, endDate) => _getMaxValue(
                    priceData,
                    controller.visibleStart,
                    controller.visibleEnd,
                  ),
                  overLayCharts: [
                    OverlayPriceChart(
                      data: priceData,
                      chartStyle: priceChartConfig.chartStyle,
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
      error: (err, stack) => Center(child: Text('Error: $err')),
      loading: () => const Center(child: CircularProgressIndicator()),
    );
  }

  double _getMaxValue(
    IndexPrice priceData,
    DateTime? startDate,
    DateTime? endDate,
  ) {
    return priceData.getMax(startDate, endDate);
  }

  double _getMinValue(
    IndexPrice priceData,
    DateTime? startDate,
    DateTime? endDate,
  ) {
    return priceData.getMin(startDate, endDate);
  }
}
