import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:invest_agent/widgets/rolling_list.dart';
import 'package:invest_agent/widgets/shrinkable.dart';
import 'package:path/path.dart' as p;

import '../model/analysis_request.dart';

class EtfSettingsPanel extends StatefulWidget {
  final void Function(AnalysisRequest) onRunAnalysis;

  const EtfSettingsPanel({
    super.key,
    required this.onRunAnalysis,
  });

  @override
  State<EtfSettingsPanel> createState() => _EtfSettingsPanelState();
}

class _EtfSettingsPanelState extends State<EtfSettingsPanel> {
  // --- Dataset selection ---
  String? datasetSource;
  String? selectedSymbol;

  // --- Rolling windows ---
  List<int> rollingWindows = [20, 50, 100, 150, 200, 250];
  List<String> analysisIndicators = [
    "SMA",
    "BB",
    "MACD",
    "RSI",
    "EMA",
    "golden_cross",
    "death_cross",
    "Volume"
  ];
  final _indicatorController = TextEditingController();

  List<String> intervals = ["1d", "1w", "1y"];
  String selectedInterval = "1d";

  List<String> periods = [
    "1d",
    "5d",
    "1w",
    "1mo",
    "3mo",
    "6mo",
    "1y",
    "2y",
    "3y",
    "5y",
    "max"
  ];
  String selectedPeriod = "1y";

  // --- Strategy parameters ---
  // TODO: Custom this
  int smaFast = 20;
  int smaSlow = 50;

  // --- Factor models ---
  final List<String> factorOptions = [
    "momentum",
    "value",
    "quality",
    "size",
    "low_vol"
  ];

  @override
  void dispose() {
    _indicatorController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: _settingPanel());
  }

  void _runAnalysis() {
    if (selectedSymbol == null || datasetSource == null) {
      return;
    }

    final request = AnalysisRequest(
      symbolTicker: selectedSymbol!,
      datasetSource: datasetSource!,
      rollingWindows: rollingWindows,
      interval: selectedInterval,
      period: selectedPeriod,
      strategy: StrategyParams(
        type: "sma",
        fast: smaFast,
        slow: smaSlow,
      ),
      techIndicators: analysisIndicators,
    );

    widget.onRunAnalysis(request);
  }

  Widget _settingPanel() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Shrinkable(title: "Load ETF data",
          body: Column(
            children: [
              ElevatedButton(
                onPressed: _pickAndLoadFile,
                child: const Text("Select historical dataset"),
              ),
              const SizedBox(height: 10),
              _sectionTitle("ETF Symbol"),
              Text(selectedSymbol ?? "No file selected"),
            ],
          ),
        ),
        Shrinkable(title: "Period: ($selectedPeriod)",
          body: RollingList<String>(values: periods, initialValue: "1y",
           onChanged: (String v) => setState(() => selectedPeriod = v))
        ),
        Shrinkable(title: "Interval: ($selectedInterval)",
          body: RollingList<String>(values: intervals, initialValue: intervals.first,
            onChanged: (String v) => setState(() => selectedInterval = v))),
        Shrinkable(title: "Rolling Windows",
          body: Column(
            children: [
              Wrap(
                spacing: 8,
                children: rollingWindows
                    .map((w) =>
                    Chip(
                      label: Text("$w"),
                      onDeleted: () {
                        setState(() => rollingWindows.remove(w));
                      },
                    ))
                    .toList(),
              ),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      decoration: const InputDecoration(
                        labelText: "Add rolling window",
                      ),
                      keyboardType: TextInputType.number,
                      onSubmitted: (v) {
                        final parsed = int.tryParse(v);
                        if (parsed != null) {
                          setState(() => rollingWindows.add(parsed));
                        }
                      },
                    ),
                  ),
                ],
              ),
            ]
        )),
        Shrinkable(title: "Technical Indicators",
          body: Column(
            children: [
              Wrap(spacing: 8,
                children: analysisIndicators.map((w) =>
                    Chip(
                      label: Text(w),
                      onDeleted: () {
                        setState(() => analysisIndicators.remove(w));
                      },
                    )).toList(),
              ),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                        controller: _indicatorController,
                        decoration: const InputDecoration(labelText: "Add indicator"),
                        keyboardType: TextInputType.name,
                        onSubmitted: (indicator) {
                          if (indicator.isNotEmpty) {
                            setState(() => analysisIndicators.add(indicator));
                            _indicatorController.clear();
                          }

                        }),
                  ),
                ],
              ),
            ],
          )
        ),
        const SizedBox(height: 30),
        Center(
          widthFactor: 4.0,
          heightFactor: 2.0,
          child: ElevatedButton(
            onPressed: _runAnalysis,
            child: const Text("Run Analysis", style: TextStyle(fontSize: 20)),
          ),
        ),
      ],
    );

    // TODO: add strategy parameters
    // const SizedBox(height: 20),
    // _sectionTitle("Strategy Parameters (SMA)"),
    // Row(
    //   children: [
    //     Expanded(
    //       child: _numberField(
    //         label: "Fast",
    //         value: smaFast,
    //         onChanged: (v) => setState(() => smaFast = v),
    //       ),
    //     ),
    //     const SizedBox(width: 16),
    //     Expanded(
    //       child: _numberField(
    //         label: "Slow",
    //         value: smaSlow,
    //         onChanged: (v) => setState(() => smaSlow = v),
    //       ),
    //     ),
    //   ],
    // ),
  }

  Widget _sectionTitle(String text) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  // Widget _numberField({
  //   required String label,
  //   required int value,
  //   required void Function(int) onChanged,
  // }) {
  //   return TextField(
  //     decoration: InputDecoration(labelText: label),
  //     keyboardType: TextInputType.number,
  //     controller: TextEditingController(text: value.toString()),
  //     onSubmitted: (v) {
  //       final parsed = int.tryParse(v);
  //       if (parsed != null) onChanged(parsed);
  //     },
  //   );
  // }

  Future<void> _pickAndLoadFile() async {
  try {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['gz'],
    );

    if (result == null || result.files.single.path == null) return;
    // After the await, the widget might be gone.
    if (!mounted) return;

    datasetSource = result.files.single.path!;
    setState(() {
      selectedSymbol = p.basenameWithoutExtension(result.files.single.path!);
    });
  } catch (e) {
    // After the await (which might have thrown the error), check if the widget is still here.
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      // TODO: handle error better
      SnackBar(content: Text('Error loading file: $e')),
    );
  }
}
}
