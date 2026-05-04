
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../model/indicator_schema.dart';

void showIndicator(BuildContext context,
    Indicator? indicator,
    Function(Indicator? indicator) onSave) {
  showDialog(context: context,
    builder: (BuildContext context) {
      return IndicatorDialog(indicator: indicator, onSave: onSave);
    }
  );
}

class IndicatorDialog extends ConsumerStatefulWidget {
  final Function(Indicator? indicator) onSave;
  final Indicator? indicator;
  const IndicatorDialog({super.key, required this.onSave, required this.indicator});

  @override
  ConsumerState<IndicatorDialog> createState() => _IndicatorDialogState();
}

class _IndicatorDialogState extends ConsumerState<IndicatorDialog> {
  late final TextEditingController controllerName;
  late final TextEditingController controllerType;
  final Map<String, dynamic> parameters = {};

  @override
  void initState() {
    super.initState();
    controllerName = TextEditingController(text: widget.indicator?.toString() ?? '');
    controllerType = TextEditingController(text: widget.indicator?.type ?? '');
  }

  @override
  void dispose() {
    controllerName.dispose();
    controllerType.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text("Indicator ${widget.indicator.toString()}"),
      content: Column(mainAxisSize: MainAxisSize.min,
        children: [
          _editIndicatorName(controllerName, "Input indicator name", "Indicator name"),
          _editIndicatorName(controllerType, "Input type: e.g. Moving Average", "Indicator type"),
          const SizedBox(height: 16),
          const Text("Parameters"),
          ElevatedButton.icon(
            icon: const Icon(Icons.add),
            label: const Text('Add parameter'),
            onPressed: () => _handleIndicatorParameters(context, ref),
          ),
        ],
      ),
      actions: [
        BackButton(onPressed: () => Navigator.of(context).pop()),
        ElevatedButton(onPressed: () {
          final name = controllerName.text.trim();
          if (name.isEmpty) return;
          final newIndicator = Indicator(id: widget.indicator?.id ?? -1,
            name: name,
            type: "",
            parameters: {
            // TODO: pass parameters
            }
          );
          widget.onSave(newIndicator);
          Navigator.of(context).pop();
          },
        child: const Text("Save"))
      ],
    );
  }

  Widget _editIndicatorName(TextEditingController controller, String hint, String label) {
    return TextField(
      controller: controllerName,
      decoration: InputDecoration(labelText: label, hintText: hint,
        border: const OutlineInputBorder(),
      ),
      keyboardType: TextInputType.text,
      textAlign: TextAlign.end,
    );
  }

  void _handleIndicatorParameters(BuildContext context, WidgetRef ref) {

  }
}