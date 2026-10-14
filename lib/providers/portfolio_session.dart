import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../model/period_type.dart';
import '../model/portfolio_schema.dart';
import '../model/results/strategies/strategy_schema.dart';

part 'portfolio_session.g.dart';

@riverpod
class PortfolioSession extends _$PortfolioSession {
  @override
  PortfolioConfig build(PortfolioConfig? portfolio) {
    return portfolio ?? PortfolioConfig.emptyPortfolio();
  }

  String get name => state.portfolioName;
  String get description => state.portfolioDesc;
  double get riskFreeRate => state.riskFreeRatePerYear;
  List<AssetAllocation> get assetAllocations => state.assetAllocations;
  DateTime get createdDateTime => state.createdDateTime;
  DateTime? get startDateTime => state.startDateTime;
  DateTime? get endDateTime => state.endDateTime;
  Strategy? get strategy => state.strategy;
  PeriodType? get analysisPeriod => state.analysisPeriod;

  void save(PortfolioConfig updatedPortfolio) => state = updatedPortfolio;

  void updateField(PortfolioConfig Function(PortfolioConfig current) transform) {
    state = transform(state);
  }

  void clear() => state = PortfolioConfig.emptyPortfolio();

  PortfolioConfig finalize() => state;
}
