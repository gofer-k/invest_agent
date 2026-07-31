import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:invest_agent/model/analysis_period.dart';
import 'package:invest_agent/model/asset_config.dart';
import 'package:invest_agent/model/results/price_result.dart';
import 'package:invest_agent/utils/choice_chart_parameter.dart';
import 'package:invest_agent/widgets/utils/math_icons.dart';

import '../../model/chart_style.dart';
import '../../model/indicator_schema.dart';
import '../../providers/indicator_provider.dart';

class MainOverlayTaskbar extends ConsumerStatefulWidget {
  final AssetConfig? asset;
  final IndexPrice? priceData;
  final PeriodType selectedPeriod;
  final Indicator selectedIndicator;
  final ChartStyle selectedChartStyle;
  final Function(PeriodType)? onPeriodChange;
  final Function(Indicator)? onIndicatorChange;
  final Function(ChartStyle)? onChartStyleChange;

  const MainOverlayTaskbar({
    super.key,
    required this.asset,
    required this.priceData,
    required this.selectedPeriod,
    required this.selectedIndicator,
    required this.selectedChartStyle,
    required this.onPeriodChange,
    required this.onIndicatorChange,
    required this.onChartStyleChange});

  @override
  ConsumerState<MainOverlayTaskbar> createState() => _OverlayTaskbarState();
}

class _OverlayTaskbarState extends ConsumerState<MainOverlayTaskbar>{
  bool _showIndicatorSelector = false;
  bool _showPeriodSelector = false;
  bool _showChartStyleSelector = false;

  @override
  Widget build(BuildContext context) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            _buildChartStyleSelector(),
            if (widget.onChartStyleChange != null) const SizedBox(width: 8,),
            _buildPeriodSelector(),
            if (widget.onPeriodChange != null) const SizedBox(width: 8,),
            _buildIndicatorSelector(),
          ],
        ),
        const SizedBox(height: 4),
        _buildPriceInfo(),
      ],
    );
  }

  Widget _buildPeriodSelector() {
    if (widget.onPeriodChange == null) return Container();

    if (!_showPeriodSelector) {
      return TextButton(
          onPressed: () => setState(() => _showPeriodSelector = true),
          child: Text(widget.selectedPeriod.value)
      );
    }

    return choiceChartParameter<PeriodType>(
      Theme.of(context).textTheme.labelMedium,
      Colors.transparent,
      widget.selectedPeriod,
      PeriodType.values,
      (PeriodType period) {
        setState(() => _showPeriodSelector = false );
        widget.onPeriodChange?.call(period);
      }
    );
  }

  Widget _buildChartStyleSelector() {
    if (widget.onChartStyleChange == null) return Container();

    if (!_showChartStyleSelector) {
      return IconButton(
        onPressed: () => setState(() => _showChartStyleSelector = true),
        icon: widget.selectedChartStyle.icon,
      );
    }

    return choiceChartParameter<ChartStyle>(
      Theme.of(context).textTheme.labelMedium,
      Colors.transparent,
      widget.selectedChartStyle,
      ChartStyle.values,
      (ChartStyle chartStyle) {
        setState(() => _showChartStyleSelector = false);
        widget.onChartStyleChange?.call(chartStyle);
      },
      iconBuilder: (style) {
        return Row(mainAxisSize: MainAxisSize.min,
          children: [
            style.icon,
            const SizedBox(width: 8),
            Text(style.toString().split('.').last),
          ],
        );
      },
    );
  }

  Widget _buildIndicatorSelector() {
    if (widget.onIndicatorChange == null) return Container();

    final indicators = ref.watch(sortedIndicatorsProvider);
    if (!_showIndicatorSelector) {
      return IconButton(
        onPressed: () => setState(() => _showIndicatorSelector = true),
        icon: MathIntegralIcon(size: 20, color: Colors.white),
      );
    }

    return choiceChartParameter<Indicator>(
      Theme.of(context).textTheme.labelMedium,
      Colors.transparent,
      widget.selectedIndicator,
      indicators,
      (Indicator indicator) {
        setState(() => _showIndicatorSelector = false );
        widget.onIndicatorChange?.call(indicator);
      },
    );
  }

  Widget _buildPriceInfo() {
    if (widget.priceData == null) return Container();

    final currentPrice = widget.priceData?.getCurrent().toStringAsFixed(3);
    final priceChange = widget.priceData?.getChangeFor(widget.selectedPeriod.days);
    final priceChangeStr = priceChange?.toStringAsFixed(2);
    final color = priceChange != null && priceChange < 0 ? Colors.red : Colors.green;

    return Column( children: [
      if (widget.asset != null)
        Text("${widget.asset?.symbol} - ${widget.selectedPeriod} - ${widget.asset?.currency.code}",
          style: TextStyle(color: Colors.white.withAlpha(128))),
      Text("$currentPrice ($priceChangeStr%)", style: TextStyle(color: color)),
    ]);
  }
}
