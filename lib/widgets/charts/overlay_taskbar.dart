import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:invest_agent/model/analysis_period.dart';
import 'package:invest_agent/model/asset_config.dart';
import 'package:invest_agent/model/price_result.dart';
import 'package:invest_agent/utils/dropdown_periods.dart';

import '../../model/indicator_result.dart';
import '../../model/indicator_schema.dart';
import '../../model/multi_chart_schema.dart';
import '../../providers/indicator_provider.dart';

class OverlayTaskbar extends ConsumerStatefulWidget {
  final AssetConfig asset;
  final MultiChartConfig chartConfig;
  final IndexPrice priceData;

  const OverlayTaskbar({
    super.key,
    required this.asset,
    required this.chartConfig,
    required this.priceData});

  @override
  ConsumerState<OverlayTaskbar> createState() => _OverlayTaskbarState();
}

class _OverlayTaskbarState extends ConsumerState<OverlayTaskbar>{
  late PeriodType _selectedPeriod = PeriodType.year;
  late Indicator _selectedIndicator = Indicator.defaultIndicator();
  late ChartStyle _selectedChartStyle = ChartStyle.line;

  @override
  Widget build(BuildContext context) {
    final currentPrice = widget.priceData.getCurrent().toStringAsFixed(3);
    final princeChange = widget.priceData.getChangeFor(_selectedPeriod.days);
    final princeChangeStr = princeChange.toStringAsFixed(2);
    final color = princeChange < 0 ? Colors.red : Colors.green;
    final indicators = ref.watch(sortedIndicatorsProvider);

    return Column(crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            choiceChartParameter<ChartStyle>(
              Theme.of(context).textTheme.labelMedium,
              Colors.transparent,
              _selectedChartStyle,
              ChartStyle.values,
              (ChartStyle chartStyle) {
                setState(() {
                  _selectedChartStyle = chartStyle;
                });
            }),
            choiceChartParameter<PeriodType>(
              Theme.of(context).textTheme.labelMedium,
              Colors.transparent,
              _selectedPeriod,
              PeriodType.values,
              (PeriodType period) {
                setState(() {
                  _selectedPeriod = period;
                });
            }),
            const SizedBox(width: 4),
            choiceChartParameter<Indicator>(
              Theme.of(context).textTheme.labelMedium,
              Colors.transparent,
              _selectedIndicator,
              indicators,
              (Indicator indicator) {
                setState(() {
                  _selectedIndicator = indicator;
                });
            }),
          ],
        ),
        const SizedBox(height: 4),
        Text("${widget.asset.symbol} - $_selectedPeriod - ${widget.asset.currency.code}",
          style: TextStyle(color: Colors.white.withAlpha(128))),
        // TODO: Current price (+/- value % by period
        Text("$currentPrice ($princeChangeStr%)", style: TextStyle(color: color)),
      ],
    );
  }
}