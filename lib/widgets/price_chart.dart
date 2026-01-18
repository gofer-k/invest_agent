import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../model/analysis_request.dart';
import '../model/analysis_respond.dart';
import '../themes/app_themes.dart';
import 'chart_controller.dart';

class PriceChart extends  StatefulWidget {
  final String eftIndexName;
  final AnalysisRespond results;
  final AnalysisRequest? analysisSettings;
  final ChartInteractionController? controller;
  final enableBottomLabels;

  const PriceChart({super.key,
    required this.eftIndexName,
    required this.analysisSettings,
    required this.results,
    required this.controller,
    this.enableBottomLabels = false});

  @override
  State<PriceChart> createState() => _PriceChartState();
}

class _PriceChartState extends State<PriceChart> {
  final usd = NumberFormat.simpleCurrency(locale: 'en_US', decimalDigits: 2);
  late TransformationController _transformationController;

  late Future<List<PriceData>> priceData;
  late BellingerBand _lowerBellingerBand;
  late BellingerBand _upperBellingerBand;
  late BellingerBand _middleBellingerBand;
  late List<SimpleMovingAverage> _sma;

  @override
  void initState() {
    _transformationController = TransformationController();
    if (widget.analysisSettings != null && widget.analysisSettings!.rollingWindows != null) {
      final rollingWindow = widget.analysisSettings!.rollingWindows!.first;
      priceData = widget.results.getRollingVolume(rollingWindow);
      _lowerBellingerBand = widget.results.getBollingerBand(BollingerBandType.lowerBB, rollingWindow);
      _upperBellingerBand = widget.results.getBollingerBand(BollingerBandType.upperBB, rollingWindow);
      _middleBellingerBand = widget.results.getBollingerBand(BollingerBandType.middleBB, rollingWindow);
      _sma = widget.results.getSMA(rollingWindow);
    }
    else {
      priceData = Future.value([]);
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
    FlTransformationConfig transformationConfig = FlTransformationConfig(
      scaleAxis: FlScaleAxis.horizontal,
      minScale: 1.0,
      // maxScale: 2.5,
      // panEnabled: _isPanEnabled,
      // scaleEnabled: _isScaleEnabled,
      transformationController: _transformationController,
    );

    final compact = NumberFormat.compact();
    final enableMovingAverage = widget.analysisSettings?.techIndicators?.contains("SMA") ?? false;
    final enableBollingerBands = widget.analysisSettings?.techIndicators?.contains("BB") ?? false;
    final currentRollingWindow = widget.analysisSettings?.rollingWindows?.first;

    return FutureBuilder<List<PriceData>>(
      future: priceData,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(child: Text('No volume data available.'));
        }
        final priceData = snapshot.data!;
        final prices = priceData.map((c) => c.closePrice).toList();
        final minPrice = prices.reduce((a, b) => a < b ? a : b);
        final maxPrice = prices.reduce((a, b) => a > b ? a : b);
        // Add headroom (10% above and below)
        final range = maxPrice - minPrice;
        final padding = range * 0.10;
        final minY = minPrice - padding;
        final maxY = maxPrice + padding;
        const double leftTitlesSize = 48;
        const double rightTitlesSize = 48;
        const double bottomTitlesSize = 58;

        /// TODO: Price data chart has to pan above
        return Stack(
              children: [
                Positioned.fill(
                  child:
                  LineChart(
                    LineChartData(
                        minX: widget.controller?.minX ?? 0,
                        maxX: widget.controller?.maxX ?? priceData.length.toDouble() - 1,
                        minY: minY,
                        maxY: maxY,
                        gridData: FlGridData(show: false),
                        lineBarsData: [
                          LineChartBarData(
                            color: AppTheme
                                .of(context)
                                .priceBarColor ?? Theme
                                .of(context)
                                .primaryColor,
                            barWidth: 1.5,
                            isStrokeCapRound: true,
                            dotData: FlDotData(show: false),
                            spots: widget.results.priceData.map((data) {
                              return FlSpot(
                                  widget.results.priceData
                                      .indexOf(data)
                                      .toDouble(), data.closePrice);
                            }).toList()
                          ),
                          if (enableBollingerBands && currentRollingWindow != null) ...[
                            LineChartBarData(
                                color: AppTheme.of(context).indicatorLowerBand ?? Theme
                                    .of(context)
                                    .canvasColor,
                                barWidth: 1.0,
                                isStrokeCapRound: true,
                                dotData: const FlDotData(show: false),
                                spots: _lowerBellingerBand.map((data) {
                                  return FlSpot(_lowerBellingerBand.indexOf(data).toDouble(),
                                      data.stdValue ?? 0.0);
                                }).toList()
                            ),
                            LineChartBarData(
                                color: AppTheme.of(context).indicatorUpperBand ?? Theme
                                    .of(context)
                                    .canvasColor,
                                barWidth: 1.0,
                                isStrokeCapRound: true,
                                dotData: const FlDotData(show: false),
                                spots: _upperBellingerBand.map((data) {
                                  return FlSpot(_upperBellingerBand.indexOf(data).toDouble(),
                                      data.stdValue ?? 0.0);
                                }).toList()
                            ),
                            LineChartBarData(
                                color: AppTheme.of(context).indicatorMiddleBand ?? Theme
                                    .of(context)
                                    .canvasColor,
                                barWidth: 1.0,
                                isStrokeCapRound: true,
                                dotData: const FlDotData(show: false),
                                spots: _middleBellingerBand.map((data) {
                                  return FlSpot(_middleBellingerBand.indexOf(data).toDouble(),
                                      data.stdValue ?? 0.0);
                                }).toList()
                            ),
                          ],
                          if (enableMovingAverage && currentRollingWindow != null)
                            LineChartBarData(
                                color: AppTheme
                                    .of(context)
                                    .indicatorRate ?? Theme
                                    .of(context)
                                    .canvasColor,
                                barWidth: 1.5,
                                isStrokeCapRound: true,
                                dotData: const FlDotData(show: false),
                                spots: _sma.map((data) {
                                  return FlSpot(_sma.indexOf(data).toDouble(),
                                      data.rollingMean ?? 0.0);
                                }).toList()
                            )
                        ],
                        titlesData: FlTitlesData(
                          show: true,
                          topTitles: const AxisTitles(
                            sideTitles: SideTitles(showTitles: false),
                          ),
                          leftTitles: AxisTitles(
                            // drawBelowEverything: true,
                            sideTitles: SideTitles(
                              showTitles: true,
                              reservedSize: leftTitlesSize,
                              maxIncluded: false,
                              minIncluded: false,
                              getTitlesWidget: (double value,
                                  TitleMeta meta) {
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
                                reservedSize: rightTitlesSize,
                                maxIncluded: false,
                                minIncluded: false,
                                getTitlesWidget: (double value,
                                    TitleMeta meta) {
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
                              showTitles: widget.enableBottomLabels,
                              reservedSize: bottomTitlesSize, // dates
                              maxIncluded: false,
                              getTitlesWidget: (double value, TitleMeta meta) {
                                final date = priceData[value.toInt()].dateTime;
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
                              getTooltipItems: (
                                  List<LineBarSpot> touchedBarSpots) {
                                return touchedBarSpots.map((barSpot) {
                                  final price = barSpot.y;
                                  final index = barSpot.x.toInt();
                                  final date = priceData[index].dateTime;
                                  final volume = priceData[index].volume;
                                  return LineTooltipItem('',
                                    const TextStyle(
                                      // color: AppColors.contentColorBlack,
                                      fontWeight: FontWeight.bold,
                                    ),
                                    children: [
                                      TextSpan(
                                        text: '${date.year}/${date.month}/${date
                                            .day}',
                                        style: TextStyle(
                                          color: AppTheme
                                              .of(context)
                                              .tooltipDateColor ?? Theme
                                              .of(context)
                                              .tooltipTheme
                                              .textStyle
                                              ?.color,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 12,
                                        ),
                                      ),
                                      TextSpan(text: '\n'),
                                      TextSpan(
                                        text: usd.format(price),
                                        style: TextStyle(
                                          color: AppTheme
                                              .of(context)
                                              .tooltipPriceColor ?? Theme
                                              .of(context)
                                              .tooltipTheme
                                              .textStyle
                                              ?.color,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16,
                                        ),
                                      ),
                                      TextSpan(text: '\n'),
                                      TextSpan(
                                        text: compact.format(volume),
                                        style: TextStyle(
                                          color: AppTheme
                                              .of(context)
                                              .tooltipVolumeColor ?? Theme
                                              .of(context)
                                              .tooltipTheme
                                              .textStyle
                                              ?.color,
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
                Positioned(
                  top: 8,
                  left: 64,
                  child: Text(widget.eftIndexName,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppTheme
                          .of(context)
                          .etfTitleColor ?? Theme
                          .of(context)
                          .textTheme
                          .titleLarge
                          ?.color ?? (Theme
                          .of(context)
                          .brightness == Brightness.dark ? Colors.white : Colors
                          .black),
                      shadows: [
                        Shadow(
                          color: AppTheme
                              .of(context)
                              .etfTitleShadowColor ?? Theme
                              .of(context)
                              .shadowColor,
                          blurRadius: 4,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
        );
      }
    );
   }
}