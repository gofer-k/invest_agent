import 'package:flutter/material.dart';

import '../model/charts_configuration.dart';
import '../model/analysis_request.dart';
import 'etf_settings_charts.dart';
import 'etf_settings_panel.dart';

class ConfigurationPanel extends StatelessWidget {
  final Future<void> Function(AnalysisRequest) onRequest;
  final Future<void> Function(ChartsConfiguration) onConfigAnalysis;
  final ChartsConfiguration configurationCharts;
  const ConfigurationPanel({super.key, required this.onRequest, required this.onConfigAnalysis, required this.configurationCharts});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(length: 2,
      child: Scaffold(
        appBar: AppBar(
          bottom: const TabBar(
            tabs: [
              Tab(icon: Icon(Icons.settings), text: 'Request'),
              Tab(icon: Icon(Icons.update), text: 'Results'),
            ]
          ),
        ),
        body: TabBarView(children: [
          EtfSettingsPanel(onRunAnalysis: (AnalysisRequest request) {
            onRequest(request);
          }),
          EtfSettingsCharts(configurationCharts: configurationCharts,
            onConfigAnalysis: (ChartsConfiguration config){
              onConfigAnalysis(config);
          })
        ]),
      )
    );
  }
}