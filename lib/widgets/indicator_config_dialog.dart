import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:invest_agent/widgets/utils/color_button.dart';
import 'package:invest_agent/widgets/utils/dropdownlist.dart';
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
  late Map<String, dynamic> parameters = {};
  bool addingParameter = false;
  IndicatorType _selectedType = IndicatorType.undefined;

  @override
  void initState() {
    super.initState();
    controllerName = TextEditingController(text: widget.indicator?.name ?? '');
    _selectedType = widget.indicator?.type ?? IndicatorType.undefined;
    parameters = Map<String, dynamic>.from(widget.indicator?.parameters ?? {});
  }

  @override
  void dispose() {
    controllerName.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text("Indicator ${widget.indicator?.name ?? 'New'}"),
      content: SizedBox(
        width: 320, // Fixed width to resolve IntrinsicWidth + Expanded issues in AlertDialog
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _editIndicatorName(controllerName, "Input indicator name", "Indicator name"),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text("Supplement chart", style: Theme.of(context).textTheme.labelLarge),
                  Switch(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    value: parameters[Indicator.mainChart] ?? false,
                    onChanged: (bool value) => setState(() {
                      parameters[Indicator.mainChart] = value;
                    })),
                  Text("Main chart", style: Theme.of(context).textTheme.labelLarge),
                ]
              ),
              const Divider(height: 4),
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
              for (var parameter in parameters.entries.where((e) => e.key != Indicator.mainChart))
                Shrinkable(
                  expanded: true,
                  title: parameter.key,
                  body: _buildIndicatorParameter(context, parameter),
               ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text("Cancel")),
        ElevatedButton(onPressed: () {
          final name = controllerName.text.trim();
          if (name.isEmpty) return;
          final newIndicator = Indicator(id: widget.indicator?.id ?? -1,
            name: name,
            type: _selectedType,
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
    if (parameter.value is Map) {
      return _editIndicatorParameter(context, parameter);
    }
    else if (parameter.value is List) {
      final list = parameter.value as List;
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 4.0),
        child:
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
            DropdownList<String>(
              onSelected: (item) {
                setState(() {
                  parameters[parameter.key] = Indicator.updateParameterValue(parameter.value, item);
                });
              },
              choiceType: list.first.toString(),
              choices: list.map((e) => e.toString()).toList(),
              backgroundColor: Colors.transparent,
            ),
          ]
         ),
      );
    }

    return _editIndicatorParameter(context, parameter);
  }

  Widget _editIndicatorParameter(
      BuildContext context,
      MapEntry<String, dynamic> parameter) {

    final value = parameter.value;
    final bool isEditable = Indicator.isEditable(value);
    final bool hasVisibility = Indicator.hasVisibilityOption(value);
    final bool isVisible = Indicator.isVisible(value);
    
    IndicatorParamType? type = Indicator.getParameterType(value);
    if (type == null && value is! String && value is! num) return const SizedBox.shrink();

    TextInputType keyboardType = switch(type) {
      IndicatorParamType.int => TextInputType.number,
      IndicatorParamType.double => const TextInputType.numberWithOptions(decimal: true),
      IndicatorParamType.string => TextInputType.text,
      IndicatorParamType.color => TextInputType.text,
      null => TextInputType.text,
    };

    final rawValue = Indicator.getParameterValue(value);
    final displayValue = rawValue?.toString() ?? '';

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          if (isEditable && type != IndicatorParamType.color)
            Expanded(
              child: TextFormField(
                key: ValueKey("edit_${parameter.key}_${widget.indicator?.id}"),
                initialValue: displayValue,
                decoration: const InputDecoration(
                  isDense: true,
                  labelText: "Value",
                  border: OutlineInputBorder(),
                ),
                keyboardType: keyboardType,
                onChanged: (v) {
                  setState(() {
                    parameters[parameter.key] = Indicator.updateParameterValue(value, v);
                  });
                },
              ),
            ),
          if (type == IndicatorParamType.color)
            Padding(
              padding: const EdgeInsets.only(left: 8.0),
              child: ColorButton(
                key: ValueKey("color_${parameter.key}"),
                label: parameter.key,
                hexValue: displayValue,
                showLabel: false, // Avoid internal Row with Expanded inside ColorButton
                onColorChanged: (String colorHex) {
                  setState(() {
                    parameters[parameter.key] = Indicator.updateParameterValue(value, colorHex);
                  });
                },
              ),
            ),
          
          if (hasVisibility)
            Checkbox.adaptive(
              value: isVisible,
              onChanged: (val) {
                if (val == null) return;
                setState(() {
                  parameters[parameter.key] = Indicator.updateParameterAttr(value, IndicatorParam.visible, val ? "1" : "0");
                });
              }
            ),
        ],
      ),
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
            parameters[v.trim()] = {"value": "0", "edit": "1", "type": "int", "visible": "1"};
            addingParameter = false;
          });
        }
      },
    );
  }
}
