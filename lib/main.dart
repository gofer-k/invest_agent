import 'package:flutter/material.dart';

import 'invest_dashboard.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  // final data = await loadFinancialDataFromGzip();
  runApp(MaterialApp(home: InvestDashboard()));
}
