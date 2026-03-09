import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

import '../model/portfolio_config.dart';
import '../themes/app_themes.dart';
import '../widgets/utils/shrinkable.dart';

class PortfolioConfigPanel extends StatefulWidget {
  const PortfolioConfigPanel({super.key});

  @override
  State<StatefulWidget> createState() => _PortfolioConfigPanelState();
}

class _PortfolioConfigPanelState extends State<PortfolioConfigPanel> {
  List<PortfolioConfig> configs = [];
  PortfolioConfig? selectedConfig;
  String? config_file;

  final _formKey = GlobalKey<FormState>();
  final nameController = TextEditingController();
  final weightController = TextEditingController();
  final metaIdController = TextEditingController();
  final thresholdController = TextEditingController(text: "0.05");

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child:_buildForm()
    );
  }

  Widget _buildForm() {
    return Form(key: _formKey,
      child: Column(
        children: [
          Shrinkable(title: "Load data",
            expanded: true,
            body: Column(
              children: [
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                      side: BorderSide(width: 1.0, color: AppTheme.of(context).buttonOutlineColor?? Colors.deepPurpleAccent)),
                  onPressed: () => _pickCacheFile("db"),
                  child: const Text("Select historical dataset"),
                ),
                const SizedBox(height: 10),
                Text(config_file ?? "No file selected"),
              ],
            ),
          ),
          TextFormField(controller: nameController,
            decoration: InputDecoration(labelText: 'Portfolio name'),
            validator: (value) => (value == null || value.isEmpty) ? 'put a name' : null,),
          // TODO: Load list of asset names from the database
          // Chiping the list of assets
          // TextFormField(
          //   controller: metaIdController,
          //   decoration: InputDecoration(labelText: 'Meta ID (FK)'),
          //   keyboardType: TextInputType.number,
          //   validator: (value) {
          //     if (value == null || int.tryParse(value) == null) return 'Podaj poprawne ID';
          //     return null;
          //   },
          // ),
          TextFormField(
            controller: weightController,
            decoration: InputDecoration(labelText: 'Target Weight (0.0 - 1.0)', hintText: 'np. 0.25'),
            validator: (value) {
              final val = double.tryParse(value ?? '');
              if (val == null) return 'NUmber [0-1.0]';
              if (val < 0 || val > 1.0) return 'Weight is out of range';
              return null;
            },
          ),
          TextFormField(
            controller: thresholdController,
            decoration: InputDecoration(labelText: 'Rebalance Threshold'),
            validator: (value) {
              if (value != null && value.isNotEmpty && double.tryParse(value) == null) {
                return 'Incorrect format';
              }
              return null;
            },
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              ElevatedButton(
                onPressed: _submitData,
                child: Text(selectedConfig == null ? 'Add' : 'Update'),
              ),
              ElevatedButton(
                onPressed: _removePortfolio,
                child: Text('Remove'),
              ),
              if (selectedConfig != null)
                TextButton(
                  onPressed: () => setState(() => selectedConfig = null),
                  child: Text('Cancel'),
                ),
            ],
          ),
        ]
      )
    );
  }

  void _submitData() {
    if (_formKey.currentState!.validate()) {
      final config = PortfolioConfig(
        id: selectedConfig?.id,
        portfolioName: nameController.text,
        metaId: int.parse(metaIdController.text),
        targetWeight: double.parse(weightController.text),
        rebalanceThreshold: double.parse(thresholdController.text),
      );
      //TODO:
      // _saveToDuckDb(config);
    }
  }

  void _removePortfolio() {
  }

  void _saveOrUpdate() {

  }

  void _delete() {

  }

  Future<void> _pickCacheFile(String extension) async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: [extension],
      );

      if (result == null || result.files.single.path == null) return;
      // After the await, the widget might be gone.
      if (!mounted) return;

      config_file = result.files.single.path!;
    } catch (e) {
      // After the await (which might have thrown the error), check if the widget is still here.
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading file: $e')),
      );
    }
  }
}