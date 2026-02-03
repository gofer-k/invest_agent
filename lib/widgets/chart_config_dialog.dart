import 'package:flutter/material.dart';
import 'package:invest_agent/widgets/utils/dropdown.dart';
import '../model/charts_configuration.dart';

void showConfigurationChart(
    BuildContext context, Function(MultiChart newMultiChart) onSave) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return ChartConfigDialog(onSave: onSave);
    },
  );
}

class ChartConfigDialog extends StatefulWidget {
  final Function(MultiChart newMultiChart) onSave;

  const ChartConfigDialog({super.key, required this.onSave});

  @override
  State<ChartConfigDialog> createState() => _ChartConfigDialogState();
}

class _ChartConfigDialogState extends State<ChartConfigDialog> {
  String multiTitle = '';
  MainChartType selectedMainChart = MainChartType.linePrice;
  SupplementChart overlayChart = SupplementChart.sma;
  List<SupplementChart> selectedOverlayCharts = [];
  late final TextEditingController controller;

  @override
  void initState() {
    super.initState();
    controller = TextEditingController();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text("Add multi Chart"),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextField(
            controller: controller,
            decoration: InputDecoration(
              hintText: "Enter multi chart name",
              isDense: true, // Makes the field a bit more compact
              border: const OutlineInputBorder(),
            ),
            keyboardType: TextInputType.text,
            textAlign: TextAlign.end, // Align text to the right, closer to the unit
          ),
          Row(
            children: [
              Expanded(
                child: Dropdown<MainChartType>(
                  choices: MainChartType.values,
                  choiceType: selectedMainChart,
                  onSelected: (MainChartType? selected) {
                    if (selected != null) {
                      setState(() => selectedMainChart = selected);
                    }
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          const Text("Overlay Chart Types:"),
          Row(
            children: [
              Expanded(
                child: Dropdown<SupplementChart>(
                  choices: SupplementChart.values,
                  // A placeholder or the first item can be used as the initial display.
                  choiceType: overlayChart,
                  onSelected: (SupplementChart? selected) {
                    if (selected != null) overlayChart = selected;
                  },
                ),
              ),
              IconButton(icon: Icon(Icons.add_box_outlined), onPressed: () {
                setState(() => selectedOverlayCharts.add(overlayChart));
              }),
            ],
          ),
          Wrap(
            spacing: 8.0,
            runSpacing: 4.0,
            children: selectedOverlayCharts
                .map((chart) => Chip(
              label: Text(chart.toString().split('.').last),
              onDeleted: () {
                setState(() {
                  selectedOverlayCharts.remove(chart);
                });
              },
            )).toList(),
          ),
        ],
      ),
      actions: [
        BackButton(onPressed: () => Navigator.of(context).pop()),
        ElevatedButton(
          onPressed: () {
            multiTitle = controller.text;
            final newChart = MultiChart(title: multiTitle, mainChart: selectedMainChart,
              overlayCharts: selectedOverlayCharts);
            if (ChartsConfiguration.validate(newChart)) {
              widget.onSave(newChart);
              Navigator.of(context).pop();
            }
            else {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("Invalid chart configuration")),
              );
            }
          },
          child: const Text("Save"),
        ),
      ],
    );
  }
}
