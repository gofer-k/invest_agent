import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:invest_agent/panels/portfolio_panel.dart';
import '../providers.dart';
import 'account_panel.dart';

class MainSettingsPanel extends ConsumerStatefulWidget {
  const MainSettingsPanel({super.key});

  @override
  ConsumerState<MainSettingsPanel> createState() => _MainSettingsPanel();
}

  class _MainSettingsPanel extends ConsumerState<MainSettingsPanel> {
   Future<void> _pickDbPath() async {
    final currentPath = ref.watch(databasePathProvider).value ?? 'Loading...';
    String? result = await FilePicker.platform.saveFile(
      dialogTitle: 'Select cache Location',
      fileName: currentPath,
    );

    if (result != null) {
      final pathNotifier = ref.read(databasePathProvider.notifier);
      await pathNotifier.setPath(result);
      setState(() {

      });
    }
  }

  Widget portfolioSection() {
     // TODO: add portfolio section
    return Column();
  }

  @override
  Widget build(BuildContext context) {
    final currentPath = ref.watch(databasePathProvider).value ?? 'Loading...';

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
            subtitle: Text(currentPath, style: const TextStyle(fontSize: 12)),
            trailing: const Icon(Icons.folder_open, size: 20),
            onTap: _pickDbPath,
          ),
          const SizedBox(height: 24),
          AccountPanel(),
          PortfolioPanel()
        ],
      ),
    );
  }
}
