import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:invest_agent/model/user_account.dart';
import 'package:invest_agent/panels/portfolio_config_panel.dart';
import 'package:invest_agent/utils/database_helper.dart';

import '../model/portfolio_config.dart';
import 'account_panel.dart';

class MainSettingsPanel extends StatefulWidget {
  const MainSettingsPanel({super.key});

  @override
  State<MainSettingsPanel> createState() => _MainSettingsPanelState();
}

class _MainSettingsPanelState extends State<MainSettingsPanel> {
  String _dbPath = 'No cache';
  late DatabaseHelper? db;

  @override
  void initState() {
    super.initState();
    _loadCacheData();
  }

  @override
  void dispose() {
    db?.dispose();
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
      _loadCacheData();
    }
  }

  Future<void> _loadCacheData() async {
    db = DatabaseHelper(_dbPath);
    try {
      // Ensure the table exists
      await db?.createCache(UserAccountSchema());
      await db?.createCache(PortfolioConfigSchema());
    } catch (e) {
      debugPrint('Error create cache: $e');
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
          if (db?.isConnected() ?? false)
            AccountPanel(db),
            PortfolioConfigPanel(db),
        ],
      ),
    );
  }
}
