import 'dart:developer';

enum MarketStackType {
  eod("eod"),
  intraday("intraday"),
  tickers("tickers"),
  exchanges("exchanges"),
  currencies("currencies"),
  timezones("timezones");

  const MarketStackType(this.type);
  final String type;
}

class MarketStackRequest {
  final MarketStackType type;
  final String? apiKey;
  final DateTime? fromDate;
  final DateTime? toDate;
  final List<String>? symbols;
  final int? limit;
  final int? offset;

  final Map<String, Object?>? params;

  MarketStackRequest({
    required this.type,
    this.params,
    this.apiKey,
    this.fromDate,
    this.toDate,
    this.symbols,
    this.limit,
    this.offset});

  factory MarketStackRequest.fromEod(String apiKey, DateTime fromDate, DateTime toDate, List<String> symbols, int limit, int offset) {
    return MarketStackRequest(
      type: MarketStackType.eod,
      apiKey: apiKey,
      fromDate: fromDate,
      toDate: toDate,
      symbols: symbols,
      limit: limit,
      offset: offset,
    );
  }

  String getUri() {
    final sw = Stopwatch()..start();
    try {
      switch (type) {
        case MarketStackType.eod:
          final buffer = StringBuffer('eod/?');
          buffer.write('access_key=$apiKey');
          buffer.write('&date_from=${_formatDate(fromDate!)}');
          buffer.write('&date_to=${_formatDate(toDate!)}');
          buffer.write('&symbols=${symbols!.join(',')}');
          buffer.write('&limit=$limit');
          buffer.write('&offset=$offset');
          return buffer.toString();
        case MarketStackType.intraday:
        case MarketStackType.tickers:
        case MarketStackType.exchanges:
        case MarketStackType.currencies:
        case MarketStackType.timezones:
        throw UnimplementedError('MarketStackType $type is not implemented yet.');
      }
    }
    finally {
      sw.stop();
      if (sw.elapsedMilliseconds > 150) {
        log('getUri for $type took ${sw.elapsedMicroseconds}us', name: 'performance generating URI');
      }
    }
  }

  String _formatDate(DateTime date) {
    // Optimization: Manual padding is often faster than DateFormat for simple cases.
    final y = date.year.toString();
    final m = date.month.toString().padLeft(2, '0');
    final d = date.day.toString().padLeft(2, '0');
    return '$y-$m-$d';
  }
}

class MarketStackRespond {
  final MarketStackType type;
  final double open;
  final double high;
  final double low;
  final double close;
  final double volume;
  final DateTime timestamp;
  final String symbol;
  final String exchange;
  final String currency;
  final double? dividend;

  MarketStackRespond({
    required this.type, required this.open, required this.high,
    required this.low, required this.close, required this.volume,
    required this.timestamp, required this.symbol, required this.exchange,
    required this.currency, required this.dividend
  });

  
  /*
  {
  "pagination": {
    "limit": 0,
    "offset": 0,
    "count": 0,
    "total": 0
  },
  "data": [
    {
      "open": 0,
      "high": 0,
      "low": 0,
      "close": 0,
      "volume": 0,
      "adj_high": 0,
      "adj_low": 0,
      "adj_close": 0,
      "adj_open": 0,
      "adj_volume": 0,
      "split_factor": 0,
      "dividend": 0,
      "name": "string",
      "exchange_code": "string",
      "asset_type": "string",
      "price_currency": "string",
      "symbol": "string",
      "exchange": "string",
      "date": "string"
    }
  ]
}
   */
  factory MarketStackRespond.fromEod(Map<String, dynamic> json) {
    final sw = Stopwatch()..start();
    try {
      return MarketStackRespond(
        type: MarketStackType.eod,
        open: (json['open'] as num).toDouble(),
        high: (json['high'] as num).toDouble(),
        low: (json['low'] as num).toDouble(),
        close: (json['close'] as num).toDouble(),
        volume: (json['volume'] as num).toDouble(),
        timestamp: DateTime.parse(json['date'] as String),
        symbol: json['symbol'] as String,
        exchange: json['exchange'] as String,
        currency: json['currency'] as String,
        dividend: json['dividend'] == null ? null : (json['dividend'] as num).toDouble(),
      );
    }
    finally {
      sw.stop();
      if (sw.elapsedMilliseconds > 500) {
        log('MarketStackRespond.fromEod took ${sw.elapsedMicroseconds}us', name: 'performance generating MarketStackRespond');
      }
    }
  }
}