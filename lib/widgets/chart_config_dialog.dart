import 'package:flutter/material.dart';
import 'package:invest_agent/widgets/utils/dropdown.dart';
import '../model/analysis_configuration.dart';

typedef onAddMultiChartFunc = void Function(MultiChart);

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
            widget.onSave(newChart);
            Navigator.of(context).pop();
          },
          child: const Text("Save"),
        ),
      ],
    );
  }
}
///
// void showConfigurationChart(BuildContext context, onAddMultiChartFunc onAddMultiChart) async {
//   MainChartType selectedMainChart = MainChartType.linePrice;
//   List<SupplementChart> overlayCharts = [];
//
//   showDialog(
//     context: context,
//     barrierDismissible:
//         true, // User can dismiss the dialog by tapping outside of it
//     builder: (BuildContext dialogContext) {
//       return AlertDialog(
//         title: const Text('Add multi chart'),
//         content: SingleChildScrollView(
//           child: Column(
//             mainAxisAlignment: MainAxisAlignment.start,
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Dropdown<MainChartType>(
//                 onSelected: (MainChartType selected) {
//                 if (selected != selectedMainChart) {
//                   selectedMainChart = selected;
//                 }
//               },
//               choiceType: selectedMainChart, choices: MainChartType.values),
//               const SizedBox(height: 8),
//               const Text("Overlay chart types"),
//               Expanded(
//                 child: Dropdown<SupplementChart>(
//                   onSelected: (SupplementChart selected) {
//                     if (!overlayCharts.contains(selected)) {
//                       overlayCharts.add(selected);
//                     }
//                   },
//                   choiceType: SupplementChart.sma, choices: SupplementChart.values),
//               ),
//               Wrap(spacing: 8,
//                 children: overlayCharts.map((w) =>
//                   Chip(label: Text("$w"),
//                     onDeleted: () => overlayCharts.remove(w)
//                   )
//                 ).toList(),
//               ),
//             ],
//           )
//         ),
//         actions: <Widget>[
//           IconButton(icon: Icon(Icons.add), onPressed: (){
//             MultiChart newChart = MultiChart(mainChart: selectedMainChart, overlayCharts: overlayCharts);
//             onAddMultiChart(newChart);
//             Navigator.of(dialogContext).pop();
//           }),
//           IconButton(icon: Icon(Icons.undo_outlined), onPressed: () {
//             Navigator.of(dialogContext).pop();
//           }),
//         ],
//       );
//     },
//   );
// }
