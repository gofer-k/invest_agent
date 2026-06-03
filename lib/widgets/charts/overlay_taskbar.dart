import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:invest_agent/model/analysis_period.dart';
import 'package:invest_agent/model/asset_config.dart';
import 'package:invest_agent/model/price_result.dart';
import 'package:invest_agent/utils/choice_chart_parameter.dart';
import 'package:invest_agent/widgets/utils/math_icons.dart';

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
  bool _showIndicatorSelector = false;
  bool _showPeriodSelector = false;
  bool _showChartStyleSelector = false;

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
            if (!_showChartStyleSelector)
              IconButton(
                onPressed: () => setState(() => _showChartStyleSelector = true),
                icon: _selectedChartStyle.icon,
              )
            else
              choiceChartParameter<ChartStyle>(
                Theme.of(context).textTheme.labelMedium,
                Colors.transparent,
                _selectedChartStyle,
                ChartStyle.values,
                (ChartStyle chartStyle) {
                  setState(() {
                    if (_selectedChartStyle != chartStyle) {
                      _selectedChartStyle = chartStyle;
                      _showChartStyleSelector = false;
                    }
                  });
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
              child: Text(_selectedPeriod.value))
            else
              choiceChartParameter<PeriodType>(
                Theme.of(context).textTheme.labelMedium,
                Colors.transparent,
                _selectedPeriod,
                PeriodType.values,
                (PeriodType period) {
                  setState(() {
                    _selectedPeriod = period;
                    _showPeriodSelector = false;
                  });
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
                _selectedIndicator,
                indicators,
                (Indicator indicator) {
                  setState(() {
                    _selectedIndicator = indicator;
                    _showIndicatorSelector = false;
                  });
                },
              ),
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