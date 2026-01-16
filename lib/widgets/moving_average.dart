import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../model/analysis_respond.dart';
import '../themes/app_themes.dart';

class MovingAverage extends StatefulWidget {
  final AnalysisRespond? result;
  final List<int> rollingWindow;
  final FlTransformationConfig? transformationConfig;

  const MovingAverage({super.key, required this.result, required this.rollingWindow, this.transformationConfig});

  @override
  State<StatefulWidget> createState() => MovingAverageState();
}

class MovingAverageState extends State<MovingAverage> {
  late TransformationController _transformationController;
  final bool _isPanEnabled = false;
  final bool _isScaleEnabled = false;
  final chartPricesKey = GlobalKey();
  late Future<List<SimpleMovingAverage>> _smaFuture;

  @override
  void initState() {
    _transformationController = TransformationController();
    if (widget.result != null && widget.rollingWindow.isNotEmpty) {
      _smaFuture = widget.result!.getSMA(widget.rollingWindow.first);
    }
    else {
      _smaFuture = Future.value([]);
    }
    super.initState();
  }

  @override
  void dispose() {
    _transformationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    FlTransformationConfig transformationConfig = widget.transformationConfig ?? FlTransformationConfig(
      scaleAxis: FlScaleAxis.horizontal,
      minScale: 1.0,
      maxScale: 25.0,
      panEnabled: _isPanEnabled,
      scaleEnabled: _isScaleEnabled,
      transformationController: _transformationController,
    );
    return FutureBuilder<List<SimpleMovingAverage>>(
        future: _smaFuture,
        builder: (context, snapshot) {
          // While waiting for data, you can show a loader or an empty container
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          // If there's an error
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          // If data is available and not null
          final sma = snapshot.data ?? [];
          return LineChart(
            LineChartData(
                lineBarsData: [
                  LineChartBarData(
                      color: AppTheme
                          .of(context)
                          .indicatorRate ?? Theme
                          .of(context)
                          .canvasColor,
                      barWidth: 1.5,
                      isStrokeCapRound: true,
                      dotData: const FlDotData(show: false),
                      spots: sma.map((data) {
                        return FlSpot(sma.indexOf(data).toDouble(),
                            data.rollingMean ?? 0.0);
                      }).toList()
                  )
                ],
                titlesData: FlTitlesData(show: false),
                lineTouchData: LineTouchData(
                    enabled: false,
                    touchCallback: (event, respond) {},
                    touchTooltipData: LineTouchTooltipData()
                )
            ),
            transformationConfig: transformationConfig,
          );
       },
    );
  }
}