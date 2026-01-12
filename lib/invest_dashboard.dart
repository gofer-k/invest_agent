import 'dart:developer';

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:invest_agent/panels/etf_settings_panel.dart';
import 'package:invest_agent/utils/load_json_data.dart';
import 'model/analysis_request.dart';
import 'model/analysis_respond.dart';
import 'model/etf_analytics_client.dart';
import 'package:path/path.dart' as p;
import 'package:intl/intl.dart';

class InvestDashboard extends StatefulWidget {
  const InvestDashboard({super.key});

  @override
  State<InvestDashboard> createState() => _InvestDashboardState();
}

class _InvestDashboardState extends State<InvestDashboard> {
  final ETFAnalyticsClient client = ETFAnalyticsClient();
  AnalysisRespond? analysisResult;
  bool isLoading = false;
  String? errorMessage;
  double priceRange = 0.0;
  double? maxPrice;
  double? minPrice;

  late TransformationController _transformationController;
  final bool _isPanEnabled = true;
  final bool _isScaleEnabled = true;
  final chartPricesKey = GlobalKey();
  double visibleMinY = 0.0;
  double visibleMaxY = 0.0;
  String chartTitle = "";

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

    final usd = NumberFormat.simpleCurrency(locale: 'en_US', decimalDigits: 2);
    return AspectRatio(aspectRatio: 16 / 9,
      child: Padding(
        padding: const EdgeInsets.only(top: 12.0, right: 12.0, left: 12.0),
        child: Stack(
          children: [
            LineChart(
              LineChartData(
                lineBarsData: [
                  LineChartBarData(
                    color: Colors.black26,
                    barWidth: 1.5,
                    isStrokeCapRound: true,
                    dotData: FlDotData(show: false),
                    spots: currentResult.priceData.map((data) {
                      return FlSpot(currentResult.priceData.indexOf(data).toDouble(), data.closePrice);
                    }).toList()
                  )
                ],
                titlesData: FlTitlesData(
                  show: true,
                  topTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  leftTitles: AxisTitles(
                    drawBelowEverything: true,
                    sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 48,
                        maxIncluded: false,
                        minIncluded: false,
                        getTitlesWidget: (double value, TitleMeta meta) {
                          return SideTitleWidget(
                            meta: meta,
                            child: Text(value.toStringAsFixed(2),
                              style: const TextStyle(fontSize: 12),
                            ),
                          );
                        }
                    ),
                  ),
                  rightTitles: AxisTitles(
                    drawBelowEverything: true,
                    sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 48,
                        maxIncluded: false,
                        minIncluded: false,
                        getTitlesWidget: (double value, TitleMeta meta) {
                          return SideTitleWidget(
                            meta: meta,
                            child: Text(value.toStringAsFixed(2),
                              style: const TextStyle(fontSize: 12),
                            ),
                          );
                        }
                    ),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 50, // dates
                      maxIncluded: false,
                      getTitlesWidget: (double value, TitleMeta meta) {
                        final date = currentResult.priceData[value.toInt()].dateTime;
                        return SideTitleWidget(
                          meta: meta,
                          child: Transform.rotate(
                            angle: -3.14 / 4.0, // -45 degrees
                            child: Text(
                              '${date.month}/${date.day}/${date.year}',
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
                lineTouchData: LineTouchData(
                    enabled: true,
                    touchCallback: (event, respond) {
                      // TODO: implement touch event
                    },
                    touchTooltipData: LineTouchTooltipData(
                      getTooltipItems: (List<LineBarSpot> touchedBarSpots) {
                        return touchedBarSpots.map((barSpot) {
                          final price = barSpot.y;
                          final date = currentResult.priceData[barSpot.x.toInt()].dateTime;
                          return LineTooltipItem('',
                            const TextStyle(
                              // color: AppColors.contentColorBlack,
                              fontWeight: FontWeight.bold,
                            ),
                            children: [
                              TextSpan(
                                text: '${date.year}/${date.month}/${date.day}',
                                style: TextStyle(
                                  color: Colors.lightGreen,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                ),
                              ),
                              TextSpan(text: '\n'),
                              TextSpan(
                                text: usd.format(price),
                                style: const TextStyle(
                                  color: Colors.orange,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                            ],
                          );
                        }).toList();
                      },
                    )  // TODO: display touched the current price
                )
              ),
              transformationConfig: FlTransformationConfig(
                scaleAxis: FlScaleAxis.horizontal,
                minScale: 1.0,
                maxScale: 25.0,
                panEnabled: _isPanEnabled,
                scaleEnabled: _isScaleEnabled,
                transformationController: _transformationController,
              ),
            ),
            Positioned(
              top: 8,
              left: 64,
              child: Text(chartTitle,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  shadows: [
                    Shadow(
                      color: Colors.black54,
                      blurRadius: 4,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

