import 'package:flutter/material.dart';
import '../../model/indicator_schema.dart';

class IndicatorOverlayTaskbar extends StatefulWidget {
  final Indicator indicator;
  final Function() onChange;
  final Function() onDelete;

  const IndicatorOverlayTaskbar({
    super.key,
    required this.indicator,
    required this.onChange,
    required this.onDelete,
  });

  @override
  State<IndicatorOverlayTaskbar> createState() => _IndicatorOverlayTaskbarState();
}

class _IndicatorOverlayTaskbarState extends State<IndicatorOverlayTaskbar> {
  bool _showTaskBar = false;

  @override
  Widget build(BuildContext context) {
    final textStyle = TextStyle(color: Colors.white.withAlpha(128));

    // Early return for the collapsed state
    if (!_showTaskBar) {
      return TextButton(
        onPressed: () => setState(() => _showTaskBar = true),
        child: Text(
          widget.indicator.toInfoString(),
          style: textStyle,
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 0),
      decoration: BoxDecoration(
        color: Theme.of(context).focusColor,
        borderRadius: BorderRadius.circular(4),
      ),
      child:
        Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Text(widget.indicator.toInfoString(),
              style: TextStyle(color: Colors.white.withAlpha(128))),
            IconButton(
              onPressed: () {
                widget.onChange();
                setState(() => _showTaskBar = false);
              },
              icon: const Icon(Icons.settings_outlined, size: 20),
              tooltip: "Edit indicator",
            ),
            IconButton(
              visualDensity: VisualDensity.compact,
              onPressed: () => widget.onDelete(),
              icon: const Icon(Icons.delete_outline, size: 20),
              tooltip: 'Remove',
            ),
            IconButton(
              visualDensity: VisualDensity.compact,
              onPressed: () => setState(() => _showTaskBar = false),
              icon: const Icon(Icons.close, size: 20, color: Colors.white70),
              tooltip: 'Collapse',
            ),
          ]
        )
    );
  }
}
