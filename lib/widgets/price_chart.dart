import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:invest_agent/widgets/volume_chart.dart';

import '../model/analysis_respond.dart';

class PriceChart extends  StatefulWidget {
  final String eftIndexName;
  final List<PriceData> priceData;

  const PriceChart({super.key, required this.eftIndexName, required this.priceData});

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
    double verticalTitleSpace = 54;
    double padding = 12;
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
                          color: Colors.black26,
                          barWidth: 1.5,
                          isStrokeCapRound: true,
                          dotData: FlDotData(show: false),
                          spots: widget.priceData.map((data) {
                            return FlSpot(widget.priceData.indexOf(data).toDouble(), data.closePrice);
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
                            final date = widget.priceData[value.toInt()].dateTime;
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
                              final date = widget.priceData[barSpot.x.toInt()].dateTime;
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
                        )
                    )
                ),
                transformationConfig: transformationConfig,
              ),
            ),
            Positioned.fill(
              child: IgnorePointer(
                child: Padding(
                  // This padding have to is aligned the parent chart padding
                  padding: EdgeInsets.only(
                    top: padding,
                    left: verticalTitleSpace + padding,
                    right: verticalTitleSpace + padding,
                    bottom: verticalTitleSpace,
                  ),
                  child: VolumeChart(
                    priceData: widget.priceData,
                    transformationConfig: transformationConfig,
                  ),
                ),
              ),
            ),
            // VolumeChart(priceData: widget.priceData),
            Positioned(
              top: 8,
              left: 64,
              child: Text(widget.eftIndexName,
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