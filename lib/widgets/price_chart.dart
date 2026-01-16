import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:invest_agent/widgets/moving_average.dart';
import 'package:invest_agent/widgets/volume_chart.dart';

import '../model/analysis_request.dart';
import '../model/analysis_respond.dart';
import '../themes/app_themes.dart';

class PriceChart extends  StatefulWidget {
  final String eftIndexName;
  final AnalysisRespond results;
  final AnalysisRequest? analysisSettings;

  const PriceChart({super.key, required this.eftIndexName, required this.analysisSettings, required this.results});

  @override
  State<PriceChart> createState() => _PriceChartState();
}

class _PriceChartState extends State<PriceChart> {
  final usd = NumberFormat.simpleCurrency(locale: 'en_US', decimalDigits: 2);
  late TransformationController _transformationController;
  final bool _isPanEnabled = true;
  final bool _isScaleEnabled = true;
  final chartPricesKey = GlobalKey();

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
    FlTransformationConfig transformationConfig = FlTransformationConfig(
      scaleAxis: FlScaleAxis.horizontal,
      minScale: 1.0,
      maxScale: 25.0,
      panEnabled: _isPanEnabled,
      scaleEnabled: _isScaleEnabled,
      transformationController: _transformationController,
    );

    double horizontalTitleSpace = 48;
    double verticalTitleSpace = 58;
    double padding = 12;
    final compact = NumberFormat.compact();
    final enableVolume = widget.analysisSettings?.techIndicators?.contains("Volume") ?? false;
    final enableMovingAverage = widget.analysisSettings?.techIndicators?.contains("SMA") ?? false;
    final enableBollingBands = widget.analysisSettings?.techIndicators?.contains("BB") ?? false;
    final currentRollingWindow = widget.analysisSettings?.rollingWindows?.first;
    return AspectRatio(aspectRatio: 16 / 9,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: padding, vertical: padding),
        child: Stack(
          children: [
            Positioned.fill(
              child: LineChart(
                LineChartData(
                    lineBarsData: [
                      LineChartBarData(
                          color: AppTheme.of(context).priceBarColor?? Theme.of(context).primaryColor,
                          barWidth: 1.5,
                          isStrokeCapRound: true,
                          dotData: FlDotData(show: false),
                          spots: widget.results.priceData.map((data) {
                            return FlSpot(widget.results.priceData.indexOf(data).toDouble(), data.closePrice);
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
                            reservedSize: horizontalTitleSpace,
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
                            reservedSize: horizontalTitleSpace,
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
                          reservedSize: verticalTitleSpace, // dates
                          maxIncluded: false,
                          getTitlesWidget: (double value, TitleMeta meta) {
                            final date = widget.results.priceData[value.toInt()].dateTime;
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
                        touchCallback: (event, respond) {},
                        touchTooltipData: LineTouchTooltipData(
                          getTooltipItems: (List<LineBarSpot> touchedBarSpots) {
                            return touchedBarSpots.map((barSpot) {
                              final price = barSpot.y;
                              final index = barSpot.x.toInt();
                              final date = widget.results.priceData[index].dateTime;
                              final volume = widget.results.priceData[index].volume;
                              return LineTooltipItem('',
                                const TextStyle(
                                  // color: AppColors.contentColorBlack,
                                  fontWeight: FontWeight.bold,
                                ),
                                children: [
                                  TextSpan(
                                    text: '${date.year}/${date.month}/${date.day}',
                                    style: TextStyle(
                                      color: AppTheme.of(context).tooltipDateColor?? Theme.of(context).tooltipTheme.textStyle?.color,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12,
                                    ),
                                  ),
                                  TextSpan(text: '\n'),
                                  TextSpan(
                                    text: usd.format(price),
                                    style: TextStyle(
                                      color: AppTheme.of(context).tooltipPriceColor?? Theme.of(context).tooltipTheme.textStyle?.color,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),
                                  TextSpan(text: '\n'),
                                  TextSpan(
                                    text: compact.format(volume),
                                    style: TextStyle(
                                      color: AppTheme.of(context).tooltipVolumeColor?? Theme.of(context).tooltipTheme.textStyle?.color,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),
                                ],
                              );
                            }).toList();
                          },
                        )
                    )
                ),
                transformationConfig: transformationConfig,
              ),
            ),
            if (enableVolume)
              Positioned.fill(
                child: IgnorePointer(
                  child: Padding(
                    // This padding have to is aligned the parent chart padding
                    padding: AppTheme.of(context).paddingOverlayChart?? EdgeInsets.only(
                      top: padding,
                      left: verticalTitleSpace + padding,
                      right: verticalTitleSpace + padding,
                      bottom: verticalTitleSpace,
                    ),
                    child: VolumeChart(
                      priceData: widget.results.priceData,
                      transformationConfig: transformationConfig,
                    ),
                  ),
                ),
              ),
            if (enableMovingAverage && currentRollingWindow != null)
              Positioned.fill(
                child: IgnorePointer(
                  child: Padding(
                    padding: AppTheme.of(context).paddingOverlayChart?? EdgeInsets.only(
                      top: padding,
                      left: verticalTitleSpace + padding,
                      right: verticalTitleSpace + padding,
                      bottom: verticalTitleSpace,
                    ),
                    child: MovingAverage(result: widget.results,
                      enableBollingerBands: enableBollingBands,
                      rolling_window:[currentRollingWindow],
                      transformationConfig: transformationConfig)
                  ),
                ),
              ),
            Positioned(
              top: 8,
              left: 64,
              child: Text(widget.eftIndexName,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.of(context).etfTitleColor?? Theme.of(context).textTheme.titleLarge?.color ?? (Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.black),
                  shadows: [
                    Shadow(
                      color: AppTheme.of(context).etfTitleShadowColor?? Theme.of(context).shadowColor,
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