import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:invest_agent/model/analysis_request.dart';
import 'package:invest_agent/widgets/chart_overlay_ma.dart';
import 'package:invest_agent/widgets/chart_painter.dart';
import 'package:invest_agent/widgets/time_controller.dart';
import '../model/analysis_respond.dart';
import 'crosshair_controller.dart';

class SyncChart extends StatefulWidget {
  final TimeController controller;
  final CrosshairController? crosshairController;
  final AnalysisRequest analysisRequest;
  final AnalysisRespond results;

  const SyncChart({super.key, required this.controller,
    this.crosshairController, required this.analysisRequest, required this.results});

  @override
  State<StatefulWidget> createState() => _SyncChartState();
}

class _SyncChartState extends State<SyncChart> {
  @override

  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([widget.controller, widget.crosshairController]),
      builder: (context, _) {
        return LayoutBuilder(builder: (context, constraints){
          final daysPerPixel = widget.controller.visibleSpan.inDays / constraints.maxWidth;
          final width = constraints.maxWidth;
          final box = context.findRenderObject() as RenderBox;
          return Listener( // Wrap with a Listener
            onPointerSignal: (pointerSignal) {
              if (pointerSignal is PointerScrollEvent) {
                final scrollDelta = pointerSignal.scrollDelta.dy;
                if (scrollDelta == 0.0) return;

                // Determine zoom factor (tweak the 0.1 value for sensitivity)
                final scaleFactor = 1 - scrollDelta * 0.001;

                // Get the cursor position to zoom towards it
                final localPos = box.globalToLocal(pointerSignal.position);
                final anchorTime = _posToDate(localPos.dx, width, widget.controller.visibleStart, widget.controller.visibleEnd);
                widget.controller.zoom(scaleFactor, anchorTime);
              }
            },
            child: GestureDetector(
              onScaleStart: (_) {},
              onScaleUpdate: (details) {
                if ((details.scale - 1.0).abs() > 0.02) {
                  final localPos = details.focalPoint;
                  final local = box.globalToLocal(localPos);
                  final anchorTime = _posToDate(local.dx, width, widget.controller.visibleStart, widget.controller.visibleEnd);
                  widget.controller.zoom(details.scale, anchorTime);
                }
                else {
                  if (width <= 0) return;
                  final local = details.focalPointDelta;
                  widget.controller.pan(Duration(days: (-local.dx * daysPerPixel).round()));
                }
              },
              onTapDown: widget.crosshairController == null ? null : (details) {
                final local = box.globalToLocal(details.globalPosition);
                final currData = _posToDate(local.dx, width, widget.controller.visibleStart, widget.controller.visibleEnd);
                widget.crosshairController?.update(currData, null);
              },
              onTapUp: (_) => widget.crosshairController?.clear(),
              child: CustomPaint(
                size: Size(width, constraints.maxHeight),
                painter: CHartPainter(
                  controller: widget.controller,
                  crosshairController: widget.crosshairController,
                  analysisRequest: widget.analysisRequest,
                  results: widget.results,
                  overlays: [
                    ChartOverlayMA(data: widget.results.getSMA(20)),
                  ]
                ),
              )
            )
          );
        });
      },
    );
  }

  DateTime? _posToDate(double pos, double width, DateTime startDate, DateTime endDate) {
    final ratio = (pos / width).clamp(0.0, 1.0);
    final spanDays = endDate.difference(startDate).inDays;
    return startDate.add(Duration(days: (spanDays * ratio).round()));
  }
}
