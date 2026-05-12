import 'package:flutter/material.dart';
import 'package:invest_agent/model/charts_configuration.dart';
import '../model/multi_chart_schema.dart';
import '../widgets/chart_config_dialog.dart';
import '../widgets/utils/shrinkable.dart';

class EtfSettingsCharts extends StatefulWidget {
  final void Function(ChartsConfiguration) onConfigAnalysis;
  final ChartsConfiguration configurationCharts;
  const EtfSettingsCharts({super.key, required this.onConfigAnalysis, required this.configurationCharts});

  @override
  State<StatefulWidget> createState() => _EtfSettingsChartsState();
}

class _EtfSettingsChartsState extends State<EtfSettingsCharts> {
  late List<MultiChartConfig> multiChart;

  @override
  void initState() {
    super.initState();
    multiChart = List.from(widget.configurationCharts.multiCharts);
  }
  
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.max,
            children: [
            const Text("Main chart type"),

            IconButton(icon: Icon(Icons.add), onPressed: (){
              showConfigurationChart(context, null, (newMultiChart) {
                setState(() {
                  multiChart.add(newMultiChart);
                });
              });
            }),
          ]
        ),
        for (var chart in multiChart)
          Shrinkable(title: chart.title,
            actions: [
              IconButton(icon: Icon(Icons.update_outlined),
                onPressed: (){
                  showConfigurationChart(context, chart, (newMultiChart) {
                    setState(() {
                      final index = multiChart.indexOf(chart);
                      if (index != -1) {
                        multiChart[index] = newMultiChart;
                      }
                    });
                  });
                }),
              IconButton(icon: Icon(Icons.remove_outlined),
                onPressed: (){
                  setState(() {
                    multiChart.remove(chart);
                  });
                }),
            ],
            expanded: true,
            body: Column(
              children: [
               // Text(chart.mainChart.toString().split('.').last, style: Theme.of(context).textTheme.titleLarge),
               //  if (chart.overlayCharts.isNotEmpty)
               //    Wrap(spacing: 8,
               //      children: chart.overlayCharts.map((w) =>
               //        Chip(label: Text(w.toString().split('.').last),
               //          onDeleted: () {
               //            setState(() {
               //              chart.removeOverlayChart(w);
               //            });
               //          },
               //        )
               //      ).toList(),
               //    ),
              ],
            ),
          ),
      ],
    );
  }
}