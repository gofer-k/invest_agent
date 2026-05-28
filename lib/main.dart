import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:invest_agent/providers/logger_riverpod.dart';
import 'package:invest_agent/themes/app_themes.dart';
import 'package:invest_agent/widgets/app_launcher.dart';

import 'panels/invest_dashboard.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    ProviderScope(
      observers: [
        LoggerRiverpod(),
      ],
      child: MaterialApp(
        theme: AppThemes.lightTheme,
        darkTheme: AppThemes.darkTheme,
        themeMode: ThemeMode.system,
        home: AppLauncher(onLoaded: (context) => const InvestDashboard()),
      )
    ),
  );
}

class InvestApp extends StatelessWidget {
  const InvestApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: const InvestDashboard(),
      darkTheme: AppThemes.darkTheme,
      theme: AppThemes.lightTheme,
      themeMode: ThemeMode.system,
    );
  }
}
