import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../model/results/strategies/global_equity_momentum.dart';
import '../model/results/strategies/mean_reversion.dart';
import '../model/results/strategies/strategy_schema.dart';

part 'strategy_session.g.dart';

@riverpod
class StrategySession extends _$StrategySession {
  @override
  Strategy build(Strategy? strategy) {
    return strategy ?? Strategy.emptyStrategy();
  }

  StrategyType get type => state.type;
  String get name => state.name;

  void save(Strategy updatedStrategy) => state = updatedStrategy;

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

  Strategy finalize() => state;
}