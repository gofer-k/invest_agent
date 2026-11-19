import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:invest_agent/model/results/portfolio_result.dart';

import '../providers/load_database_provider.dart';
import '../providers/portfolio_provider.dart';
import '../providers/trading_analytics_service.dart';
import '../widgets/utils/display_expression.dart';
import '../widgets/utils/popup_widget.dart';

class RiskManagementPanel extends ConsumerStatefulWidget {
  const RiskManagementPanel({super.key});

  @override
  ConsumerState<RiskManagementPanel> createState() =>
      _RiskManagementPanelState();
}

class _RiskManagementPanelState extends ConsumerState<RiskManagementPanel> {
  int? _lastEvaluatedPortfolioId;

  @override
  Widget build(BuildContext context) {
    final activePortFolioId = ref.watch(activeRiskPortfolioIdProvider);

    // Listen to activeRiskPortfolioIdProvider changes to trigger evaluation
    ref.listen<int?>(activeRiskPortfolioIdProvider, (previous, next) {
      if (next != null && next != previous) {
        _evaluatePortfolioById(next);
      }
    });

    if (activePortFolioId == null) {
      return const Center(child: Text("No portfolio selected"));
    }

    // Ensure initial or loaded portfolio is evaluated if not already cached
    final portfolioAsync = ref.watch(
      portfolioProvider(CacheKeyType.analysisCache),
    );
    final portfolios = portfolioAsync.value?.getItems() ?? [];
    final portfolio = portfolios
        .where((p) => p.id == activePortFolioId)
        .firstOrNull;

    final analyticsState = ref.watch(tradingAnalyticsServiceProvider);

    if (portfolio != null &&
        !analyticsState.cache.containsKey(activePortFolioId) &&
        _lastEvaluatedPortfolioId != activePortFolioId) {
      _lastEvaluatedPortfolioId = activePortFolioId;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          ref
              .read(tradingAnalyticsServiceProvider.notifier)
              .evaluate(portfolio);
        }
      });
    }

    final analysisAsync = ref.watch(
      portfolioResultProvider(portfolioId: activePortFolioId),
    );
    return analysisAsync.when(
      data: (result) => _buildRiskMetrics(result),
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, stack) => Center(child: Text('Error: $err')),
    );
  }

  void _evaluatePortfolioById(int portfolioId) {
    if (_lastEvaluatedPortfolioId == portfolioId) return;
    _lastEvaluatedPortfolioId = portfolioId;

    final portfolioAsync = ref.read(
      portfolioProvider(CacheKeyType.analysisCache),
    );
    final portfolios = portfolioAsync.value?.getItems() ?? [];
    final portfolio = portfolios.where((p) => p.id == portfolioId).firstOrNull;

    if (portfolio != null) {
      final analyticsState = ref.read(tradingAnalyticsServiceProvider);
      if (!analyticsState.cache.containsKey(portfolioId)) {
        ref.read(tradingAnalyticsServiceProvider.notifier).evaluate(portfolio);
      }
    }
  }

  Widget _buildRiskMetrics(PortfolioResult? result) {
    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 2.0, vertical: 2.0),
      children: [
        Text(
          "Risk metrics for portfolio: ${result?.portfolioConfig.portfolioName ?? 'N/A'}",
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const Divider(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Text(
              "Begin data: ${_fromDate(result?.portfolioConfig.startDateTime)}",
            ),
            Text("End data: ${_fromDate(result?.portfolioConfig.endDateTime)}"),
          ],
        ),
        const Divider(height: 24),
        DataTable(
          columnSpacing: 8,
          headingRowHeight: 0.0,
          columns: const [
            DataColumn(label: Text('Metric')),
            DataColumn(label: Text('Value'), numeric: true),
          ],
          rows: [
            _showMetricResult(
              metric: PerformanceMetricsType.totalReturn,
              metricValue: result?.performanceMetrics.totalReturn ?? 0.0,
            ),
            _showMetricResult(
              metric: PerformanceMetricsType.annualizedReturn,
              metricValue: result?.performanceMetrics.annualizedReturn ?? 0.0,
            ),
            _showMetricResult(
              metric: PerformanceMetricsType.cagr,
              metricValue: result?.performanceMetrics.cagr ?? 0.0,
            ),
            _showMetricResult(
              metric: PerformanceMetricsType.maxDrawdown,
              metricValue: result?.performanceMetrics.maxDrawdown ?? 0.0,
            ),
            _showMetricResult(
              metric: PerformanceMetricsType.volatility,
              metricValue: result?.performanceMetrics.volatility ?? 0.0,
            ),
            _showMetricResult(
              metric: PerformanceMetricsType.sharpeRatio,
              metricValue: result?.performanceMetrics.sharpeRatio ?? 0.0,
            ),
            _showMetricResult(
              metric: PerformanceMetricsType.sortinoRatio,
              metricValue: result?.performanceMetrics.sortinoRatio ?? 0.0,
            ),
            _showMetricResult(
              metric: PerformanceMetricsType.calmar,
              metricValue: result?.performanceMetrics.calmar ?? 0.0,
            ),
            _showMetricResult(
              metric: PerformanceMetricsType.alpha,
              metricValue: result?.performanceMetrics.alpha ?? 0.0,
            ),
            _showMetricResult(
              metric: PerformanceMetricsType.beta,
              metricValue: result?.performanceMetrics.beta ?? 0.0,
            ),
            _showMetricResult(
              metric: PerformanceMetricsType.correlation,
              metricValue: result?.performanceMetrics.correlation ?? 0.0,
            ),
            _showMetricResult(
              metric: PerformanceMetricsType.concentration,
              metricValue: result?.performanceMetrics.concentration ?? 0.0,
            ),
            _showMetricResult(
              metric: PerformanceMetricsType.trackingError,
              metricValue: result?.performanceMetrics.trackingError ?? 0.0,
            ),
            _showMetricResult(
              metric: PerformanceMetricsType.trackingDiff,
              metricValue: result?.performanceMetrics.trackingDiff ?? 0.0,
            ),
          ],
        ),
      ],
    );
  }

  DataRow _showMetricResult({
    required PerformanceMetricsType metric,
    required double metricValue,
    double rightColScale = 1.2,
  }) {
    final expressionDecoration = BoxDecoration(
      color: Theme.of(context).canvasColor.withValues(alpha: 0.9),
      borderRadius: BorderRadius.circular(8),
      border: Border.all(color: Colors.white24),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.2),
          blurRadius: 8,
          offset: const Offset(0, 2),
        ),
      ],
    );

    return DataRow(
      cells: [
        DataCell(
          PopupWidget(
            barrierColor: Colors.black54,
            content: Text("$metric", maxLines: 3),
            popupDialog: DisplayExpression(
              context: context,
              expression: metric.description,
              scale: rightColScale,
              decoration: expressionDecoration,
            ),
          ),
        ),
        DataCell(
          PopupWidget(
            barrierColor: Colors.black54,
            content: Text(
              (metricValue).toStringAsFixed(4),
              style: const TextStyle(fontFamily: 'monospace'),
            ),
            popupDialog: DisplayExpression(
              context: context,
              expression: metric.range,
              scale: rightColScale,
              decoration: expressionDecoration,
            ),
          ),
        ),
      ],
    );
  }

  String _fromDate(DateTime? date) {
    return date == null
        ? 'N/A'
        : '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }
}
