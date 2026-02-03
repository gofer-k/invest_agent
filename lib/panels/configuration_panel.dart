import 'package:flutter/material.dart';

import '../model/charts_configuration.dart';
import '../model/analysis_request.dart';
import 'etf_settings_charts.dart';
import 'etf_settings_panel.dart';

class ConfigurationPanel extends StatelessWidget {
  final Future<void> Function(AnalysisRequest) onRequest;
  final Future<void> Function(ChartsConfiguration) onConfigAnalysis;
  const ConfigurationPanel({super.key, required this.onRequest, required this.onConfigAnalysis});

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
          EtfSettingsCharts(onConfigAnalysis: (ChartsConfiguration config){
            onConfigAnalysis(config);
          })
        ]),
      )
    );
  }
}