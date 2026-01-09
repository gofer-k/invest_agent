class AnalysisRespond {
  const AnalysisRespond();

  factory AnalysisRespond.fromJson(Map<String, dynamic> json) {
    double? parseNum(dynamic value) {
      if (value == null || value == 'null' || value == 'NaN') return null;
      final cleaned = value.toString().replaceAll(RegExp(r'JS:\d+'), '');
      return double.tryParse(cleaned);
    }

    return AnalysisRespond(
      // open: parseNum(json['Open']),
      // high: parseNum(json['High']),
      // low: parseNum(json['Low']),
      // close: parseNum(json['Close']),
      // volume: int.tryParse(json['Volume'].toString()),
      // return_: parseNum(json['return']),
      // rollingMean: parseNum(json['rolling_mean']),
      // rollingStd: parseNum(json['rolling_std']),
      // volatility: parseNum(json['volatility']),
      // maxDrawdown: parseNum(json['max_drawdown']),
      // priceAboveMa: int.tryParse(json['price_above_ma'].toString()),
      // sma: {
      //   'SMA20': parseNum(json['SMA20']),
      //   'SMA50': parseNum(json['SMA50']),
      //   'SMA100': parseNum(json['SMA100']),
      //   'SMA150': parseNum(json['SMA150']),
      //   'SMA200': parseNum(json['SMA200']),
      //   'SMA250': parseNum(json['SMA250']),
      // },
      // rollingStdMap: {
      //   'rolling_std20': parseNum(json['rolling_std20']),
      //   'rolling_std50': parseNum(json['rolling_std50']),
      //   'rolling_std100': parseNum(json['rolling_std100']),
      //   'rolling_std150': parseNum(json['rolling_std150']),
      //   'rolling_std200': parseNum(json['rolling_std200']),
      //   'rolling_std250': parseNum(json['rolling_std250']),
      // },
      // bbUpper: {
      //   'BB_upper20': parseNum(json['BB_upper20']),
      //   'BB_upper50': parseNum(json['BB_upper50']),
      //   'BB_upper100': parseNum(json['BB_upper100']),
      //   'BB_upper150': parseNum(json['BB_upper150']),
      //   'BB_upper200': parseNum(json['BB_upper200']),
      //   'BB_upper250': parseNum(json['BB_upper250']),
      // },
      // bbLower: {
      //   'BB_lower20': parseNum(json['BB_lower20']),
      //   'BB_lower50': parseNum(json['BB_lower50']),
      //   'BB_lower100': parseNum(json['BB_lower100']),
      //   'BB_lower150': parseNum(json['BB_lower150']),
      //   'BB_lower200': parseNum(json['BB_lower200']),
      //   'BB_lower250': parseNum(json['BB_lower250']),
      // },
      // bbWidth: {
      //   'BB_width20': parseNum(json['BB_width20']),
      //   'BB_width50': parseNum(json['BB_width50']),
      //   'BB_width100': parseNum(json['BB_width100']),
      //   'BB_width150': parseNum(json['BB_width150']),
      //   'BB_width200': parseNum(json['BB_width200']),
      //   'BB_width250': parseNum(json['BB_width250']),
      // },
      // bbPercent: {
      //   'BB_percent20': parseNum(json['BB_percent20']),
      //   'BB_percent50': parseNum(json['BB_percent50']),
      //   'BB_percent100': parseNum(json['BB_percent100']),
      //   'BB_percent150': parseNum(json['BB_percent150']),
      //   'BB_percent200': parseNum(json['BB_percent200']),
      //   'BB_percent250': parseNum(json['BB_percent250']),
      // },
      // goldenCross: int.tryParse(json['golden_cross'].toString()),
      // deathCross: int.tryParse(json['death_cross'].toString()),
      // ema: {
      //   'EMA12': parseNum(json['EMA12']),
      //   'EMA26': parseNum(json['EMA26']),
      //   'EMA50': parseNum(json['EMA50']),
      //   'EMA200': parseNum(json['EMA200']),
      // },
      // macd: {
      //   'MACD_12_26': parseNum(json['MACD_12_26']),
      //   'MACD_signal_12_26': parseNum(json['MACD_signal_12_26']),
      //   'MACD_hist_12_26': parseNum(json['MACD_hist_12_26']),
      //   'MACD_50_200': parseNum(json['MACD_50_200']),
      //   'MACD_signal_50_200': parseNum(json['MACD_signal_50_200']),
      //   'MACD_hist_50_200': parseNum(json['MACD_hist_50_200']),
      // },
      // rsi: parseNum(json['RSI']),
    );
  }
}