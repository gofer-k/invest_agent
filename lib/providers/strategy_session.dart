import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../model/period_type.dart';
import '../model/results/strategies/global_equity_momentum.dart';
import '../model/results/strategies/mean_reversion.dart';
import '../model/results/strategies/strategy_schema.dart';
import '../widgets/dialogs/asset_dialog.dart';

part 'strategy_session.g.dart';

@riverpod
class StrategySession extends _$StrategySession {
  @override
  Strategy build(Strategy? strategy) {
    return strategy ?? Strategy.emptyStrategy();
  }

  StrategyType get type => state.type;
  String get name => state.name;
  double get cash => state.cash;
  FiatCurrencyEnum get currency => state.currency;
  PeriodType get analysisPeriod => state.analysisPeriod;
  DateTime get beginDate => state.beginDate;
  DateTime get endDate => state.endDate;

  void save(Strategy updatedStrategy) {
    state = updatedStrategy;
  }

  void updateType(StrategyType newType) {
    if (state.type == newType) return;

    // Convert the base state to the specific subclass when the type changes
    state = switch (newType) {
      StrategyType.meanReversion => MeanReversionConfig.fromStrategy(state),
      StrategyType.gem => GemStrategyConfig.fromStrategy(state),
      _ => state.copyWith(newType: newType), // Fallback for base/unimplemented types
    };
  }

  void updateField(Strategy Function(Strategy current) transform) {
    state = transform(state);
  }

  void clear() {
    state = Strategy.emptyStrategy();
  }

  Strategy finalize() {
    return state;
  }

}