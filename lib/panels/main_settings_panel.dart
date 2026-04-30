import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:invest_agent/panels/portfolio_panel.dart';
import '../providers/load_database_provider.dart';
import 'account_panel.dart';
import 'index_price_panel.dart';

class MainSettingsPanel extends ConsumerStatefulWidget {
  const MainSettingsPanel({super.key});

  @override
  ConsumerState<MainSettingsPanel> createState() => _MainSettingsPanel();
}

  class _MainSettingsPanel extends ConsumerState<MainSettingsPanel> {
    Widget portfolioSection() {
     // TODO: add portfolio section
    return Column();
  }

  @override
  Widget build(BuildContext context) {
    final currentPath = ref.watch(loadDatabaseProvider(CacheKeyType.priceCache)).value ?? 'Loading...';

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
            onTap: (){},
          ),
          const SizedBox(height: 24),
          AccountPanel(),
          IndexPricePanel(),
          PortfolioPanel()
        ],
      ),
    );
  }
}
