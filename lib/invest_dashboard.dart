import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:invest_agent/panels/etf_settings_panel.dart';
import 'package:invest_agent/utils/load_json_data.dart';
import 'model/analysis_request.dart';
import 'model/analysis_respond.dart';
import 'model/etf_analytics_client.dart';

class InvestDashboard extends StatefulWidget {
  const InvestDashboard({super.key});

  @override
  State<InvestDashboard> createState() => _InvestDashboardState();
}

class _InvestDashboardState extends State<InvestDashboard> {
  final ETFAnalyticsClient client = ETFAnalyticsClient();
  AnalysisRequest? analysisResult;
  bool isLoading = false;
  String? errorMessage;
  late TransformationController _transformationController;
  bool _isPanEnabled = true;
  bool _isScaleEnabled = true;

  @override
  void initState() {
    _transformationController = TransformationController();
    super.initState();
  }

  @override
  void dispose() {
    _transformationController.dispose();
    super.dispose();
  }

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
  Future<void> _handleRunAnalysis(AnalysisRequest request) async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      final result = await client.runAnalysis(request);

      setState(() {
        if (result["format"] == "gz") {
          analysisResult = receiveCompressedAnalysisResult(result) as AnalysisRequest?;
        }
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

 AnalysisRespond? receiveCompressedAnalysisResult(Map<String, dynamic> result) {
    final filePath = result["response_file"];
    final data = loadFinancialDataFromGzip(filePath);
    // return data.then((value) => value);
   return null;
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

    return AspectRatio(aspectRatio: 16 / 9,
      child: Padding(
        padding: const EdgeInsets.only(top: 0.0, right: 8.0),
        child: LineChart(
          LineChartData(),
          transformationConfig: FlTransformationConfig(
            scaleAxis: FlScaleAxis.horizontal,
            minScale: 1.0,
            maxScale: 25.0,
            panEnabled: _isPanEnabled,
            scaleEnabled: _isScaleEnabled,
            transformationController: _transformationController,
          ),
        ),
      ),
    );
  }
}

