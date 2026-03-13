import 'package:invest_agent/model/cache_schema.dart';
import 'package:sealed_currencies/sealed_currencies.dart';

enum StockExchange {
  LSE("XLON", ".L"),
  XETRA("XETR", ".DE"),
  XWAR("xWAR", ".WA");

  const StockExchange(this.code, this.suffix);

  @override
  String toString() => code;

  String toSuffix() => suffix;

  final String code;
  final String suffix;
}

class AssetConfig extends CacheSchema{
  final int? id;
  final String symbol;
  final FiatCurrency currency;
  final StockExchange stockExchange;

  static const String cacheName = "metadata";
  static const String cacheSequenceName = "metadata_id_sequence";

  static StockExchange? _stockExchangeFromString(String stockSymbol, String stock_suffix) {
    try {
      return StockExchange.values.firstWhere((e) =>
      e.code == stockSymbol && e.suffix == stock_suffix);
    } catch (e) {
      return null; // Return null if no match is found
    }
  }

  AssetConfig({
    this.id,
    required this.symbol,
    required this.currency,
    required this.stockExchange,
  }) : super.from([]);

  @override
  factory AssetConfig.from(List<Object?> item) {
    if (item.length < 5) {
      throw Exception("Invalidate input data");
    }
    final dbCurrency = item[3] as String;
    final currency = FiatCurrency.maybeFromCode(dbCurrency.toUpperCase());
    if (currency == null) {
      throw Exception("Invalidate input currency: $dbCurrency. It must tbe compatible to ISO 4217 code");
    }
    final stockExchange = _stockExchangeFromString(item[2] as String, item[4] as String);
    if (stockExchange == null) {
      throw Exception("Invalidate input stock exchange: [${item[2]}, ${item[4]}]");
    }
    return AssetConfig(
        id: item[0] as int?,
        symbol: item[1] as String,
        currency: currency,
        stockExchange: stockExchange);
  }

  @override
  Map<String, dynamic> toMap() => {
    'symbol': symbol,
    'exchange': stockExchange.code,
    'currency': currency.code,
    'symbol_suffix': stockExchange.suffix,
  };

  static String create() {
    return '''
      CREATE TABLE IF NOT EXISTS $cacheName (
        id INTEGER PRIMARY KEY DEFAULT nextval('$cacheSequenceName'),
        symbol TEXT NOT NULL,
        exchange VARCHAR,
        currency VARCHAR,
        symbol_suffix VARCHAR,
        UNIQUE(id, symbol));
    ''';
  }

  static String createKey() {
    return "CREATE SEQUENCE IF NOT EXISTS $cacheSequenceName START 1;";
  }

  static String deleteAll() {
    return "DELETE FROM $cacheName;";
  }

  static String readAll() {
    return "SELECT * FROM $cacheName ORDER BY id DESC;";
  }

  @override
  String deleteOne() {
    return "DELETE FROM $cacheName WHERE id = $id;";
  }

  @override
  String readOne() {
    return "SELECT * FROM $cacheName WHERE id = $id;";
  }

  @override
  String saveOne() {
    return '''
      INSERT INTO $cacheName 
      VALUES (
     '$symbol',
      '${currency.code}',
      '${stockExchange.code}',
      );
      ''';
  }

  @override
  String? updateOne() {
    if (id == null) return null;
    return '''
      UPDATE $cacheName
      SET symbol = '$symbol',
          exchange = '${stockExchange.code}',
          currency = '${currency.code}',
          symbol_suffix = '${stockExchange.suffix}'
      WHERE id = $id;
      ''';
  }
}