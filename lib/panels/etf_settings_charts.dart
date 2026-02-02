

import 'package:flutter/material.dart';
import 'package:invest_agent/model/analysis_configuration.dart';
import 'package:invest_agent/widgets/utils/shrinkable_list_Item.dart';

import '../model/analysis_period.dart';
import '../themes/app_themes.dart';
import '../widgets/chart_config_dialog.dart';
import '../widgets/utils/rolling_list.dart';
import '../widgets/utils/shrinkable.dart';

class EtfSettingsCharts extends StatefulWidget {
  const EtfSettingsCharts({super.key});

  @override
  State<StatefulWidget> createState() => _EtfSettingsChartsState();
}

class _EtfSettingsChartsState extends State<EtfSettingsCharts> {
  List<PeriodType> periods = PeriodType.values.toList();
  PeriodType selectedPeriod = PeriodType.year;
  List<MultiChart> multiChart = [];
  AnalysisConfiguration configuration = AnalysisConfiguration();

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Shrinkable(title: "Period: ($selectedPeriod)",
            body: RollingList<PeriodType>(values: periods, initialValue: PeriodType.year,
                onChanged: (PeriodType v) => setState(() => selectedPeriod = v))
        ),
        const SizedBox(height: 8),
        Row(children: [
            const Text("Main chart type"),
            IconButton(icon: Icon(Icons.add), onPressed: (){
              showConfigurationChart(context, (MultiChart newMultiChart) {
                setState(() {
                  multiChart.add(newMultiChart);
                });
              });
            }),
          ]
        ),
        for (var multiChart in multiChart)
          Shrinkable(title: multiChart.title, expanded: true,
            body: Column(
              children: [
               Text("Main chart type: ${multiChart.mainChart.name}"),
                Wrap(spacing: 8,
                  children: multiChart.overlayCharts.map((w) =>
                    Chip(label: Text("$w"),
                      onDeleted: () {
                        setState(() => multiChart.removeOverlayChart(w));
                      },
                    )
                  ).toList(),
                ),
              ],
            ),
          ),
        const SizedBox(height: 30),
        Center(
          widthFactor: 4.0,
          heightFactor: 2.0,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
                side: BorderSide(width: 1.0, color: AppTheme.of(context).buttonOutlineColor?? Colors.deepPurpleAccent)),
            onPressed: _updateAnalysis,
            child: const Text("Update Analysis", style: TextStyle(fontSize: 20)),
          ),
        ),
      ],
    );
  }

  void _updateAnalysis() {
  }
}