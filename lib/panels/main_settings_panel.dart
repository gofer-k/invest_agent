import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:invest_agent/panels/portfolio_config_panel.dart';
import 'account_panel.dart';

class MainSettingsPanel extends StatefulWidget {
  const MainSettingsPanel({super.key});

  @override
  State<MainSettingsPanel> createState() => _MainSettingsPanelState();
}

class _MainSettingsPanelState extends State<MainSettingsPanel> {
  String _dbPath = 'No cache';

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

   Future<void> _pickDbPath() async {
    String? result = await FilePicker.platform.saveFile(
      dialogTitle: 'Select DuckDB Cache Location',
      fileName: 'No cache path',
    );

    if (result != null) {
      setState(() {
        _dbPath = result;
      });
      // TODO: save cache path to ModelManager
    }
  }

  Widget portfolioSection() {
return Column();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('General Settings', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const Divider(),
          ListTile(
            dense: true,
            title: const Text('Cache Location'),
            subtitle: Text(_dbPath, style: const TextStyle(fontSize: 12)),
            trailing: const Icon(Icons.folder_open, size: 20),
            onTap: _pickDbPath,
          ),
          const SizedBox(height: 24),
          AccountPanel(),
          // TODO: add portfolio section
          // PortfolioConfigPanel(),
        ],
      ),
    );
  }
}
