import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:invest_agent/utils/load_json_data.dart';
import 'package:invest_agent/widgets/charts/multi_chart.dart';
import '../model/charts_configuration.dart';
import '../model/analysis_request.dart';
import '../model/analysis_respond.dart';
import '../model/etf_analytics_client.dart';
import 'package:path/path.dart' as p;

import 'etf_settings_charts.dart';
import 'request_settings_panel.dart';
import 'main_settings_panel.dart';
import '../widgets/app_task_bar.dart';

class InvestDashboard extends StatefulWidget {
  const InvestDashboard({super.key});

  @override
  State<InvestDashboard> createState() => _InvestDashboardState();
}

class _InvestDashboardState extends State<InvestDashboard> {
  final ETFAnalyticsClient client = ETFAnalyticsClient();
  ChartsConfiguration configurationCharts = ChartsConfiguration();
  AnalysisRequest? analysisRequest;
  AnalysisRespond? analysisResult;
  
  bool isLoading = false;
  String? errorMessage;

  double visibleMinY = 0.0;
  double visibleMaxY = 0.0;
  String chartTitle = "";

  // Panel Management: null means hidden, 0: Request, 1: Results, 2: Main Settings
  int? activePanelIndex;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        mainAxisSize: MainAxisSize.max,
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          // VERTICAL TASK BAR ON THE LEFT
          AppVerticalTaskBar(
            mainActions: [
              TaskBarIcon(
                icon: Icons.play_arrow,
                color: Colors.green,
                tooltip: 'Run Analysis',
                onPressed: () {
                  // Trigger analysis logic if request is available
                },
              ),
              const Divider(height: 20, indent: 8, endIndent: 8),
              // TAB ACTIONS MOVED TO VERTICAL BAR
              TaskBarIcon(
                icon: Icons.settings,
                tooltip: 'Request Settings',
                color: activePanelIndex == 0 ? Theme.of(context).primaryColor : null,
                onPressed: () => _togglePanel(0),
              ),
              TaskBarIcon(
                icon: Icons.update,
                tooltip: 'Results Settings',
                color: activePanelIndex == 1 ? Theme.of(context).primaryColor : null,
                onPressed: () => _togglePanel(1),
              ),
              const Divider(height: 20, indent: 8, endIndent: 8),
              TaskBarIcon(
                icon: Icons.settings_applications,
                tooltip: 'Main Settings',
                color: activePanelIndex == 2 ? Theme.of(context).primaryColor : null,
                onPressed: () => _togglePanel(2),
              ),
            ],
            overflowActions: [
              ListTile(
                leading: const Icon(Icons.help_outline, size: 20),
                title: const Text('Help'),
                onTap: () => Navigator.pop(context),
              ),
            ],
          ),
          
          // COLLAPSIBLE SIDE PANEL
          if (activePanelIndex != null)
            SizedBox(
              width: 350,
              child: Container(
                decoration: BoxDecoration(
                  border: Border(right: BorderSide(color: Theme.of(context).dividerColor)),
                ),
                child: Column(
                  children: [
                    // Panel Header with Hide Icon
                    Container(
                      height: 40,
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      color: Theme.of(context).brightness == Brightness.dark 
                          ? const Color(0xFF3C3F41) 
                          : const Color(0xFFF2F2F2),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            _getPanelTitle(),
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                          ),
                          IconButton(
                            icon: const Icon(Icons.remove, size: 18),
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                            tooltip: 'Hide Panel',
                            onPressed: () => setState(() => activePanelIndex = null),
                          ),
                        ],
                      ),
                    ),
                    Expanded(child: _buildActivePanel()),
                  ],
                ),
              ),
            ),

          // MAIN ANALYSIS PANEL
          Expanded(
            flex: 4,
            child: _buildAnalysisPanel(),
          ),
        ],
      ),
    );
  }

  String _getPanelTitle() {
    switch (activePanelIndex) {
      case 0: return 'REQUEST';
      case 1: return 'RESULTS';
      case 2: return 'MAIN SETTINGS';
      default: return '';
    }
  }

  void _togglePanel(int index) {
    setState(() {
      if (activePanelIndex == index) {
        activePanelIndex = null; // Hide if same icon clicked
      } else {
        activePanelIndex = index; // Switch to new panel
      }
    });
  }

  Widget _buildActivePanel() {
    switch (activePanelIndex) {
      case 0:
        return RequestSettingsPanel(onRunAnalysis: _handleRunAnalysis);
      case 1:
        return EtfSettingsCharts(
          configurationCharts: configurationCharts,
          onConfigAnalysis: _handleConfigAnalysis,
        );
      case 2:
        return const MainSettingsPanel();
      default:
        return const SizedBox.shrink();
    }
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
    setState(() {
      configurationCharts = config;
    });
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
      if (currentRequest != null) {
        return MultiChartView(
            chartTitle: [currentRequest.symbolTicker],
            analysisRequest: currentRequest,
            results: currentResult,
            chartConfig: configurationCharts,
            chartHeight: constraints.maxHeight);
        }
        return const Center(child: Text("No analysis to see results"));
      }
    );
  }
}
