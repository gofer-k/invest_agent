import 'package:invest_agent/model/analysis_schema.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'cache_notifier.dart';

part 'analysis_notifier.g.dart';

@riverpod
class AnalysisNotifier extends _$AnalysisNotifier {
  static final _schema = AnalysisSchema();
  static const _defaultDbPath = 'analysis.db';

  AnalysisSchema get schema => _schema;
  late String? _dbPath;
  String get dbPath => _dbPath ?? _defaultDbPath;

  @override
  FutureOr<List<AnalysisEntry>> build([String? path]) {
    _dbPath = path ?? _defaultDbPath;
    return ref.watch(cacheProvider<AnalysisEntry, AnalysisSchema>(_schema, dbPath).future);
  }

  Future<void> addEntry(AnalysisEntry entry) async {
    if (ref.mounted) {
      await ref.read(cacheProvider<AnalysisEntry, AnalysisSchema>(_schema, dbPath).notifier).addEntry(entry);
    }
  }

  Future<void> deleteEntry(AnalysisEntry entry) async {
    await ref.read(cacheProvider<AnalysisEntry, AnalysisSchema>(_schema, dbPath).notifier).deleteEntry(entry);
  }

  Future<void> clearAll() async {
    await ref.read(cacheProvider<AnalysisEntry, AnalysisSchema>(_schema, dbPath).notifier).clearAll();
  }
}
