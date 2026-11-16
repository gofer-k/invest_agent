import 'package:test/test.dart';
import 'package:sealed_currencies/sealed_currencies.dart';
import 'package:invest_agent/model/asset_config.dart';

void main() {

  group('AssetConfig Tests', () {
    final testCurrency = FiatEur();
    const testExchange = StockExchange.xEtra;
    const testSymbol = "SAP";
    final schema = AssetConfigSchema();

    test('should initialize correctly with constructor', () {
      final config = AssetConfig(
        id: 1,
        symbol: testSymbol,
        currency: testCurrency,
        stockExchange: testExchange,
      );

      expect(config.id, 1);
      expect(config.symbol, testSymbol);
      expect(config.currency, testCurrency);
      expect(config.stockExchange, testExchange);
    });

    test('from() factory should create instance from valid list', () {
      // Mocking DB row: [id, symbol, exchange_code, currency_code, suffix]
      final dbRow = [10, "VOD", "XLON", "GBP", ".L"];

      final config = AssetConfig.from(dbRow);

      expect(config.id, 10);
      expect(config.symbol, "VOD");
      expect(config.currency.code, "GBP");
      expect(config.stockExchange, StockExchange.lSe);
    });

    test('from() factory should throw exception on invalid currency', () {
      final invalidRow = [1, "ABC", "XLON", "INVALID", ".L"];
      expect(() => AssetConfig.from(invalidRow), throwsException);
    });

    test('from() factory should throw exception on unknown stock exchange', () {
      final unknownExchangeRow = [1, "ABC", "NYSE", "USD", ".US"];
      expect(() => AssetConfig.from(unknownExchangeRow), throwsException);
    });

    test('toMap() should return correct map representation', () {
      final config = AssetConfig(
        symbol: "BMW",
        currency: FiatEur(),
        stockExchange: StockExchange.xEtra, id: -1,
      );

      final map = config.toMap();

      expect(map['symbol'], "BMW");
      expect(map['exchange'], "XETR");
      expect(map['currency'], "EUR");
      expect(map['symbol_suffix'], ".DE");
    });

    group('SQL String Generation', () {
      test('create() contains correct table name and columns', () {
        final sql = schema.create;
        expect(sql, contains("CREATE TABLE IF NOT EXISTS ${AssetConfigSchema.cacheName}"));
        expect(sql, contains("symbol TEXT NOT NULL"));
        expect(sql, contains("symbol_suffix VARCHAR"));
      });

      test('readOne() uses correct ID', () {
        final item = AssetConfig(id: 1, symbol: "ABC", currency: FiatEur(),
            stockExchange: StockExchange.xEtra);
        expect(schema.readOne(item), contains("WHERE id = ${item.id}"));
      });

      test('deleteOne() uses correct ID', () {
        final item = AssetConfig(id: 99, symbol: "ABC", currency: FiatEur(),
            stockExchange: StockExchange.xEtra);
        expect(schema.deleteOne(item), contains("WHERE id = 99"));
      });

      test('updateOne() generates valid SQL when ID is present', () {
        final item = AssetConfig(id: 1, symbol: "ABC", currency: FiatEur(),
            stockExchange: StockExchange.xEtra);
        final sql = schema.updateOne(item);
        expect(sql, contains("UPDATE ${AssetConfigSchema.cacheName}"));
        expect(sql, contains("SET symbol = '${item.symbol}'"));
        expect(sql, contains("WHERE id = ${item.id}"));
      });
    });
  });
}