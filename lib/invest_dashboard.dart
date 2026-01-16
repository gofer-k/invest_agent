import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:invest_agent/panels/etf_settings_panel.dart';
import 'package:invest_agent/utils/load_json_data.dart';
import 'package:invest_agent/widgets/price_chart.dart';
import 'model/analysis_request.dart';
import 'model/analysis_respond.dart';
import 'model/etf_analytics_client.dart';
import 'package:path/path.dart' as p;
class InvestDashboard extends StatefulWidget {
  const InvestDashboard({super.key});

  @override
  State<InvestDashboard> createState() => _InvestDashboardState();
}

class _InvestDashboardState extends State<InvestDashboard> {
  final ETFAnalyticsClient client = ETFAnalyticsClient();
  AnalysisRequest? analysisRequest;
  AnalysisRespond? analysisResult;
  bool isLoading = false;
  String? errorMessage;
  double priceRange = 0.0;
  double? maxPrice;
  double? minPrice;
  
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
            child: EtfSettingsPanel(
              onRunAnalysis: _handleRunAnalysis,
            ),
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

    try {
      final result = await client.runAnalysis(request);
      AnalysisRespond? receivedData;
      if (result["format"] == "gz") {
        receivedData = await receiveCompressedAnalysisResult(result);
      }
      final calculatedPriceRange = await receivedData?.getPriceRange();
      final calculatedMaxPrice = await receivedData?.getMaxPrice();
      final calculatedMinPrice = await receivedData?.getMinPrice();
      chartTitle = p.basenameWithoutExtension(request.symbolTicker);
      setState(() {
        if (result["format"] == "gz") {
          analysisRequest = request;
          analysisResult = receivedData;
          priceRange = (calculatedPriceRange != null) ? (calculatedPriceRange * 0.1) : 0.0;
          maxPrice = calculatedMaxPrice;
          minPrice = calculatedMinPrice;
          isLoading = false;
        }
      });
    } catch (e) {
      setState(() {
        errorMessage = e.toString();
        log("ETF agent analysis: Error: $errorMessage");
        isLoading = false;
      });
    }
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

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        // TODO: Price candlestick chart instead of price lina chart
        Expanded(flex: 3,
          child: PriceChart(eftIndexName: chartTitle, analysisSettings: currentRequest, results: currentResult)
        ),
        //TODO: add moving average with MACD
        // TODO: add RSI indicator
        // Expanded(flex: 1,
        //   child: MovingAverage(result: currentResult, rolling_window: [50],),
        // )
      ]
    );
  }
}

