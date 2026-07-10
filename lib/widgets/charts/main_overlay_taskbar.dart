import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:invest_agent/model/analysis_period.dart';
import 'package:invest_agent/model/asset_config.dart';
import 'package:invest_agent/model/results/price_result.dart';
import 'package:invest_agent/utils/choice_chart_parameter.dart';
import 'package:invest_agent/widgets/utils/math_icons.dart';

import '../../model/indicator_result.dart';
import '../../model/indicator_schema.dart';
import '../../providers/indicator_provider.dart';

class MainOverlayTaskbar extends ConsumerStatefulWidget {
  final AssetConfig asset;
  final IndexPrice priceData;
  final PeriodType selectedPeriod;
  final Indicator selectedIndicator;
  final ChartStyle selectedChartStyle;
  final Function(PeriodType) onPeriodChange;
  final Function(Indicator) onIndicatorChange;
  final Function(ChartStyle) onChartStyleChange;

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
    final currentPrice = widget.priceData.getCurrent().toStringAsFixed(3);
    final priceChange = widget.priceData.getChangeFor(widget.selectedPeriod.days);
    final priceChangeStr = priceChange.toStringAsFixed(2);
    final color = priceChange < 0 ? Colors.red : Colors.green;
    final indicators = ref.watch(sortedIndicatorsProvider);

    return Column(crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            if (!_showChartStyleSelector)
              IconButton(
                onPressed: () => setState(() => _showChartStyleSelector = true),
                icon: widget.selectedChartStyle.icon,
              )
            else
              choiceChartParameter<ChartStyle>(
                Theme.of(context).textTheme.labelMedium,
                Colors.transparent,
                widget.selectedChartStyle,
                ChartStyle.values,
                (ChartStyle chartStyle) {
                  setState(() {
                    _showChartStyleSelector = false;
                  });
                  widget.onChartStyleChange(chartStyle);
                },
                iconBuilder: (style) {
                  return Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      style.icon,
                      const SizedBox(width: 8),
                      Text(style.toString().split('.').last),
                    ],
                  );
                },
              ),
            const SizedBox(width: 8,),
            if (!_showPeriodSelector)
              TextButton(onPressed: () => setState(() => _showPeriodSelector = true),
              child: Text(widget.selectedPeriod.value))
            else
              choiceChartParameter<PeriodType>(
                Theme.of(context).textTheme.labelMedium,
                Colors.transparent,
                widget.selectedPeriod,
                PeriodType.values,
                (PeriodType period) {
                  setState(() {
                    _showPeriodSelector = false;
                  });
                  widget.onPeriodChange(period);
                },
              ),
            const SizedBox(width: 8,),
            if (!_showIndicatorSelector)
              IconButton(
                onPressed: () {
                  setState(() => _showIndicatorSelector = true);
                },
                icon: MathIntegralIcon(size: 20, color: Colors.white),
              )
            else
              choiceChartParameter<Indicator>(
                Theme.of(context).textTheme.labelMedium,
                Colors.transparent,
                widget.selectedIndicator,
                indicators,
                (Indicator indicator) {
                  setState(() {
                    _showIndicatorSelector = false;
                  });
                  widget.onIndicatorChange(indicator);
                },
              ),
          ],
        ),
        const SizedBox(height: 4),
        Text("${widget.asset.symbol} - ${widget.selectedPeriod} - ${widget.asset.currency.code}",
          style: TextStyle(color: Colors.white.withAlpha(128))),
        Text("$currentPrice ($priceChangeStr%)", style: TextStyle(color: color)),
      ],
    );
  }
}
