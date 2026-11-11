import 'package:equatable/equatable.dart';
import 'package:invest_agent/model/portfolio_schema.dart';

typedef PortfolioId = int;
typedef PortfolioResultMap = Map<PortfolioId, PortfolioResult>;

enum PerformanceMetricsType {
  totalReturn(name: "Total return",
    description:
      r'\begin{aligned} '
      r'&\text{To find the total return percentage, you account for both growth} \\ '
      r'&\text{and payouts relative to your starting cost:} \\ '
      r'&Tot_{ret} = \frac{(End_{val} - Start_{val}) - \text{income received}}{Start_{val}} '
      r'\end{aligned}'),
  annualizedReturn(name: "Annualized return",
    description:
      r'\begin{aligned} '
      r'&\text{Annualized return is the total return of the investment} \\ '
      r'&\text{and the exact number of years it was held:} \\ '
      r'&Ann_{ret} = \frac{Tot_{ret}}{years} '
      r'\end{aligned}'),
  volatility(name: "Volatility",
    description:
      "Volatility measures how much, and how fast, "
      "the price of an asset or a portfolio"
      "fluctuates over time. In simple terms,"
      "it is a measurement of market turbulence"
      "and price uncertainty."
      "High volatility means the price shoots up"
      "and down rapidly over short periods,"
      "making it harder to predict the future value."),
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
      r'\begin{aligned} '
      r'&\text{The largest percentage loss from a portfolio’s peak to its trough} \\ '
      r'&\text{during a specific time period. It is a crucial metric for} \\ '
      r'&\text{understanding potential downside risks.} \\ '
      r'&MDD = \frac{Peak - trough}{Peak} '
      r'\end{aligned}'
  ),
  alpha(name: "Alpha", description: "Alpha of the portfolio. Explain this later!!"),
  beta(name: "Beta",
    description:
      r'\begin{aligned} '
      r'&\text{Portfolio Beta measures the sensitivity to the movements of the} \\ '
      r'&\text{overall market. A beta > 1 indicates higher volatility compared} \\ '
      r'&\text{to the market.} \\ '
      r'&Beta = \frac{Cov(R_p, R_m)}{Var(R_m)} '
      r'\end{aligned}'),
  cagr(name: "Compound Annual Growth Rate (CAGR)",
    description:
      r'\begin{aligned} '
      r'&\text{It represents the smoothed annual rate at which an investment grows,} \\ '
      r'&\text{assuming it grew at a steady rate over a specified time period} \\ '
      r'&\text{with all profits reinvested.} \\ '
      r'&\left(\frac{End_{val}}{Beg_{val}}\right)^{\frac{1}{years}} - 1 '
      r'\end{aligned}'),
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
      r'\begin{aligned} '
      r'&\text{Shows how much a company pays out in dividends each year} \\ '
      r'&\text{relative to its current stock price.} \\ '
      r'&\text{Dividend yield} = \frac{\text{Annual dividend per share}}{\text{Stock price}} '
      r'\end{aligned}');

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
