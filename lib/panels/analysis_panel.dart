import 'package:flutter/material.dart';
import '../model/analysis_request.dart';
import '../model/etf_analytics_client.dart';
import 'etf_settings_panel.dart';

class AnalyticsScreen extends StatefulWidget {
  const AnalyticsScreen({super.key});

  @override
  State<AnalyticsScreen> createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends State<AnalyticsScreen> {
  final client = ETFAnalyticsClient();

  Map<String, dynamic>? analysisResult;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("ETF Analytics")),
      body: Column(
        children: [
          Expanded(
            flex: 2,
            child: EtfSettingsPanel(
              onRunAnalysis: _handleRunAnalysis,
            ),
          ),
          Expanded(
            flex: 3,
            child: analysisResult == null
                ? const Center(child: Text("No results yet"))
                : _buildResultsView(),
          ),
        ],
      ),
    );
  }

  Future<void> _handleRunAnalysis(Map<String, dynamic> payload) async {
    final request = AnalysisRequest(
      symbolTicker: payload["symbol"],
      datasetSource: payload["dataset_source"],
      rollingWindows: List<int>.from(payload["rolling_windows"]),
      strategy: StrategyParams(
        type: payload["strategy"]["type"],
        fast: payload["strategy"]["fast"],
        slow: payload["strategy"]["slow"],
      ),
      factors: List<String>.from(payload["factors"]),
      features: List<String>.from(payload["features"]),
    );

    final result = await client.runAnalysis(request);

    setState(() {
      analysisResult = result;
    });
  }

  Widget _buildResultsView() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text("Rolling windows: ${analysisResult!["rolling"]}"),
        const SizedBox(height: 12),
        Text("Strategy: ${analysisResult!["strategy"]}"),
        const SizedBox(height: 12),
        Text("Factors: ${analysisResult!["factors"]}"),
        const SizedBox(height: 12),
        Text("Features: ${analysisResult!["features"]}"),
      ],
    );
  }
}
