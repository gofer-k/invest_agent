import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

class EtfSettingsPanel extends StatefulWidget {
  final void Function(Map<String, dynamic>) onRunAnalysis;

  const EtfSettingsPanel({
    super.key,
    required this.onRunAnalysis,
  });

  @override
  State<EtfSettingsPanel> createState() => _EtfSettingsPanelState();
}

class _EtfSettingsPanelState extends State<EtfSettingsPanel> {
  // --- ETF selection ---
  final List<String> etfSymbols = ["VOO", "SPY", "QQQ", "IWM", "EFA"];
  String selectedSymbol = "VOO";

  // --- Dataset selection ---
  late String? datasetSources = null;
  String selectedDataset = "Choose dataset file";

  // --- Rolling windows ---
  List<int> rollingWindows = [20, 50, 100, 150, 200, 250];

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
  final Set<String> selectedFactors = {
    "SMA", "BB", "MACD", "RSI", "EMA", "golden_cross", "death_cross", "Volume"};

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _sectionTitle("Raw Input File Path"),
              ElevatedButton(
                onPressed: _pickAndLoadFile,
                child: const Text("Select historical dataset"),
              ),
            ],
          ),

          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _sectionTitle("ETF Symbol"),
              Text(datasetSources ?? "No file selected"),
            ],
          ),

          const SizedBox(height: 20),
          _sectionTitle("Rolling Windows"),
          Wrap(
            spacing: 8,
            children: rollingWindows
                .map((w) => Chip(
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
                    labelText: "Add window",
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

          const SizedBox(height: 20),
          _sectionTitle("Strategy Parameters (SMA)"),
          Row(
            children: [
              Expanded(
                child: _numberField(
                  label: "Fast",
                  value: smaFast,
                  onChanged: (v) => setState(() => smaFast = v),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _numberField(
                  label: "Slow",
                  value: smaSlow,
                  onChanged: (v) => setState(() => smaSlow = v),
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),
          _sectionTitle("Factor Models"),
          Wrap(
            spacing: 8,
            children: factorOptions.map((factor) {
              final selected = selectedFactors.contains(factor);
              return FilterChip(
                label: Text(factor),
                selected: selected,
                onSelected: (v) {
                  setState(() {
                    if (v) {
                      selectedFactors.add(factor);
                    } else {
                      selectedFactors.remove(factor);
                    }
                  });
                },
              );
            }).toList(),
          ),

          const SizedBox(height: 30),
          Center(
            child: ElevatedButton(
              onPressed: _runAnalysis,
              child: const Text("Run Analysis"),
            ),
          ),
        ],
      ),
    );
  }

  void _runAnalysis() {
    final payload = {
      "symbol_ticker": selectedSymbol,
      "dataset_source": selectedDataset,
      "rolling_windows": rollingWindows,
      "strategy": {
        "type": "sma",
        "fast": smaFast,
        "slow": smaSlow,
      },
      "factors": selectedFactors.toList(),
    };

    widget.onRunAnalysis(payload);
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

  Widget _numberField({
    required String label,
    required int value,
    required void Function(int) onChanged,
  }) {
    return TextField(
      decoration: InputDecoration(labelText: label),
      keyboardType: TextInputType.number,
      controller: TextEditingController(text: value.toString()),
      onSubmitted: (v) {
        final parsed = int.tryParse(v);
        if (parsed != null) onChanged(parsed);
      },
    );
  }

Future<void> _pickAndLoadFile() async {
  try {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['gz'],
    );

    if (result == null || result.files.single.path == null) return;

    setState(() {
      datasetSources = result.files.single.path!;
    });
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      // TODO: handle error better
      SnackBar(content: Text('Error loading file: $e')),
    );
  }
}
}
