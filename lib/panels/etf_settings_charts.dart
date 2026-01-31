

import 'package:flutter/material.dart';
import 'package:invest_agent/model/analysis_configuration.dart';

import '../model/analysis_period.dart';
import '../themes/app_themes.dart';
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
  late AnalysisConfiguration configuration;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Shrinkable(title: "Period: ($selectedPeriod)",
            body: RollingList<PeriodType>(values: periods, initialValue: PeriodType.year,
                onChanged: (PeriodType v) => setState(() => selectedPeriod = v))
        ),

        // Shrinkable(title: "Rolling Windows",
        //     body: Column(
        //         children: [
        //           Wrap(
        //             spacing: 8,
        //             children: rollingWindows
        //                 .map((w) =>
        //                 Chip(
        //                   label: Text("$w"),
        //                   onDeleted: () {
        //                     setState(() => rollingWindows.remove(w));
        //                   },
        //                 ))
        //                 .toList(),
        //           ),
        //           Row(
        //             children: [
        //               Expanded(
        //                 child: TextField(
        //                   decoration: const InputDecoration(
        //                     labelText: "Add rolling window",
        //                   ),
        //                   keyboardType: TextInputType.number,
        //                   onSubmitted: (v) {
        //                     final parsed = int.tryParse(v);
        //                     if (parsed != null) {
        //                       setState(() => rollingWindows.add(parsed));
        //                     }
        //                   },
        //                 ),
        //               ),
        //             ],
        //           ),
        //         ]
        //     )),
        // Shrinkable(title: "Technical Indicators",
        //     body: Column(
        //       children: [
        //         Wrap(spacing: 8,
        //           children: analysisIndicators.map((w) =>
        //               Chip(
        //                 label: Text(w),
        //                 onDeleted: () {
        //                   setState(() => analysisIndicators.remove(w));
        //                 },
        //               )).toList(),
        //         ),
        //         Row(
        //           children: [
        //             Expanded(
        //               child: TextField(
        //                   controller: _indicatorController,
        //                   decoration: const InputDecoration(labelText: "Add indicator"),
        //                   keyboardType: TextInputType.name,
        //                   onSubmitted: (indicator) {
        //                     if (indicator.isNotEmpty) {
        //                       setState(() => analysisIndicators.add(indicator));
        //                       _indicatorController.clear();
        //                     }
        //
        //                   }),
        //             ),
        //           ],
        //         ),
        //       ],
        //     )
        // ),
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