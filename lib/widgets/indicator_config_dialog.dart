
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
  bool addingParameter = false;

  @override
  void initState() {
    super.initState();
    controllerName = TextEditingController(text: widget.indicator?.name ?? '');
    controllerType = TextEditingController(text: widget.indicator?.type ?? '');
    // Ensure parameters is a mutable copy
    parameters = Map<String, dynamic>.from(widget.indicator?.parameters ?? {});
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
      title: Text("Indicator ${widget.indicator?.name ?? 'New'}"),
      content: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              _editIndicatorName(controllerName, "Input indicator name", "Indicator name"),
              const SizedBox(height: 8),
              _editIndicatorName(controllerType, "Input type: e.g. Moving Average", "Indicator type"),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text("Parameters", style: Theme.of(context).textTheme.headlineSmall),
                  IconButton(
                    icon: Icon(addingParameter ? Icons.close : Icons.add),
                    onPressed: () => setState(() => addingParameter = !addingParameter),
                  ),
                ],
              ),
              if (addingParameter) _handleAddParameter(context),
              const SizedBox(height: 8),
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
               // const SizedBox(height: 8),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text("Cancel")),
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
      controller: controller,
      decoration: InputDecoration(labelText: label, hintText: hint,
        border: const OutlineInputBorder(),
      ),
      keyboardType: TextInputType.text,
    );
  }

  Widget _buildIndicatorParameter(BuildContext context, MapEntry<String, dynamic> parameter) {
    if (parameter.value is List) {
      final list = parameter.value as List;
      return Column(
        children: [
          Wrap(
            spacing: 8,
            children: list.map<Widget>((item) =>
                Chip(
                  label: Text("$item"),
                  onDeleted: () {
                    // REMOVE ONLY THE VALUE FROM THE LIST
                    setState(() {
                      list.remove(item);
                    });
                  },
                )
            ).toList(),
          ),
          TextField(
            decoration: InputDecoration(labelText: "Add to ${parameter.key}"),
            onSubmitted: (v) {
              if (v.trim().isEmpty) return;
              final parsed = num.tryParse(v) ?? v.trim();
              setState(() => list.add(parsed));
            },
          ),
        ],
      );
    }

    // Single value editor
    return TextField(
      controller: TextEditingController(text: parameter.value.toString()),
      decoration: InputDecoration(labelText: "Value for ${parameter.key}"),
      onChanged: (v) {
        parameters[parameter.key] = num.tryParse(v) ?? v.trim();
      },
    );
  }

  Widget _handleAddParameter(BuildContext context) {
    return TextField(
      decoration: const InputDecoration(
        labelText: "New parameter name",
        hintText: "Enter name and press Enter",
        border: OutlineInputBorder(),
      ),
      autofocus: true,
      onSubmitted: (v) {
        if (v.trim().isNotEmpty) {
          setState(() {
            // Initialize as an empty mutable list
            parameters[v.trim()] = [];
            addingParameter = false;
          });
        }
      },
    );
  }
  // Widget _handleAddParameter(BuildContext context) {
  //   final nameController = TextEditingController();
  //   return Column(
  //       children: [
  //         TextField(
  //           controller: nameController,
  //           decoration: const InputDecoration(
  //             labelText: "New parameter name",
  //             border: OutlineInputBorder(),
  //             hintText: "e.g. Periods, Source, etc.",
  //           ),
  //           autofocus: true,
  //           onSubmitted: (v) {
  //             final name = v.trim();
  //             if (name.isNotEmpty) {
  //               setState(() {
  //                 // Initialize as an empty list so it uses the List UI
  //                 parameters[name] = [];
  //                 addingParameter = false;
  //               });
  //             }
  //           },
  //         ),
  //         Row(
  //           mainAxisAlignment: MainAxisAlignment.end,
  //           children: [
  //             TextButton(
  //               onPressed: () => setState(() => addingParameter = false),
  //               child: const Text("Cancel"),
  //             ),
  //             ElevatedButton(
  //               onPressed: () {
  //                 final name = nameController.text.trim();
  //                 if (name.isNotEmpty) {
  //                   setState(() {
  //                     parameters[name] = [];
  //                     addingParameter = false;
  //                   });
  //                 }
  //               },
  //               child: const Text("Add"),
  //             ),
  //           ],
  //         ),
  //       ]
  //   );
  // }
}
