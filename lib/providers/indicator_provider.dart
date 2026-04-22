import 'package:invest_agent/model/indicator_schema.dart';
import 'package:invest_agent/providers/load_database_provider.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'indicator_provider.g.dart';

@riverpod
class IndicatorNotifier extends _$IndicatorNotifier {
  @override
  FutureOr<List<Indicator>> build() async {
    final helper = await ref.watch(databaseHelperProvider.future);
    
    // Ensure table exists (though usually done in an initialization step)
    final schema = IndicatorSchema();
    await helper.createCache(schema);
    
    return helper.fetchAll<Indicator>(schema);
  }

  Future<void> addIndicator(Indicator indicator) async {
    final helper = await ref.read(databaseHelperProvider.future);
    await helper.saveOne(IndicatorSchema(), indicator);
    ref.invalidateSelf();
  }

  Future<void> updateIndicator(Indicator indicator) async {
    final helper = await ref.read(databaseHelperProvider.future);
    await helper.updateOne(IndicatorSchema(), indicator);
    ref.invalidateSelf();
  }

  Future<void> deleteIndicator(Indicator indicator) async {
    final helper = await ref.read(databaseHelperProvider.future);
    await helper.deleteOne(IndicatorSchema(), indicator);
    ref.invalidateSelf();
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
