import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:invest_agent/widgets/utils/shrinkable.dart';
import 'package:path/path.dart' as p;

import '../model/analysis_period.dart';
import '../model/analysis_request.dart';
import '../themes/app_themes.dart';

class RequestSettingsPanel extends StatefulWidget {
  final void Function(AnalysisRequest) onRunAnalysis;

  const RequestSettingsPanel({
    super.key,
    required this.onRunAnalysis,
  });

  @override
  State<RequestSettingsPanel> createState() => _RequestSettingsPanelState();
}

class _RequestSettingsPanelState extends State<RequestSettingsPanel> {
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

  List<IntervalType> intervals = IntervalType.values;
  IntervalType selectedInterval = IntervalType.day;

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
      period: PeriodType.max,
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
          expanded: true,
          body: Column(
            children: [
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  side: BorderSide(width: 1.0, color: AppTheme.of(context).buttonOutlineColor?? Colors.deepPurpleAccent)),
                onPressed: () => _pickAndLoadFile("csv"),
                child: const Text("Select historical dataset"),
              ),
              const SizedBox(height: 10),
              _sectionTitle("ETF Symbol"),
              Text(selectedSymbol ?? "No file selected"),
            ],
          ),
        ),
        Center(
          widthFactor: 4.0,
          heightFactor: 2.0,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
                side: BorderSide(width: 1.0, color: AppTheme.of(context).buttonOutlineColor?? Colors.deepPurpleAccent)),
            onPressed: _runAnalysis,
            child: const Text("Run Analysis", style: TextStyle(fontSize: 20)),
          ),
        ),
      ],
    );
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

  Future<void> _pickAndLoadFile(String extension) async {
  try {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: [extension],
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
      SnackBar(content: Text('Error loading file: $e')),
    );
  }
}
}
