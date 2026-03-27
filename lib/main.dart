import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:invest_agent/themes/app_themes.dart';
import 'package:invest_agent/widgets/utils/logger_riverpod.dart';

import 'panels/invest_dashboard.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    ProviderScope(
      observers: [
        LoggerRiverpod(),
      ],
      child: const InvestApp(),
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
