import 'package:invest_agent/model/analysis_schema.dart';
import 'package:invest_agent/utils/database_helper.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'analysis_provider.g.dart';

const String _analysisDbPath = 'analysis.db';

@Riverpod(keepAlive: true)
Future<DatabaseHelper> analysisDatabaseHelper(Ref ref) async {
  // Use a separate database file for analysis cache
  final helper = DatabaseHelper(_analysisDbPath);
  await helper.init();
  
  // Ensure table is created
  final schema = AnalysisSchema();
  await helper.createCache(schema);

  ref.onDispose(() {
    helper.dispose();
  });

  return helper;
}

@riverpod
class AnalysisNotifier extends _$AnalysisNotifier {
  @override
  FutureOr<List<AnalysisEntry>> build() async {
    final helper = await ref.watch(analysisDatabaseHelperProvider.future);
    return helper.fetchAll<AnalysisEntry>(AnalysisSchema());
  }

  Future<void> addEntry(AnalysisEntry entry) async {
    final helper = await ref.read(analysisDatabaseHelperProvider.future);
    await helper.saveOne(AnalysisSchema(), entry);
    if (ref.mounted) {
      ref.invalidateSelf();
    }
  }

  Future<void> deleteEntry(AnalysisEntry entry) async {
    final helper = await ref.read(analysisDatabaseHelperProvider.future);
    await helper.deleteOne(AnalysisSchema(), entry);
    if (ref.mounted) {
      ref.invalidateSelf();
    }
  }

  Future<void> clearAll() async {
    final helper = await ref.read(analysisDatabaseHelperProvider.future);
    await helper.deleteAll(AnalysisSchema());
    if (ref.mounted) {
      ref.invalidateSelf();
    }
  }
}
