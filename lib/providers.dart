import 'package:invest_agent/utils/database_helper.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'providers.g.dart';

@riverpod
DatabaseHelper databaseHelper(Ref ref) {
  // Use a default path or fetch from a config service
  return DatabaseHelper('invest_agent.db');
}
