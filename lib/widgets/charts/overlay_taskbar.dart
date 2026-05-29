import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:invest_agent/model/analysis_period.dart';
import 'package:invest_agent/model/asset_config.dart';
import 'package:invest_agent/model/price_result.dart';

import '../../model/multi_chart_schema.dart';

class OverlayTaskbar extends ConsumerStatefulWidget {
  final AssetConfig asset;
  final PeriodType period;
  final MultiChartConfig chartConfig;
  final IndexPrice priceData;

  const OverlayTaskbar({
    super.key,
    required this.asset,
    required this.period,
    required this.chartConfig,
    required this.priceData});

  @override
  ConsumerState<OverlayTaskbar> createState() => _OverlayTaskbarState();
}

class _OverlayTaskbarState extends ConsumerState<OverlayTaskbar>{
  @override
  Widget build(BuildContext context) {
    final currentPrice = widget.priceData.getCurrent().toStringAsFixed(3);
    final princeChange = widget.priceData.getChangeFor(widget.period.days);
    final princeChangeStr = princeChange.toStringAsFixed(2);
    final color = princeChange < 0 ? Colors.red : Colors.green;

    return Column(
      children: [
        Text("${widget.asset.symbol} - ${widget.period} - ${widget.asset.currency.code}",
          style: TextStyle(color: Colors.white.withAlpha(128))),
        // TODO: Current price (+/- value % by period
        Text("$currentPrice ($princeChangeStr%)", style: TextStyle(color: color)),
      ],
    );
  }
}