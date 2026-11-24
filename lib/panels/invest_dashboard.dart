import 'package:desktop_multi_window/desktop_multi_window.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:invest_agent/model/asset_config.dart';
import 'package:invest_agent/model/charts_configuration.dart';
import 'package:invest_agent/model/portfolio_schema.dart';
import 'package:invest_agent/model/results/analysis_respond.dart';
import 'package:invest_agent/panels/risk_management_panel.dart';
import 'package:invest_agent/themes/app_themes.dart';
import 'package:invest_agent/widgets/app_logo.dart';
import 'package:invest_agent/widgets/browser_tabs_view.dart';
import 'package:invest_agent/widgets/utils/dropdownlist.dart';
import 'package:invest_agent/widgets/utils/tabbed_window_type.dart';
import 'package:invest_agent/widgets/utils/task_bar_icon.dart';

import '../providers/load_database_provider.dart';
import '../providers/model_config.dart';
import '../providers/portfolio_provider.dart';
import '../providers/tab_window_session.dart';
import '../widgets/app_task_bar.dart';
import 'main_settings_panel.dart';

enum LeftPaneIndex {
  mainSettings("Main Settings"),
  request("Request"),
  results("Results"),
  notUsed("");

  const LeftPaneIndex(this.name);

  final String name;
}

enum RightPaneIndex {
  analysisResults("Analysis results"),
  notUsed("");

  const RightPaneIndex(this.name);

  final String name;
}

class InvestDashboard extends ConsumerStatefulWidget {
  const InvestDashboard({super.key});

  @override
  ConsumerState<InvestDashboard> createState() => _InvestDashboardState();
}

class _InvestDashboardState extends ConsumerState<InvestDashboard> {
  ChartsConfiguration configurationCharts = ChartsConfiguration();
  AnalysisRespond? analysisResult;

  bool isLoading = false;
  String? errorMessage;
  String chartTitle = "";

  var activeLeftPaneIndex = LeftPaneIndex.notUsed;
  var activeRightPaneIndex = RightPaneIndex.notUsed;
  AssetConfig? _selectedAsset;
  PortfolioConfig? _selectedPortfolio;

  final List<WindowController> _childWindows = [];

  @override
  void initState() {
    super.initState();
    onWindowsChanged.listen((_) async {
      final windows = await WindowController.getAll();
      debugPrint('Active windows count: ${windows.length}');
    });
  }

  @override
  void dispose() {
    _destroyAllChildren();
    super.dispose();
  }

  Future<void> _destroyAllChildren() async {
    for (var controller in _childWindows) {
      try {
        await controller.invokeMethod('window_close');
      } catch (_) {}
    }
    _childWindows.clear();
  }

