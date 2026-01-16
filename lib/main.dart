import 'package:flutter/material.dart';
import 'package:invest_agent/themes/app_themes.dart';

import 'invest_dashboard.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(MaterialApp(home: InvestDashboard(),
    darkTheme: AppThemes.darkTheme,
    theme: AppThemes.lightTheme,
    themeMode: ThemeMode.system,
  ));
}
