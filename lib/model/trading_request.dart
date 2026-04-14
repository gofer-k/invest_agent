import 'dart:developer';

enum ResourceUri {
  marketStack("MarketStack", "http://api.marketstack.com/v2/", false),
  binance("Binance", "https://accounts.binance.com/", false),
  localHost("LocalHost", "http://127.0.0.1:8000/", true);

  final String name;
  final String baseUrl;
  final bool isLocal;
  const ResourceUri(this.name, this.baseUrl, this.isLocal);

  static ResourceUri? fromString(String? providerName) {
    return ResourceUri.values.cast<ResourceUri?>().firstWhere(
          (e) => e?.name == providerName,
      orElse: () => null,
    );
  }
}

abstract class RemoteRequest {
  ResourceUri get resource;
  Uri get uri;
  
  @override
  bool operator ==(Object other) =>
    identical(this, other) ||
    other is RemoteRequest &&
      runtimeType == other.runtimeType && resource == other.resource;
  
  @override
  int get hashCode => resource.hashCode ^ resource.hashCode;
}

enum MarketStackType {
  eod("eod"),
  intraday("intraday"),
  tickers("tickers"),
  exchanges("exchanges"),
  currencies("currencies"),
  timezones("timezones");

  const MarketStackType(this.path);
  final String path;
}

class MarketStackRequest extends RemoteRequest {
  @override
  ResourceUri get resource => ResourceUri.marketStack;
  
  final MarketStackType type;
  final String? apiKey;
  final DateTime? fromDate;
  final DateTime? toDate;
  final String? exchange;
  final List<String>? symbols;
  final int? limit;
  final int? offset;

  final Map<String, String>? params;

  MarketStackRequest({
    required this.type,
    this.params,
    this.apiKey,
    this.fromDate,
    this.toDate,
    this.symbols,
    this.limit,
    this.offset,
    this.exchange});

  factory MarketStackRequest.fromEod({
    required String apiKey,
    required DateTime fromDate,
    required List<String> symbols,
    required String? exchange,
    DateTime? toDate,
    int? limit, int? offset}) {
    return MarketStackRequest(
      type: MarketStackType.eod,
      apiKey: apiKey,
      fromDate: fromDate,
      toDate: toDate ?? DateTime.now(),
      exchange: exchange,
      symbols: symbols,
      limit: limit,
      offset: offset,
    );
  }

  @override
  Uri get uri {
    final sw = Stopwatch()..start();
    try {
      final queryParams = <String, String>{
        'access_key': apiKey!,
        if (fromDate != null) 'date_from': _formatDate(fromDate!),
        if (toDate != null) 'date_to': _formatDate(toDate!),
        if (exchange != null) 'exchange': ?exchange,
        if (symbols != null && symbols!.isNotEmpty) 'symbols': symbols!.join(','),
        if (limit != null) 'limit': limit.toString(),
        if (offset != null) 'offset': offset.toString(),
        ...?params,
      };

      final baseUri = Uri.parse(resource.baseUrl);
      return baseUri.replace(
        path: '${baseUri.path}${type.path}',
        queryParameters: queryParams,
      );
    } finally {
      sw.stop();
      if (sw.elapsedMilliseconds > 150) {
        log('get uri for $type took ${sw.elapsedMicroseconds}us', name: 'performance');
      }
    }
  }

  @override
  bool operator ==(Object other) =>
    identical(this, other) ||
    super == other &&
    other is MarketStackRequest &&
      type == other.type &&
      apiKey == other.apiKey &&
      fromDate == other.fromDate &&
      toDate == other.toDate &&
      exchange == other.exchange &&
      (
          symbols == other.symbols
          || (symbols != null && other.symbols != null
           && symbols!.length == other.symbols!.length
           && symbols!.every((s) => other.symbols!.contains(s))
          )
      );

  @override
  int get hashCode =>
    super.hashCode ^ type.hashCode ^ apiKey.hashCode ^ fromDate.hashCode ^
    toDate.hashCode ^ exchange.hashCode ^ (symbols?.length ?? 0);

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
  final String symbolSuffix;
  final String exchange;
  final String currency;
  final double? dividend;

  MarketStackRespond({
    required this.type, required this.open, required this.high,
    required this.low, required this.close, required this.volume,
    required this.timestamp, required this.symbol,
    required this.symbolSuffix, required this.exchange,
    required this.currency, required this.dividend
  });

  factory MarketStackRespond.fromEod(Map<String, dynamic> json) {
    final sw = Stopwatch()..start();
    try {
      final symbolStr = json['symbol'] as String;
      final dotIndex = symbolStr.indexOf('.');

      final (symbol, suffix) = dotIndex == -1
          ? (symbolStr, "")
          : (symbolStr.substring(0, dotIndex), symbolStr.substring(dotIndex + 1));

      return MarketStackRespond(
        type: MarketStackType.eod,
        open: (json['open'] as num).toDouble(),
        high: (json['high'] as num).toDouble(),
        low: (json['low'] as num).toDouble(),
        close: (json['close'] as num).toDouble(),
        volume: (json['volume'] as num).toDouble(),
        timestamp: DateTime.parse(json['date'] as String),
        symbol: symbol,
        symbolSuffix: suffix,
        exchange: json['exchange'] as String,
        currency: json['price_currency'] as String,
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

class MarketStackManagerRespond {
  final List<MarketStackRespond> data;
  final int count;
  final int offset;
  final int limit;
  final int total;

  MarketStackManagerRespond({
    required this.data,
    required this.count,
    required this.offset,
    required this.limit,
    required this.total
  });

  factory MarketStackManagerRespond.fromEod(Map<String, dynamic> json){
    final sw = Stopwatch()..start();
    try {
      return MarketStackManagerRespond(
          data: (json['data'] as List<dynamic>)
              .cast<Map<String, dynamic>>()
              .map((e) => MarketStackRespond.fromEod(e))
              .toList(),
          count: json['count'] as int,
          offset: json['offset'] as int,
          limit: json['limit'] as int,
          total: json['total'] as int);
    }
    finally {
      sw.stop();
      if (sw.elapsedMilliseconds > 500) {
        log(
            'MarketStackManagerRespond.fromEod took ${sw.elapsedMicroseconds}us',
            name: 'performance generating MarketStackManagerRespond');
      }
    }
  }
}

class LocalRequest extends RemoteRequest {
  LocalRequest();

  @override
  ResourceUri get resource => ResourceUri.localHost;

  @override
  Uri get uri => Uri.parse(resource.baseUrl);
}
