import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../model/analysis_respond.dart';
import '../themes/app_themes.dart';

class BollingerBandsChart extends StatefulWidget {
  final AnalysisRespond? result;
  final List<int> rollingWindow;
  final FlTransformationConfig? transformationConfig;
  final bool enableGridData;
  const BollingerBandsChart({super.key, required this.result, required this.rollingWindow, this.transformationConfig, this.enableGridData = false});

  @override
  State<StatefulWidget> createState() => BollingerBandsChartState();
}

class BollingerBandsChartState extends State<BollingerBandsChart> {
  late TransformationController _transformationController;
  final chartKey = GlobalKey();
  late Future<BellingerBand> _lowerBellingerBandFuture;
  late Future<BellingerBand> _upperBellingerBandFuture;
  late Future<BellingerBand> _middleBellingerBandFuture;

  @override
  void initState() {
    _transformationController = TransformationController();
    if (widget.result != null && widget.rollingWindow.isNotEmpty) {
      _lowerBellingerBandFuture = widget.result!.getBollingerBand(BollingerBandType.lowerBB, widget.rollingWindow.first);
      _upperBellingerBandFuture = widget.result!.getBollingerBand(BollingerBandType.upperBB, widget.rollingWindow.first);
      _middleBellingerBandFuture = widget.result!.getBollingerBand(BollingerBandType.middleBB, widget.rollingWindow.first);
    }
    else {
      _lowerBellingerBandFuture = Future.value([]);
      _upperBellingerBandFuture = Future.value([]);
      _middleBellingerBandFuture = Future.value([]);
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
      panEnabled: true,
      scaleEnabled: true,
      transformationController: _transformationController,
    );
    return Stack(alignment: Alignment.center,
      children: [
        Positioned.fill(
          child: bollingerBand(_lowerBellingerBandFuture, AppTheme.of(context).indicatorLowerBand, transformationConfig)),
        Positioned.fill(
          child: bollingerBand(_upperBellingerBandFuture, AppTheme.of(context).indicatorUpperBand, transformationConfig)),
        Positioned.fill(
          child: bollingerBand(_middleBellingerBandFuture, AppTheme.of(context).indicatorMiddleBand, transformationConfig)),
      ]
    );
  }

  Widget bollingerBand(Future<BellingerBand> band, Color? colorBand, FlTransformationConfig transformationConfig) {
    return FutureBuilder<BellingerBand>(
      future: band,
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
        final bb = snapshot.data ?? [];
        return LineChart(
          LineChartData(
            minX: 0,
            maxX: bb.length.toDouble() - 1,
            gridData: FlGridData(show: widget.enableGridData),
            lineBarsData: [
              LineChartBarData(
                  color: colorBand ?? Theme
                      .of(context)
                      .canvasColor,
                  barWidth: 1.0,
                  isStrokeCapRound: true,
                  dotData: const FlDotData(show: false),
                  spots: bb.map((data) {
                    return FlSpot(bb.indexOf(data).toDouble(),
                        data.stdValue ?? 0.0);
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