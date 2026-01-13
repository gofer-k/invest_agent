import 'dart:math';

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
    final maxVolume = widget.priceData .map((c) => c.volume) .reduce((a, b) => a > b ? a : b);
    final maxPrice = widget.priceData.map((c) => max(c.openPrice, c.closePrice)).reduce(max);
    double scaledVolume(double v) => (v / maxVolume) * 0.05 * maxPrice;

    return BarChart(
      transformationConfig: widget.transformationConfig,
      BarChartData(
        minY: 0,
        // maxY: widget.priceData.length.toDouble() - 1,
        barGroups: widget.priceData.map((entry) {
          final index = widget.priceData.indexOf(entry);
          // final normalized = entry.volume / maxVolume;
          final scaled = scaledVolume(entry.volume);
          // double logVolume(double v) => log(v + 1);
          final isBull = entry.closePrice >= entry.openPrice;

          return BarChartGroupData(
            x: index,
            barRods: [
              BarChartRodData(
                toY: scaled,
                width: 4,
                color: isBull ? Colors.green : Colors.red,
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