  @override
  Widget build(BuildContext context) {
    final notifier = ref.watch(tabWindowSessionProvider().notifier);
    ref.listen<List<AssetConfig>>(sortedAssetsProvider, (previous, next) {
      if (notifier.activeTab?.cache != null && next.isNotEmpty) {
        setState(() {
          notifier.addTab(
            TabWindow(type: TabbedWindowType.asset, cache: next.first),
          );
        });
      }
    });

    ref.watch(portfolioProvider(CacheKeyType.analysisCache)).whenData((
      portfolios,
    ) {
      if (portfolios.getItems().isNotEmpty) {
        setState(() {
          notifier.addTab(
            TabWindow(
              type: TabbedWindowType.portfolio,
              cache: portfolios.getItems().first,
            ),
          );
        });
      }
    });

    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 40,
        automaticallyImplyLeading: false,
        backgroundColor: AppTheme.of(context).barColor,
        elevation: 0,
        shape: Border(
          bottom: BorderSide(
            color: AppTheme.of(context).borderColor ?? Colors.transparent,
            width: 1,
          ),
        ),
        titleSpacing: 0,
        title: Row(children: [Expanded(child: _buildHorizontalTaskbar())]),
      ),
      body: Row(
        mainAxisSize: MainAxisSize.max,
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          _buildVerticalTaskbar(),
          _buildLeftPane(),
          Expanded(flex: 4, child: _buildMainPane(ref)),
          _buildRightPane(),
        ],
      ),
    );
  }

  Widget _buildHorizontalTaskbar() {
    return AppHorizontalTaskBar(
      mainActions: [
        AppLogo(size: 24, color: AppTheme.of(context).indicatorRate),
        const SizedBox(width: 24),
        _displayAssetsList(),
        _openAssetsTab(),
        VerticalDivider(
          width: 1,
          thickness: 1.5,
          color: Theme.of(context).dividerColor,
        ),
        _displayPortfolioList(),
        _openPortfolioTab(),
      ],
      overflowActions: [
        VerticalDivider(
          width: 1,
          thickness: 1,
          color: Theme.of(context).dividerColor,
        ),
        FittedBox(
          fit: BoxFit.fitWidth,
          child: Text(
            "Placeholder",
            style: Theme.of(context).textTheme.labelLarge,
          ),
        ),
      ],
    );
  }

  Widget _buildVerticalTaskbar() {
    return AppVerticalTaskBar(
      mainActions: [
        TaskBarIcon(
          icon: Icons.settings,
          tooltip: 'Main Settings',
          color: activeLeftPaneIndex == LeftPaneIndex.mainSettings
              ? AppTheme.of(context).taskHighlightColor
              : null,
          onPressed: () => _toggleVerticalLeftPanel(LeftPaneIndex.mainSettings),
        ),
        const Divider(height: 20, indent: 8, endIndent: 8),
        TaskBarIcon(
          icon: Icons.bar_chart,
          tooltip: 'Analysis results',
          color: activeRightPaneIndex == RightPaneIndex.analysisResults
              ? AppTheme.of(context).taskHighlightColor
              : null,
          onPressed: () =>
              _toggleVerticalRightPane(RightPaneIndex.analysisResults),
        ),
      ],
      overflowActions: [
        ListTile(
          leading: const Icon(Icons.help_outline, size: 20),
          title: const Text('Help'),
          onTap: () => Navigator.pop(context),
        ),
      ],
    );
  }

  void _toggleVerticalLeftPanel(LeftPaneIndex index) {
    setState(() {
      if (activeLeftPaneIndex == index) {
        activeLeftPaneIndex =
            LeftPaneIndex.notUsed; // Hide if same icon clicked
      } else {
        activeLeftPaneIndex = index; // Switch to new panel
      }
    });
  }

  void _toggleVerticalRightPane(RightPaneIndex index) {
    setState(() {
      if (activeRightPaneIndex == index) {
        activeRightPaneIndex =
            RightPaneIndex.notUsed; // Hide if same icon clicked
      } else {
        activeRightPaneIndex = index; // Switch to new panel
      }
    });
  }

  Widget _buildLeftPane() {
    if (activeLeftPaneIndex != LeftPaneIndex.notUsed) {
      return SizedBox(
        width: 350,
        child: Container(
          decoration: BoxDecoration(
            border: Border(
              right: BorderSide(color: Theme.of(context).dividerColor),
            ),
          ),
          child: Column(
            children: [
              // Panel Header with Hide Icon
              Container(
                height: 40,
                padding: const EdgeInsets.symmetric(horizontal: 8),
                color: Theme.of(context).brightness == Brightness.dark
                    ? const Color(0xFF3C3F41)
                    : const Color(0xFFF2F2F2),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      activeLeftPaneIndex.name,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.remove, size: 18),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                      tooltip: 'Hide settings',
                      onPressed: () => setState(
                        () => activeLeftPaneIndex = LeftPaneIndex.notUsed,
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(child: _buildSettingsActivePanel()),
            ],
          ),
        ),
      );
    }
    return SizedBox.shrink();
  }

  Widget _buildRightPane() {
    if (activeRightPaneIndex != RightPaneIndex.notUsed) {
      return SizedBox(
        width: 350,
        child: Container(
          decoration: BoxDecoration(
            border: Border(
              right: BorderSide(color: Theme.of(context).dividerColor),
            ),
          ),
          child: Column(
            children: [
              // Panel Header with Hide Icon
              Container(
                height: 40,
                padding: const EdgeInsets.symmetric(horizontal: 8),
                color: Theme.of(context).brightness == Brightness.dark
                    ? const Color(0xFF3C3F41)
                    : const Color(0xFFF2F2F2),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      activeRightPaneIndex.name,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.remove, size: 18),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                      tooltip: 'Hide results',
                      onPressed: () => setState(
                        () => activeRightPaneIndex = RightPaneIndex.notUsed,
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(child: _buildAnalysisResults()),
            ],
          ),
        ),
      );
    }
    return SizedBox.shrink();
  }

  Widget _buildSettingsActivePanel() {
    switch (activeLeftPaneIndex) {
      case LeftPaneIndex.mainSettings:
        return const MainSettingsPanel();
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildAnalysisResults() {
    if (activeRightPaneIndex == RightPaneIndex.analysisResults) {
      return const RiskManagementPanel();
    }
    return const SizedBox.shrink();
  }

  Widget _displayAssetsList() {
    final assets = ref.watch(sortedAssetsProvider);
    if (assets.isEmpty) {
      return const SizedBox(
        width: 100,
        child: Text("Loading assets...", style: TextStyle(fontSize: 11)),
      );
    }
    if (_selectedAsset == null && assets.isNotEmpty) {
      _selectedAsset = assets.first;
    }

    return DropdownList<AssetConfig>(
      textStyle: Theme.of(context).textTheme.labelLarge,
      backgroundColor: Colors.grey.shade600.withAlpha(128),
      onSelected: (AssetConfig asset) {
        setState(() {
          _selectedAsset = asset;
        });
      },
      choiceType: _selectedAsset ?? assets.first,
      choices: assets,
    );
  }

  Widget _openAssetsTab() {
    return IconButton(
      icon: const Icon(Icons.add_card, size: 20),
      tooltip: 'Open Selected Asset as New Tab',
      onPressed: () {
        if (_selectedAsset != null) {
          ref
              .read(tabWindowSessionProvider().notifier)
              .addTab(
                TabWindow(type: TabbedWindowType.asset, cache: _selectedAsset!),
              );
        }
      },
    );
  }

  Widget _displayPortfolioList() {
    final portfolioAsync = ref.watch(
      portfolioProvider(CacheKeyType.analysisCache),
    );
    final portfolios = portfolioAsync.value?.getItems() ?? [];
    if (portfolios.isEmpty) {
      return const SizedBox.shrink();
    }
    if (_selectedPortfolio == null && portfolios.isNotEmpty) {
      _selectedPortfolio = portfolios.first;
    }
    return DropdownList<PortfolioConfig>(
      textStyle: Theme.of(context).textTheme.labelLarge,
      backgroundColor: Colors.grey.shade600.withAlpha(128),
      onSelected: (PortfolioConfig portfolio) {
        setState(() {
          _selectedPortfolio = portfolio;
        });
      },
      choiceType: _selectedPortfolio ?? portfolios.first,
      choices: portfolios,
    );
  }

  Widget _openPortfolioTab() {
    return IconButton(
      icon: const Icon(Icons.account_balance_wallet, size: 20),
      tooltip: "Open portfolio's assets and te related signals",
      onPressed: () {
        if (_selectedPortfolio != null) {
          ref
              .read(tabWindowSessionProvider().notifier)
              .addTab(
                TabWindow(
                  type: TabbedWindowType.portfolio,
                  cache: _selectedPortfolio!,
                ),
              );
        }
      },
    );
  }

  Widget _buildMainPane(WidgetRef ref) {
    return BrowserTabsView();
  }
}
