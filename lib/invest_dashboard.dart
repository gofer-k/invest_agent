import 'package:flutter/material.dart';
import 'package:invest_agent/panels/etf_settings_panel.dart';
import 'model/analysis_request.dart';
import 'model/etf_analytics_client.dart';

class InvestDashboard extends StatefulWidget {
  const InvestDashboard({super.key});

  @override
  State<InvestDashboard> createState() => _InvestDashboardState();
}

class _InvestDashboardState extends State<InvestDashboard> {
  final ETFAnalyticsClient client = ETFAnalyticsClient();
  Map<String, dynamic>? analysisResult;
  bool isLoading = false;
  String? errorMessage;


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Investment Dashboard')),
      body: Column(
        children: [
          // SETTINGS PANEL
          Expanded(
            flex: 2,
            child: EtfSettingsPanel(
              onRunAnalysis: _handleRunAnalysis,
            ),
          ),
          const Divider(height: 1),
          // ANALYSIS PANEL
          Expanded(
            flex: 3,
            child: _buildAnalysisPanel(),
          ),
          // TODO: integrate input file data
          // ElevatedButton(
          //   onPressed: _pickAndLoadFile,
          //   child: const Text('Select GZIP File'),
          // ),
          // Expanded(
          //   child: _financialDataFuture == null
          //       ? const Center(child: Text('Please select a .gz file to load data.'))
          //       : FutureBuilder<List<FinancialEntry>>(
          //     future: _financialDataFuture,
          //     builder: (context, snapshot) {
          //       if (snapshot.connectionState == ConnectionState.waiting) {
          //         return const Center(child: CircularProgressIndicator());
          //       } else if (snapshot.hasError) {
          //         return Center(child: Text('Error: ${snapshot.error}'));
          //       } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          //         return const Center(child: Text('No data available.'));
          //       }
          //
          //     },
          //   ),
          // ),
        ],
      ),
    );
  }

  // Handle the callback from the settings panel
  Future<void> _handleRunAnalysis(Map<String, dynamic> payload) async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      final request = AnalysisRequest(
        symbolTicker: payload["symbol_ticker"],
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
    } catch (e) {
      setState(() {
        errorMessage = e.toString();
      });
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  // Build the analysis panel UI
  Widget _buildAnalysisPanel() {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (errorMessage != null) {
      return Center(
        child: Text(
          "Error: $errorMessage",
          style: const TextStyle(color: Colors.red),
        ),
      );
    }

    if (analysisResult == null) {
      return const Center(
        child: Text("Run analysis to see results"),
      );
    }

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const Text(
          "Analysis Results",
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),

        // Rolling windows
        if (analysisResult!["rolling"] != null) ...[
          const Text("Rolling Windows:", style: TextStyle(fontSize: 16)),
          Text(analysisResult!["rolling"].toString()),
          const SizedBox(height: 16),
        ],

        // Strategy
        if (analysisResult!["strategy"] != null) ...[
          const Text("Strategy Output:", style: TextStyle(fontSize: 16)),
          Text(analysisResult!["strategy"].toString()),
          const SizedBox(height: 16),
        ],

        // Factors
        if (analysisResult!["factors"] != null) ...[
          const Text("Factor Models:", style: TextStyle(fontSize: 16)),
          Text(analysisResult!["factors"].toString()),
        ],

        // Features
        if (analysisResult!["features"] != null) ...[
          const Text("Features Models:", style: TextStyle(fontSize: 16)),
          Text(analysisResult!["features"].toString()),
        ],
      ],
    );
  }
}

