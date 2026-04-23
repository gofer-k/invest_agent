import 'package:invest_agent/model/indicator_schema.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../model/cache_schema.dart';
import 'cache_notifier.dart';

part 'indicator_provider.g.dart';

@riverpod
class IndicatorNotifier extends _$IndicatorNotifier {
  static final _schema = IndicatorSchema();
  static const _defaultDbPath = 'indicators.db';

  IndicatorSchema get schema => _schema;
  late String? _dbPath;
  String get dbPath => _dbPath ?? _defaultDbPath;

  @override
  FutureOr<List<Indicator>> build([String? cachePath]) async {
    _dbPath = cachePath ?? _defaultDbPath;
    return ref.watch(cacheProvider<Indicator, IndicatorSchema>(_schema, dbPath).future);
  }

  Future<void> addEntry(Indicator entry) async {
    await ref.read(cacheProvider<Indicator, IndicatorSchema>(_schema, dbPath).notifier).addEntry(entry);
  }

  Future<void> updateIndicator(Indicator entry) async {
    await ref.read(cacheProvider<Indicator, IndicatorSchema>(_schema, dbPath).notifier).updateEntry(entry);
  }

  Future<void> deleteEntry(Indicator entry) async {
    await ref.read(cacheProvider<Indicator, IndicatorSchema>(_schema, dbPath).notifier).deleteEntry(entry);
  }

  Future<void> clearAll() async {
    await ref.read(cacheProvider<Indicator, IndicatorSchema>(_schema, dbPath).notifier).clearAll();
  }

  Future<void> toggleIndicator(Indicator indicator) async {
    final updated = Indicator(
      id: indicator.id,
      name: indicator.name,
      type: indicator.type,
      parameters: indicator.parameters,
      isEnabled: !indicator.isEnabled,
    );
    await updateIndicator(updated);
  }
}
