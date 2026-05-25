import 'dart:convert';
import 'dart:developer';

import 'package:invest_agent/model/cache_schema.dart';
import 'package:sealed_currencies/sealed_currencies.dart';

enum StockExchange {
  lSe("XLON", ".L"),
  xEtra("XETR", ".DE"),
  xWar("XWAR", ".WA");

  const StockExchange(this.code, this.suffix);

  @override
  String toString() => code;

  String toSuffix() => suffix;

  final String code;
  final String suffix;
}

class AssetConfigSchema implements CacheSchema
{
  static const String cacheName = "metadata";
  static const String cacheSequenceName = "metadata_id_sequence";

  @override
  String get create =>
  '''
      CREATE TABLE IF NOT EXISTS $cacheName (
        id INTEGER PRIMARY KEY DEFAULT nextval('$cacheSequenceName'),
        symbol TEXT NOT NULL,
        exchange VARCHAR,
        currency VARCHAR,
        symbol_suffix VARCHAR,
        links TEXT
      );
    ''';

  @override
  String get createKey => "CREATE SEQUENCE IF NOT EXISTS $cacheSequenceName START 1;";

  @override
  String get deleteAll => "DELETE FROM $cacheName;";

  @override
  String deleteOne(Cache cache) => "DELETE FROM $cacheName WHERE id = ${(cache as AssetConfig).id};";

  @override
  String get readAll => "SELECT * FROM $cacheName ORDER BY id DESC;";

  @override
  String readOne(Cache cache) => "SELECT * FROM $cacheName WHERE id = ${(cache as AssetConfig).id};";

  @override
  String saveOne(Cache cache) {
    final assetConfig = cache as AssetConfig;
    final linksJson = jsonEncode(assetConfig.links.map((e) => e.toString()).toList());
    return '''
      INSERT INTO $cacheName 
      VALUES (
     nextval('$cacheSequenceName'),      
     '${assetConfig.symbol}',
     '${assetConfig.stockExchange.code}',
     '${assetConfig.currency.code}',
     '${assetConfig.stockExchange.suffix}',
     '$linksJson' 
      );
    ''';
  }

  @override
  String updateOne(Cache cache) {
    final assetConfig = cache as AssetConfig;
    final linksJson = jsonEncode(assetConfig.links.map((e) => e.toString()).toList());
    return '''
      UPDATE $cacheName
      SET symbol = '${assetConfig.symbol}',
          exchange = '${assetConfig.stockExchange.code}',
          currency = '${assetConfig.currency.code}',
          symbol_suffix = '${assetConfig.stockExchange.suffix}',
          links = '$linksJson'
      WHERE id = ${assetConfig.id};
      ''';
  }
}

typedef AssetsByExchange = Map<String, List<AssetConfig>>;

class AssetConfig extends Cache{
  final int id;
  final String symbol;
  final FiatCurrency currency;
  final StockExchange stockExchange;
  final List<Uri> links;

  static StockExchange? _stockExchangeFromString(String stockSymbol, String stockSuffix) {
    try {
      return StockExchange.values.firstWhere((e) =>
      e.code == stockSymbol && e.suffix == stockSuffix);
    } catch (e) {
      return null; // Return null if no match is found
    }
  }
  
  static List<Uri>? _linksFromJson(Object? jsonLinks) {
    if (jsonLinks == null) return null;
    try {
      final decoded = jsonLinks is String ? jsonDecode(jsonLinks) : jsonLinks;
      final List<dynamic> list;

      if (decoded is Map && decoded.containsKey('urls')) {
        list = decoded['urls'] as List<dynamic>;
      } else if (decoded is List) {
        list = decoded;
      } else {
        return null;
      }

      return list.map((e) => Uri.tryParse(e.toString()))
          .whereType<Uri>().toList();
    }
    catch (e){
      log("Invalid asset's links format: $e");
    }
    return null;
  }

  static Map<String, dynamic> _toJsonLinks(List<Uri> links) {
    return {'urls': links.map((e) => e.toString()).toList()};
  }

  AssetConfig({
    required this.id,
    required this.symbol,
    required this.currency,
    required this.stockExchange,
    this.links = const [],
  }) : super.from([]);

  static AssetConfig defaultAsset() => 
    AssetConfig(id: -1, 
      symbol: 'no symbol',
      currency: FiatCurrency.pln(),
      stockExchange: StockExchange.xWar,
      links: []);

  bool isDefault() => id == -1;

  AssetConfig copyWith(int? id, String? symbol, FiatCurrency? currency, StockExchange? stock, List<Uri>? links) {
    return AssetConfig(
      id: id ?? this.id,
      symbol: symbol ?? this.symbol,
      currency: currency ?? this.currency,
      stockExchange: stock ?? stockExchange,
      links: links ?? this.links,
    );
  }

  factory AssetConfig.of({required int id}) {
    return AssetConfig(id: id, symbol: '', currency: FiatCurrency.pln(), stockExchange: StockExchange.xWar, links: []);
  }

  @override
  String toString() => symbol;

  @override
  factory AssetConfig.from(List<Object?> item) {
    if (item.length < 6) {
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
    
    final links = _linksFromJson(item[5]);

    return AssetConfig(
        id: item[0] as int,
        symbol: item[1] as String,
        currency: currency,
        stockExchange: stockExchange,
        links: links ?? []);
  }

  @override
  Map<String, dynamic> toMap() => {
    'id': id,
    'symbol': symbol,
    'exchange': stockExchange.code,
    'currency': currency.code,
    'symbol_suffix': stockExchange.suffix,
    'links': AssetConfig._toJsonLinks(links)
  };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AssetConfig &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          symbol == other.symbol;

  @override
  int get hashCode => id.hashCode ^ symbol.hashCode;

}
