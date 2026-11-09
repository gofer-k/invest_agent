import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:invest_agent/model/results/portfolio_result.dart';

import '../providers/trading_analytics_service.dart';
import '../widgets/utils/display_expression.dart';
import '../widgets/utils/popup_widget.dart';

class RiskManagementPanel extends ConsumerStatefulWidget {
  const RiskManagementPanel({super.key});

  @override
  ConsumerState<RiskManagementPanel> createState() => _RiskManagementPanelState();
}

class _RiskManagementPanelState extends ConsumerState<RiskManagementPanel> {
  @override
  Widget build(BuildContext context) {
    final activePortfolioId = ref.watch(activeRiskPortfolioIdProvider)  ;
    if (activePortfolioId == null) {
      return const Center(child: Text("No active portfolio selected"));
    }
    final analysisAsync = ref.watch(
        portfolioResultProvider(portfolioId: activePortfolioId));

    return analysisAsync.when(
      data: (result) => _buildRiskMetrics(result),
      error: (err, stackTrace) => Center(child: Text('Risk evaluation error: $err')), 
      loading: () => const Center(child: CircularProgressIndicator()));
  }

  Widget _buildRiskMetrics(PortfolioResult? result) {
    return Column(
      children: [
        Text("Risk metrics for portfolio ${result?.portfolioConfig.portfolioName}"),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Text("Begin data: ${result?.portfolioConfig.startDateTime}"),
            Text("End data: ${result?.portfolioConfig.endDateTime}"),
          ],
        ),
        ListView(
          children: [
            _showMetricResult(metric: PerformanceMetricsType.totalReturn, metricValue: result?.performanceMetrics.totalReturn ?? 0.0),
            _showMetricResult(metric: PerformanceMetricsType.annualizedReturn, metricValue: result?.performanceMetrics.annualizedReturn ?? 0.0),
            _showMetricResult(metric: PerformanceMetricsType.cagr, metricValue: result?.performanceMetrics.cagr ?? 0.0),
            _showMetricResult(metric: PerformanceMetricsType.maxDrawdown, metricValue: result?.performanceMetrics.maxDrawdown ?? 0.0),
            _showMetricResult(metric: PerformanceMetricsType.volatility, metricValue: result?.performanceMetrics.volatility ?? 0.0),
            _showMetricResult(metric: PerformanceMetricsType.sharpeRatio, metricValue: result?.performanceMetrics.sharpeRatio ?? 0.0),
            _showMetricResult(metric: PerformanceMetricsType.sortinoRatio, metricValue: result?.performanceMetrics.sortinoRatio ?? 0.0),
            _showMetricResult(metric: PerformanceMetricsType.calmar, metricValue: result?.performanceMetrics.calmar ?? 0.0),
            _showMetricResult(metric: PerformanceMetricsType.alpha, metricValue: result?.performanceMetrics.alpha ?? 0.0),
            _showMetricResult(metric: PerformanceMetricsType.beta, metricValue: result?.performanceMetrics.beta ?? 0.0),
            _showMetricResult(metric: PerformanceMetricsType.correlation, metricValue: result?.performanceMetrics.correlation ?? 0.0),
            _showMetricResult(metric: PerformanceMetricsType.trackingError, metricValue: result?.performanceMetrics.trackingError ?? 0.0),
            _showMetricResult(metric: PerformanceMetricsType.trackingDiff, metricValue: result?.performanceMetrics.trackingDiff ?? 0.0),
            _showMetricResult(metric: PerformanceMetricsType.expenseRatio, metricValue: result?.performanceMetrics.expenseRatio ?? 0.0),
            _showMetricResult(metric: PerformanceMetricsType.concentration, metricValue: result?.performanceMetrics.concentration ?? 0.0),
            _showMetricResult(metric: PerformanceMetricsType.dividendYield, metricValue: result?.performanceMetrics.dividendYield ?? 0.0),
          ]
        )
      ]
    );
  }

  Widget _showMetricResult({
    required PerformanceMetricsType metric,
    required double metricValue,
    double horizontalPaddingItem = 4.0,
    double verticalPaddingItem = 4.0,
    double rightColScale = 2.0}) {

    return PopupWidget(
        horizontalPadding: horizontalPaddingItem,
        verticalPadding: verticalPaddingItem,
        content: Text("T$metric: $metricValue"),
        popupDialog:
        DisplayExpression(
            context: context,
            expression: metric.description,
            scale: rightColScale)
    );
  }
}