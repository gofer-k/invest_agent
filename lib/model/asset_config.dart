import 'package:invest_agent/model/cache.dart';
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

class AssetConfig implements Cache{
  final int? id;
  final String symbol;
  final FiatCurrency currency;
  final StockExchange stockExchange;

  static const String cacheName = "metadata";

  AssetConfig({
    this.id,
    required this.symbol,
    required this.currency,
    required this.stockExchange,
  });

  @override
  String create() {
    return '''
      CREATE TABLE IF NOT EXISTS $cacheName (
        id INTEGER PRIMARY KEY DEFAULT nextval('metadata_id_sequence'),
        symbol TEXT NOT NULL,
        exchange VARCHAR,
        currency VARCHAR,
        symbol_suffix VARCHAR,
        UNIQUE(id, symbol));
    ''';
  }

  @override
  String createKey() {
    return "CREATE SEQUENCE IF NOT EXISTS metadata_id_sequence START 1;";
  }

  @override
  String deleteAll() {
    return "DELETE FROM $cacheName;";
  }

  @override
  String deleteOne() {
    return "DELETE FROM $cacheName WHERE id = $id;";
  }

  @override
  String readAll() {
    return "SELECT * FROM $cacheName ORDER BY id DESC;";
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
      ${currency.code},
      ${stockExchange.code},
      );
      ''';
  }

  @override
  Map<String, dynamic> toMap() => {
    'symbol': symbol,
    'exchange': stockExchange.code,
    'currency': currency.code,
    'symbol_suffix': stockExchange.suffix,
  };

  @override
  String? updateOne() {
    if (id == null) return null;
    return '''
      UPDATE $cacheName
      SET symbol = '$symbol',
          exchange = ${stockExchange.code},
          currency = ${currency.code},
          symbol_suffix = ${stockExchange.suffix}
      WHERE id = $id;
      ''';
  }
}