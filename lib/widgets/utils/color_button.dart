import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';

class ColorButton extends StatelessWidget {
  final String label;
  final String hexValue;
  final ValueChanged<String> onColorChanged;
  final bool showLabel;

  const ColorButton({
    super.key,
    required this.label,
    required this.hexValue,
    required this.onColorChanged,
    this.showLabel = true,
  });

  // Converts String (#FF0000) to Flutter Color
  Color _parseColor(String hex) {
    try {
      String cleanHex = hex.replaceAll('#', '').replaceAll('0x', '');
      if (cleanHex.length == 6) cleanHex = 'FF$cleanHex';
      return Color(int.parse(cleanHex, radix: 16));
    } catch (e) {
      return Colors.blue;
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentColor = _parseColor(hexValue);

    final Widget button = GestureDetector(
      onTap: () => _showPicker(context, currentColor),
      child: Container(
        width: 100,
        height: 40,
        decoration: BoxDecoration(
          color: currentColor,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.grey.shade400),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(25), // 0.1 of 255
              blurRadius: 4,
              offset: const Offset(0, 2),
            )
          ],
        ),
        child: Center(
          child: Text(
            hexValue.toUpperCase(),
            style: TextStyle(
              color: useWhiteForeground(currentColor)
                  ? Colors.white
                  : Colors.black,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );

    if (!showLabel) return button;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Expanded(child: Text(label)),
          // The Clickable Color Box
          button,
        ],
      ),
    );
  }

  void _showPicker(BuildContext context, Color color) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Select $label'),
        content: SingleChildScrollView(
          child: ColorPicker(
            pickerColor: color,
            onColorChanged: (newColor) {
              // Convert Color back to Hex String
              String hexString = newColor.toHexString(includeHashSign: true);
              onColorChanged(hexString);
            },
            paletteType: PaletteType.hsvWithHue, // Grading Palette
            enableAlpha: true,                  // Opacity
            labelTypes: [                 // RGBA Panel
              ColorLabelType.rgb,
              ColorLabelType.hex,
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
}
