import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:invest_agent/utils/load_json_data.dart';
import 'package:invest_agent/widgets/charts/multi_chart.dart';
import '../model/charts_configuration.dart';
import '../model/analysis_request.dart';
import '../model/analysis_respond.dart';
import '../model/etf_analytics_client.dart';
import 'package:path/path.dart' as p;

import 'configuration_panel.dart';
class InvestDashboard extends StatefulWidget {
  const InvestDashboard({super.key});

  @override
  State<InvestDashboard> createState() => _InvestDashboardState();
}

class _InvestDashboardState extends State<InvestDashboard> {
  final ETFAnalyticsClient client = ETFAnalyticsClient();
  ChartsConfiguration? configurationCharts;
  AnalysisRequest? analysisRequest;
  AnalysisRespond? analysisResult;
  
  bool isLoading = false;
  String? errorMessage;

  double visibleMinY = 0.0;
  double visibleMaxY = 0.0;
  String chartTitle = "";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Investment Dashboard')),
      body: Row(
        mainAxisSize: MainAxisSize.max,
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          // SETTINGS PANEL
          Expanded(
            flex: 1,
            child: ConfigurationPanel(onRequest: _handleRunAnalysis, onConfigAnalysis: _handleConfigAnalysis),
          ),
          const SizedBox(width: 10),
          // ANALYSIS PANEL
          Expanded(
            flex: 4,
            child: _buildAnalysisPanel(),
          ),
        ],
      ),
    );
  }

  // Handle the callback from the settings panel
  Future<void> _handleRunAnalysis(AnalysisRequest request) async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    if (analysisRequest != null && analysisRequest!.symbolTicker == request.symbolTicker) {
      analysisResult?.changePeriod(request.period);
      analysisRequest = request;
      setState(() {
        isLoading = false;
      });
      return;
    }

    try {
      final result = await client.runAnalysis(request);
      AnalysisRespond? receivedData;

      if (result["format"] == "gz") {
        receivedData = await receiveCompressedAnalysisResult(result);
      }
      chartTitle = p.basenameWithoutExtension(request.symbolTicker);

      setState(() {
        analysisRequest = request;
        // Only assign if we successfully got data
        if (receivedData != null) {
          analysisResult = receivedData;
        }
      });
    } catch (e) {
      setState(() {
        errorMessage = e.toString();
        log("ETF agent analysis: Error: $errorMessage");
        isLoading = false;
      });
    } finally {
      if (mounted) { // Best practice check before calling setState in async gaps
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  Future<void> _handleConfigAnalysis(ChartsConfiguration config) async {
    configurationCharts = config;
  }
  
  Future<AnalysisRespond?> receiveCompressedAnalysisResult(Map<String, dynamic> result) {
    final filePath = result["response_file"];
    final data = loadFinancialDataFromGzip(filePath);

    return data;
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
          style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
        ),
      );
    }

    final AnalysisRespond? currentResult = analysisResult;
    if (currentResult == null) {
      return const Center(
        child: Text("Run analysis to see results"),
      );
    }
    final currentRequest = analysisRequest;
    if (analysisRequest == null) {
      return const Center(
        child: Text("Run analysis to see settings"),
      );
    }

    return LayoutBuilder(builder: (context, constraints) {
      if (currentRequest != null && configurationCharts != null) {
        return MultiChartView(
            chartTitle: [currentRequest.symbolTicker],
            analysisRequest: currentRequest,
            results: currentResult,
            chartConfig: configurationCharts!,
            chartHeight: constraints.maxHeight);
        }
        return const Center(child: Text("No analysis to see results"));
      }
    );
  }
}

