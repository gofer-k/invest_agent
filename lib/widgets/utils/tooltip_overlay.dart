import 'package:flutter/material.dart';
import 'package:intl/intl.dart' as intl;
import 'package:invest_agent/widgets/charts/controllers/crosshair_controller.dart';

import '../charts/overlay_chart.dart';

class TooltipOverlay extends StatelessWidget {
  final CrosshairController tooltipController;

  const TooltipOverlay({super.key, required this.tooltipController});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
        animation: tooltipController,
        builder: (context, _) {
          final data = tooltipController.data;
          if (data == null) return const SizedBox.shrink();
          return Positioned(
            left: data.position.dx + 8, top: data.position.dy - 40,
            child: Container(margin: const EdgeInsets.all(8),
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.black87,
                borderRadius: BorderRadius.circular(6),
              ),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(intl.DateFormat.yMd().format(data.time),
                      style: const TextStyle(color: Colors.white)),
                  for (final entry in data.data) ...[
                    Text(formatValue(entry), style: const TextStyle(color: Colors.white)),
                    if (data.data.isNotEmpty)
                      ...entry.extras.entries.map((e) => Text("${e.key}: ${e.value}", style: const TextStyle(color: Colors.white))),
                  ],
                ]
              ),
            ),
          );
        }
    );
  }

  String formatValue(TooltipItem item) {
    final String? text = switch (item.overlayType) {
      OverlayType.bellingerBands => "BB price:",
      OverlayType.macd => "MACD:",
      OverlayType.movingAverage => "SMA:",
      OverlayType.obv => null,
      OverlayType.pattern => null,
      OverlayType.priceCandles => "Price: ",
      OverlayType.priceLine => "Price: ",
      OverlayType.rsi => "RSI: ",
      OverlayType.signal => null,
      OverlayType.volume => "Volume: ",
      OverlayType.tooltipMarker => null,
    };
    return text != null ? intl.NumberFormat.compact().format(item.value) : "";
  }
}