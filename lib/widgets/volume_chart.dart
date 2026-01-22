import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:invest_agent/model/analysis_request.dart';
import 'package:invest_agent/model/analysis_respond.dart';
import 'package:invest_agent/themes/app_themes.dart';

import 'chart_controller.dart';
import 'datetime_label.dart';

class VolumeChart extends StatefulWidget {
  final AnalysisRequest? analysisSettings;
  final AnalysisRespond results;
  final ChartInteractionController? controller;
  final bool leftSideTitle;
  final bool rightSideTile;
  final bool bottomTitle;
  final bool enableTitle;

  const VolumeChart({super.key,
    required this.results,
    required this.analysisSettings,
    required this.controller,
    this.leftSideTitle = true,
    this.rightSideTile = false,
    this.bottomTitle = false,
    this.enableTitle = false});

  @override
  State<StatefulWidget> createState() => _VolumeChartState();
}

class _VolumeChartState extends State<VolumeChart>{
  late TransformationController _transformationController;
  late Future<List<PriceData>> priceData;
  @override
  void initState() {
    _transformationController = TransformationController();
    if (widget.analysisSettings != null && widget.analysisSettings!.rollingWindows != null) {
      priceData = widget.results.getRollingVolume(widget.analysisSettings!.rollingWindows!.first);
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
      maxScale: 25.0,
      // panEnabled: true,
      // scaleEnabled: true,
      transformationController: _transformationController,
    );

    // double horizontalTitleSpace = 48;
    // double verticalTitleSpace = 58;
    final compact = NumberFormat.compact();

    // TODO: decrease the chart vertical size
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
         final maxVolumeZscore = priceData.map((c) => c.volumeZscore) .reduce((a, b) => a > b ? a : b);
         final miVolumeZscore = priceData.map((c) => c.volumeZscore) .reduce((a, b) => a < b ? a : b);
         final maxVolume = priceData.map((c) => c.volume) .reduce((a, b) => a > b ? a : b);
         double scaledVolume(double v) => 10.0 * v / maxVolumeZscore;
         const double leftTitlesSize = 48;
         const double rightTitlesSize = 48;
         const double bottomTitlesSize = 58;
         final datetimeData = priceData.map((e) => e.dateTime).toList();

         return AspectRatio(aspectRatio: 16 / 9,
           child: Stack(
             children: [
               BarChart(
                 transformationConfig: transformationConfig,
                 BarChartData(
                   minY: miVolumeZscore * 10.0,
                   maxY: maxVolumeZscore * 10.0,
                   barGroups: priceData.map((entry) {
                     final index = priceData.indexOf(entry);
                     final scaled = scaledVolume(entry.volumeZscore);
                     final bullishColor = AppTheme
                         .of(context)
                         .bullishBarColor ?? Colors.green;
                     final bearishColor = AppTheme
                         .of(context)
                         .bearishBarColor ?? Colors.red;
                     return BarChartGroupData(
                       x: index,
                       barRods: [
                         BarChartRodData(
                           toY: scaled,
                           width: 4,
                           // color: isBull ? bullishColor : bearishColor,
                           color: entry.volumeZscore >= 0
                               ? bullishColor
                               : bearishColor,
                           borderRadius: BorderRadius.zero,
                         ),
                       ],
                     );
                   }).toList(),
                   extraLinesData: ExtraLinesData(
                     verticalLines: widget.controller?.verticalLines ?? [],
                   ),
                   gridData: FlGridData(show: false),
                   borderData: FlBorderData(show: false),
                   titlesData: FlTitlesData(
                     show: (widget.leftSideTitle || widget.rightSideTile ||
                         widget.bottomTitle),
                     topTitles: const AxisTitles(
                         sideTitles: SideTitles(showTitles: false)),
                     leftTitles: AxisTitles(
                       // drawBelowEverything: true,
                       sideTitles: SideTitles(
                           showTitles: widget.leftSideTitle,
                           reservedSize: leftTitlesSize,
                           maxIncluded: false,
                           minIncluded: false,
                           getTitlesWidget: (double value, TitleMeta meta) {
                             return SideTitleWidget(
                               meta: meta,
                               child: Text(widget.leftSideTitle
                                   ? value.toStringAsFixed(2)
                                   : "",
                                 style: const TextStyle(fontSize: 12),
                               ),
                             );
                           }
                       ),
                     ),
                     rightTitles: AxisTitles(
                       drawBelowEverything: true,
                       sideTitles: SideTitles(
                           showTitles: widget.rightSideTile,
                           reservedSize: rightTitlesSize,
                           maxIncluded: false,
                           minIncluded: false,
                           getTitlesWidget: (double value, TitleMeta meta) {
                             return SideTitleWidget(
                                 meta: meta,
                                 child: LayoutBuilder(
                                   builder: (BuildContext context,
                                       BoxConstraints constraints) {
                                     if ((value - maxVolumeZscore).abs() >
                                         0.01) {
                                       return Text(value.toStringAsFixed(2),
                                           style: const TextStyle(
                                               fontSize: 12));
                                     }
                                     return Container(
                                       padding: const EdgeInsets.symmetric(
                                           horizontal: 8, vertical: 4),
                                       decoration: BoxDecoration(
                                         color: Colors.green,
                                         borderRadius: BorderRadius.circular(6),
                                         border: Border.all(
                                             color: Colors.green,
                                             // outline color
                                             width: 1.2),
                                       ),
                                       child: Text(compact.format(maxVolume),
                                           style: TextStyle(
                                               color: Colors.white70,
                                               fontSize: 12,
                                               fontWeight: FontWeight.bold)
                                       ),
                                     );
                                   },
                                 )
                             );
                           }
                       ),
                     ),
                     bottomTitles: AxisTitles(
                       sideTitles: SideTitles(
                         showTitles: widget.bottomTitle,
                         reservedSize: bottomTitlesSize, // dates
                         maxIncluded: false,
                         getTitlesWidget: (double value, TitleMeta meta) {
                           final date = buildDateLabel(value, meta, widget.controller!.windowWidth, datetimeData);
                           return SideTitleWidget(
                             meta: meta,
                             child: Transform.rotate(
                               angle: -3.14 / 4.0, // -45 degrees
                               child: date
                             ),
                           );
                         },
                       ),
                     ),
                   ),
                 ),
               ),
               if (widget.enableTitle)
                 Positioned(
                   top: 8,
                   left: 64,
                   child: Text("Volume rolling(20)",
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
                           .brightness == Brightness.dark
                           ? Colors.white
                           : Colors.black),
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
           ),
         );
       }
    );
  }
}