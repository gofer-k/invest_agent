import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:invest_agent/model/analysis_respond.dart';

class VolumeChart extends StatefulWidget {
  final List<PriceData> priceData;
  final bool leftSideTitle;
  final bool rightSideTile;
  final bool bottomTitle;
  final dynamic transformationConfig;

  const VolumeChart({super.key, required this.priceData, this.leftSideTitle = false, this.rightSideTile = false, this.bottomTitle = false, required this.transformationConfig});

  @override
  State<StatefulWidget> createState() => _VolumeChartState();
}

class _VolumeChartState extends State<VolumeChart>{
  @override
  Widget build(BuildContext context) {
    return BarChart(
      transformationConfig: widget.transformationConfig,
      BarChartData(
        barGroups: widget.priceData.map((entry) {
          final index = widget.priceData.indexOf(entry);
          return BarChartGroupData(
            x: index,
            barRods: [
              BarChartRodData(
                toY: entry.volume,
                width: 4,
                color: entry.closePrice >= entry.openPrice ? Colors.green : Colors.red,
                borderRadius: BorderRadius.zero,
              ),
            ],
          );
        }).toList(),
        gridData: FlGridData(show: false),
        borderData: FlBorderData(show: false),
        titlesData: FlTitlesData(show: false),
      ),
    );
  }
}