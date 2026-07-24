import 'package:flutter/material.dart';
import '../model/multi_chart_schema.dart';

void showConfigurationChart(
    BuildContext context, MultiChartConfig? chart,
    Function(MultiChartConfig newMultiChart) onSave) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return ChartConfigDialog(chart: chart, onSave: onSave);
    },
  );
}

class ChartConfigDialog extends StatefulWidget {
  final Function(MultiChartConfig newMultiChart) onSave;
  final MultiChartConfig? chart;

  const ChartConfigDialog({super.key, required this.onSave, required this.chart});

  @override
  State<ChartConfigDialog> createState() => _ChartConfigDialogState();
}

class _ChartConfigDialogState extends State<ChartConfigDialog> {
  late String multiTitle;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Text("ChartConfigDialog");
  }
}
