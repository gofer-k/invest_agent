
import 'package:equatable/equatable.dart';
import 'package:invest_agent/model/portfolio_schema.dart';

typedef PortfolioId = int;
typedef PortfolioResultMap = Map<PortfolioId, PortfolioResult>;

class PerformanceMetrics extends Equatable {
  final double totalReturn;
  final double annualizedReturn;
  final double volatility;
  final double sharpeRatio;
  final double sortinoRatio;
  final double maxDrawdown;
  final double alpha;
  final double beta;
  final double cagr;
  final double calmar;
  final double correlation;
  final double trackingError;
  final double trackingDiff;
  final double expenseRatio;
  final double bidAskSpread;
  final double concentration;
  final double dividendYield;

  const PerformanceMetrics({
    this.totalReturn = 0.0,
    this.annualizedReturn = 0.0,
    this.volatility = 0.0,
    this.sharpeRatio = 0.0,
    this.sortinoRatio = 0.0,
    this.maxDrawdown = 0.0,
    this.alpha = 0.0,
    this.beta = 0.0,
    this.cagr = 0.0,
    this.calmar = 0.0,
    this.correlation = 0.0,
    this.trackingError = 0.0,
    this.trackingDiff = 0.0,
    this.expenseRatio = 0.0,
    this.bidAskSpread = 0.0,
    this.concentration = 0.0,
    this.dividendYield = 0.0,
  });

  PerformanceMetrics copyWith({
    double? totalReturn,
    double? annualizedReturn,
    double? volatility,
    double? sharpeRatio,
    double? sortinoRatio,
    double? maxDrawdown,
    double? alpha,
    double? beta,
    double? cagr,
    double? calmar,
    double? correlation,
    double? trackingError,
    double? trackingDiff,
    double? expenseRatio,
    double? bidAskSpread,
    double? concentration,
    double? dividendYield}) {
    return PerformanceMetrics(
      totalReturn: totalReturn ?? this.totalReturn,
      annualizedReturn: annualizedReturn ?? this.annualizedReturn,
      volatility: volatility ?? this.volatility,
      sharpeRatio: sharpeRatio ?? this.sharpeRatio,
      sortinoRatio: sortinoRatio ?? this.sortinoRatio,
      maxDrawdown: maxDrawdown ?? this.maxDrawdown,
      alpha: alpha ?? this.alpha,
      beta: beta ?? this.beta,
      cagr: cagr ?? this.cagr,
      calmar: calmar ?? this.calmar,
      correlation: correlation ?? this.correlation,
      trackingError: trackingError ?? this.trackingError,
      trackingDiff: trackingDiff ?? this.trackingDiff,
      expenseRatio: expenseRatio ?? this.expenseRatio,
      bidAskSpread: bidAskSpread ?? this.bidAskSpread,
      concentration: concentration ?? this.concentration,
      dividendYield: dividendYield ?? this.dividendYield);
  }

  @override
  bool get stringify => true;

  @override
  List<Object?> get props => [
    totalReturn, annualizedReturn, volatility, sharpeRatio, sortinoRatio,
    maxDrawdown, alpha, beta, cagr, calmar, correlation, trackingError,
    trackingDiff, expenseRatio, bidAskSpread, concentration, dividendYield
  ];
}

class EquityCurvePoint extends Equatable {
  final DateTime timestamp;
  final double portfolioValue;
  final double drawdown;

  const EquityCurvePoint({
    required this.timestamp,
    required this.portfolioValue,
    this.drawdown = 0.0,
  });

  EquityCurvePoint copyWith({DateTime? timestamp, double? portfolioValue, double? drawdown}) {
    return EquityCurvePoint(
      timestamp: timestamp ?? this.timestamp,
      portfolioValue: portfolioValue ?? this.portfolioValue,
      drawdown: drawdown ?? this.drawdown);
  }

  @override
  List<Object?> get props => [timestamp, portfolioValue, drawdown];
}

class PortfolioResult extends Equatable {
  final PortfolioConfig portfolioConfig;
  final PerformanceMetrics performanceMetrics;
  final List<EquityCurvePoint> equityCurve;
  final DateTime calculatedAt;

  const PortfolioResult({
    required this.portfolioConfig,
    required this.performanceMetrics,
    required this.equityCurve,
    required this.calculatedAt,
  });

  @override
  List<Object?> get props => [
    portfolioConfig,
    performanceMetrics,
    equityCurve,
    calculatedAt,
  ];
}