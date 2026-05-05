
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:invest_agent/widgets/utils/shrinkable.dart';
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
  late Map<String, dynamic> parameters = {};

  @override
  void initState() {
    super.initState();
    controllerName = TextEditingController(text: widget.indicator?.toString() ?? '');
    controllerType = TextEditingController(text: widget.indicator?.type ?? '');
    parameters = widget.indicator?.parameters ?? {};
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
      content: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
          child: Column(
        // mainAxisSize: MainAxisSize.min,
            children: [
              _editIndicatorName(controllerName, "Input indicator name", "Indicator name"),
              const SizedBox(height: 8),
              _editIndicatorName(controllerType, "Input type: e.g. Moving Average", "Indicator type"),
              const SizedBox(height: 16),
              Text("Parameters", style: Theme.of(context).textTheme.headlineSmall),
              ElevatedButton.icon(
                icon: const Icon(Icons.add),
                label: const Text('Add parameter'),
                onPressed: () => _handleAddParameter(context, ref),
              ),
              for (var parameter in parameters.entries)
                Shrinkable(
                  expanded: true,
                  title: parameter.key,
                  actions: [
                    IconButton(
                      icon: Icon(Icons.delete, color: Theme.of(context).colorScheme.error),
                      onPressed: () {
                        setState(() => parameters.remove(parameter.key) );
                      }
                    ),
                  ],
                  body: _buildIndicatorParameter(context, parameter),
               ),
                const SizedBox(height: 8),
            ],
          ),
        ),
        actions: [
          BackButton(onPressed: () => Navigator.of(context).pop()),
          ElevatedButton(onPressed: () {
            final name = controllerName.text.trim();
            if (name.isEmpty) return;
            final newIndicator = Indicator(id: widget.indicator?.id ?? -1,
              name: name,
              type: controllerType.text.trim(),
              parameters: parameters
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

  Widget _buildIndicatorParameter(BuildContext context, MapEntry<String, dynamic> parameter) {
    if (parameter.value is List) {
      final inputType = parameter.value is List<num> ? TextInputType.numberWithOptions() : TextInputType.text;
      return Column(
        children: [
          Wrap(spacing: 8,
            children: (parameter.value as List).map<Widget>((w) =>
              Chip(label: Text("$w"),
                onDeleted: () {
                  setState(() => parameter.value.remove(w));
                },
              )
            ).toList(),
          ),
          Row(
            children: [
              Expanded(
                child: TextField(

                  decoration: InputDecoration(labelText: "Add ${parameter.key}"),
                    keyboardType: inputType,
                    onSubmitted: (v) {
                      final parsed = num.tryParse(v);
                      if (parsed != null) {
                        setState(() => parameter.value.add(parsed));
                      }
                    },
                ),
              ),
            ],
          ),
        ]
      );
    }
    return
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: TextField(
          controller: TextEditingController(text: parameter.value.toString()),
          decoration: InputDecoration(labelText: "Value for ${parameter.key}"),
          keyboardType: parameter.value is num ? TextInputType.numberWithOptions() : TextInputType.text,
          onChanged: (v) {
            final parsed = num.tryParse(v);
            if (parsed != null) {
              parameters[parameter.key] = parsed;
            } else {
              parameters[parameter.key] = v.trim();
            }
          },
        ),
      );
  }

  void _handleAddParameter(BuildContext context, WidgetRef ref) {

  }
}
