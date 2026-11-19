import 'package:equatable/equatable.dart';
import 'package:invest_agent/model/portfolio_schema.dart';

typedef PortfolioId = int;
typedef PortfolioResultMap = Map<PortfolioId, PortfolioResult>;

enum PerformanceMetricsType {
  totalReturn(
    name: "Total return",
    description:
        r'\begin{aligned} '
        r'&\text{To find the total return percentage, you account for both growth} \\ '
        r'&\text{and payouts relative to your starting cost:} \\ '
        r'&Tot_{ret} = \frac{(End_{val} - Start_{val}) - \text{income received}}{Start_{val}} '
        r'\end{aligned}',
    range: 'variety [%]]',
  ),
  annualizedReturn(
    name: "Annualized return",
    description:
        r'\begin{aligned} '
        r'&\text{Annualized return is the total return of the investment} \\ '
        r'&\text{and the exact number of years it was held:} \\ '
        r'&Ann_{ret} = \frac{Tot_{ret}}{years} '
        r'\end{aligned}',
    range: 'variety [%]]',
  ),
  volatility(
    name: "Volatility",
    description:
        "Volatility measures how much, and how fast, "
        "the price of an asset or a portfolio"
        "fluctuates over time. In simple terms,"
        "it is a measurement of market turbulence"
        "and price uncertainty."
        "High volatility means the price shoots up"
        "and down rapidly over short periods,"
        "making it harder to predict the future value.",
    range: 'variety [%]]',
  ),
  sharpeRatio(
    name: "Sharpe ratio",
    description:
        "Measures risk-adjusted returns. It shows how much excess return you receive "
        "for the extra volatility endured by holding a riskier asset."
        "A higher Sharpe Ratio indicates better risk-adjusted performance.",
    range:
        r'\begin{aligned} '
        r'&\text{< 0: less risk free rate (RFR)} \\ '
        r'&\text{< 1.0: moderate profit} \\ '
        r'&\text{> 1.0: goodd profit} \\ '
        r'&\text{> 2.0: very good profit}'
        r'\end{aligned}',
  ),
  sortinoRatio(
    name: "Sortino ratio",
    description:
        "A variation of the Sharpe Ratio that penalizes only downside volatility,"
        "or negative returns. This makes it more suitable for investors "
        "who are primarily concerned with minimizing losses rather than total volatility.",
    range:
        r'\begin{aligned} '
        r'&\text{< 1: weak} \\ '
        r'&\text{1 < 2.0: solid} \\ '
        r'&\text{> 2.0: very good}'
        r'\end{aligned}',
  ),
  maxDrawdown(
    name: "Max drawdown",
    description:
        r'\begin{aligned} '
        r'&\text{The largest percentage loss from a portfolio’s peak to its trough} \\ '
        r'&\text{during a specific time period. It is a crucial metric for} \\ '
        r'&\text{understanding potential downside risks.} \\ '
        r'&MDD = \frac{Peak - trough}{Peak} \\'
        r'\end{aligned}',
    range: r'''
        \begin{aligned} 
        <10% fall: +11% profit \\
        <20% fall: +30% profit \\
        <50% fall: +100% profit \\
        \end{aligned}''',
  ),
  alpha(
    name: "Alpha",
    description:
        r'\begin{aligned} '
        r'&\text{Alpha is the excess return an investor } \\ '
        r'&\text{generates above what the market } \\ '
        r'&\text{itself would have provided for the same level of risk.} \\ '
        r'&\text{It represents the portion of performance that } \\ '
        r'&\text{cannot be explained by the general movement of the broader market.} \\ '
        r'\end{aligned}',
    range: "???",
  ),
  beta(
    name: "Beta",
    description:
        r'\begin{aligned} '
        r'&\text{Portfolio Beta measures the sensitivity to the movements of the} \\ '
        r'&\text{overall market. A beta > 1 indicates higher volatility compared} \\ '
        r'&\text{to the market.} \\ '
        r'&Beta = \frac{Cov(R_p, R_m)}{Var(R_m)} '
        r'\end{aligned}',
    range: "???",
  ),
  cagr(
    name: "CAGR",
    description:
        r'\begin{aligned} '
        r'&\text{It represents the smoothed annual rate at which an investment grows,} \\ '
        r'&\text{assuming it grew at a steady rate over a specified time period} \\ '
        r'&\text{with all profits reinvested.} \\ '
        r'&\left(\frac{End_{val}}{Beg_{val}}\right)^{\frac{1}{years}} - 1 '
        r'\end{aligned}',
    range: 'variety',
  ),
  calmar(
    name: "Calmar",
    description:
        "Compilation the portfolio’s annualized return to its maximum drawdown,"
        "making it useful for evaluating portfolios with significant risk exposure.",
    range:
        r'\begin{aligned} '
        r'&\text{<0: loss in the period} \\ '
        r'&\text{<1: downfalls risk in the period} \\ '
        r'&\text{1-3: solid profit the worst downfall} \\ '
        r'&\text{>3: very good ine mnimal downfall}'
        r'\end{aligned}',
  ),
  correlation(
    name: "Correlation",
    description:
        "Measures how two investments move in relation to one another.",
    range:
        '\begin{aligned} '
        r'&\text{<1.0: the assets no follow a trend} \\ '
        r'&\text{-0.99 - -0.3: loss part of portfolio and the other one otherwise} \\ '
        r'&\text{-0.29 - +0.29: assets are follow inpedentdly} \\ '
        r'&\text{+0.3 - +0.69: the most assets follow a trend high or low} \\ '
        r'&\text{+0.7 - +0.99: risk loss part of assets} \\ '
        r'&\text{+1.0: followed trend.No need to diversify assets} \\ '
        r'\end{aligned}',
  ),
  trackingError(
    name: "Tracking error",
    description:
        "A measure how closely a portfolio’s returns follow "
        "the returns of a benchmark index. A lower tracking error indicates "
        "closer alignment with the benchmark.",
    range:
        r'\begin{aligned} '
        r'&\text{+/- 0.0 [%]: the mimic the trend} \\ '
        r'&\text{2 - 5 [%]: the minor diviation of a trend} \\ '
        r'&\text{5 - 7 [%]: the major divation of trend}'
        r'\end{aligned}',
  ),
  trackingDiff(
    name: "Tracking diff",
    description: "Tracking diff: Explain this later!!",
    range:
        r'\begin{aligned} '
        r'&\text{<0.0: the less results against atrend} \\ '
        r'&\text{0 = a trend result} \\ '
        r'&\text{>0: The result better against trend}'
        r'\end{aligned}',
  ),
  expenseRatio(
    name: "Expense ratio",
    description:
        "An expense ratio is the annual fee that a mutual fund or ETF charges "
        "its investors to cover its operational and administrative costs",
    range: "-",
  ),
  concentration(
    name: "Concentration",
    description:
        "Measures how heavily your portfolio's value relies on "
        "a small number of individual investments, sectors, or geographic regions.",
    range: "variate",
  ),
  dividendYield(
    name: "Dividend yield",
    description:
        r'\begin{aligned} '
        r'&\text{Shows how much a company pays out in dividends each year} \\ '
        r'&\text{relative to its current stock price.} \\ '
        r'&\text{Dividend yield} = \frac{\text{Annual dividend per share}}{\text{Stock price}} '
        r'\end{aligned}',
    range: "variety [%]]",
  );

  final String name;
  final String description;
  final String range;

  const PerformanceMetricsType({
    required this.name,
    required this.description,
    required this.range,
  });

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
    double? dividendYield,
  }) {
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
      dividendYield: dividendYield ?? this.dividendYield,
    );
  }

  @override
  bool get stringify => true;

  @override
  List<Object?> get props => [
    totalReturn,
    annualizedReturn,
    volatility,
    sharpeRatio,
    sortinoRatio,
    maxDrawdown,
    alpha,
    beta,
    cagr,
    calmar,
    correlation,
    trackingError,
    trackingDiff,
    expenseRatio,
    bidAskSpread,
    concentration,
    dividendYield,
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

  EquityCurvePoint copyWith({
    DateTime? timestamp,
    double? portfolioValue,
    double? drawdown,
  }) {
    return EquityCurvePoint(
      timestamp: timestamp ?? this.timestamp,
      portfolioValue: portfolioValue ?? this.portfolioValue,
      drawdown: drawdown ?? this.drawdown,
    );
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
