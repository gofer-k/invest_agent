
import 'package:equatable/equatable.dart';
import 'package:invest_agent/model/portfolio_schema.dart';

typedef PortfolioId = int;
typedef PortfolioResultMap = Map<PortfolioId, PortfolioResult>;

enum PerformanceMetricsType {
  totalReturn(name: "Total return",
    description:
      "To find the total return percentage, you account for both growth "
      "and payouts relative to your starting cost: \n"
      r'Tot_ret =  \frac{(End_val - Start_val) - income received}{Start_val}'),
  annualizedReturn(name: "Annualized return",
    description:
      "Annualized return is the total return of the investment "
      "and the exact number of years it was held:\n"
      r'Ann_ret = \frac{Tot_ret}{years}'),
  volatility(name: "Volatility",
    description:
      "Volatility measures how much, and how fast, the price of an asset or"
      "a portfolio fluctuates over time. In simple terms, "
      "it is a measurement of market turbulence and price uncertainty."
      "High volatility means the price shoots up and down rapidly over short periods,"
      "making it harder to predict the future value."
      "Low volatility means the price changes gradually and stays relatively stable."),
  sharpeRatio(name: "Sharpe ratio",
    description:
      "Measures risk-adjusted returns. It shows how much excess return you receive "
      "for the extra volatility endured by holding a riskier asset."
      "A higher Sharpe Ratio indicates better risk-adjusted performance."
  ),
  sortinoRatio(name: "Sortino ratio",
    description:
      "A variation of the Sharpe Ratio that penalizes only downside volatility,"
      "or negative returns. This makes it more suitable for investors "
      "who are primarily concerned with minimizing losses rather than total volatility."),
  maxDrawdown(name: "Max drawdown (MDD)",
    description:
      "The largest percentage loss from a portfolio’s peak to its trough "
      "during a specific time period."
      "It is a crucial metric for understanding potential downside risks.'n"
      r'MDD = \frac{Peak - trough}{Peak}'
  ),
  alpha(name: "Alpha", description: "Alpha of the portfolio. Explain this later!!"),
  beta(name: "Beta",
    description:
      "Portfolio Beta measures the sensitivity"
      "to the movements of the overall market."
      "A beta greater than 1 indicates higher volatility compared to the market,"
      "while a beta less than 1 indicates lower volatility.\n"
      r'Beta = \frac{Cov(R_p, R_m)}{Var(R_m)}'),
  cagr(name: "Compound Annual Growth Rate (CAGR)",
    description:
      "It represents the smoothed annual rate at which an investment grows, "
      "assuming it grew at a steady rate over a specified time period "
      "with all profits reinvested.\n"
      r'(\frac{End_val}{Beg_val})^(|frac{1}{years}|) - 1'),
  calmar(name: "Calmar",
    description:
      "Compilation the portfolio’s annualized return to its maximum drawdown,"
      "making it useful for evaluating portfolios with significant risk exposure."),
  correlation(name: "Correlation", description: "Measures how two investments move in relation to one another."),
  trackingError(name: "Tracking error",
    description:
      "A measure how closely a portfolio’s returns follow "
      "the returns of a benchmark index. A lower tracking error indicates "
      "closer alignment with the benchmark."),
  trackingDiff(name: "Tracking diff", description: "Tracking diff: Explain this later!!"),
  expenseRatio(name: "Expense ratio",
    description:
      "An expense ratio is the annual fee that a mutual fund or ETF charges "
      "its investors to cover its operational and administrative costs"),
  concentration(name: "Concentration",
    description:
      "Measures how heavily your portfolio's value relies on "
      "a small number of individual investments, sectors, or geographic regions."),
  dividendYield(name: "Dividend yield",
    description:
      "Shows how much a company pays out in dividends each year"
      " relative to its current stock price.\n"
      r'Dividend yield = \frac{Annual dividend per share}{Stock price}');

  final String name;
  final String description;
  const PerformanceMetricsType({required this.name, required this.description});

  @override
  String toString() => name;
}

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