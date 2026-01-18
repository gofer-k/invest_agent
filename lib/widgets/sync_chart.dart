import 'package:flutter/cupertino.dart';
import 'chart_controller.dart';

class SyncChart extends StatefulWidget {
  final ChartInteractionController controller;
  final Widget body;
  final double topPadding;
  final double leftTitles;
  final double rightTitles ;
  final double bottomTitles;

  const SyncChart({super.key, required this.controller,
    required this.body, this.topPadding = 12, this.bottomTitles = 58,
    this.leftTitles = 48, this.rightTitles = 48});

  @override
  State<StatefulWidget> createState() => _SyncChartState();
}

class _SyncChartState extends State<SyncChart> {
  // Store the initial focal point when a scale gesture begins.
  Offset _initialFocalPoint = Offset.zero;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      final width = constraints.maxWidth;
      return GestureDetector(behavior: HitTestBehavior.translucent,
        // onPanUpdate: (details) {
        //   // convert pixel delta to domain delta
        //   final dxDomain = -details.delta.dx * widget.controller.windowWidth / width;
        //   widget.controller.panDomain(dxDomain);
        // },
        onScaleStart: (details) {
          _initialFocalPoint = details.focalPoint;
        },
        onScaleUpdate: (details) {
          if (details.scale != 1.0) {
            final focalPixel = details.focalPoint.dx - (context.findRenderObject() as RenderBox).localToGlobal(Offset.zero).dx;
            final focalDomain = widget.controller.pixelToDomain(focalPixel, width);
            widget.controller.zoom(details.scale, focalDomain);
          }
          else {
            // --- Panning Logic ---
            // Calculate the change in position from the initial focal point.
            final dx = details.focalPoint.dx - _initialFocalPoint.dx;
            // Convert pixel delta to domain delta.
            final dxDomain = -dx * widget.controller.windowWidth / width;
            widget.controller.panDomain(dxDomain);
            // Update the initial focal point for the next update.
            _initialFocalPoint = details.focalPoint;
          }
        },
        onTapDown: (details) {
          final local = (context.findRenderObject() as RenderBox).globalToLocal(details.globalPosition);
          final xDomain = widget.controller.pixelToDomain(local.dx, width);
          widget.controller.setCrosshair(xDomain);
        },
        onTapUp: (_) => widget.controller.setCrosshair(null),
        child: AnimatedBuilder(
          animation: widget.controller,
          builder: (_, _) {
            return AspectRatio(aspectRatio: 16 / 9,
              child: Padding(
                padding: EdgeInsets.only(left: widget.leftTitles, right: widget.rightTitles, top: widget.topPadding),
                child: Stack(
                   children: [
                      Positioned.fill(child: widget.body),
                      if (widget.controller.crosshairX != null)
                        CustomPaint(size: Size.infinite,
                          painter: _CrosshairPainter(
                            xPixel: widget.controller.domainToPixel(widget.controller.crosshairX!, width),
                          ),
                        ),
                   ],
                ),
              ),
            );
          },
        ),
      );
    });
  }
}

class _CrosshairPainter extends CustomPainter {
  final double xPixel;

  _CrosshairPainter({required this.xPixel});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0x88FFFFFF)
      ..strokeWidth = 1;

    canvas.drawLine(
      Offset(xPixel, 0),
      Offset(xPixel, size.height),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant _CrosshairPainter oldDelegate) =>
      oldDelegate.xPixel != xPixel;
}
