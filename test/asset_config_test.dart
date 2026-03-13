import 'package:test/test.dart';
import 'package:sealed_currencies/sealed_currencies.dart';
import 'package:invest_agent/model/asset_config.dart';

void main() {
  group('AssetConfig Tests', () {
    final testCurrency = FiatEur();
    const testExchange = StockExchange.XETRA;
    const testSymbol = "SAP";

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
      expect(config.stockExchange, StockExchange.LSE);
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
        stockExchange: StockExchange.XETRA,
      );

      final map = config.toMap();

      expect(map['symbol'], "BMW");
      expect(map['exchange'], "XETR");
      expect(map['currency'], "EUR");
      expect(map['symbol_suffix'], ".DE");
    });

    group('SQL String Generation', () {
      final config = AssetConfig(
        id: 99,
        symbol: "PKN",
        currency: FiatPln(),
        stockExchange: StockExchange.XWAR,
      );

      test('create() contains correct table name and columns', () {
        final sql = AssetConfig.create();
        expect(sql, contains("CREATE TABLE IF NOT EXISTS metadata"));
        expect(sql, contains("symbol TEXT NOT NULL"));
        expect(sql, contains("symbol_suffix VARCHAR"));
      });

      test('readOne() uses correct ID', () {
        expect(config.readOne(), contains("WHERE id = 99"));
      });

      test('deleteOne() uses correct ID', () {
        expect(config.deleteOne(), contains("WHERE id = 99"));
      });

      test('updateOne() returns null if ID is missing', () {
        final newConfig = AssetConfig(
          symbol: "NEW",
          currency: FiatUsd(),
          stockExchange: StockExchange.LSE,
        );
        expect(newConfig.updateOne(), isNull);
      });

      test('updateOne() generates valid SQL when ID is present', () {
        final sql = config.updateOne();
        expect(sql, contains("UPDATE metadata"));
        expect(sql, contains("SET symbol = 'PKN'"));
        expect(sql, contains("WHERE id = 99"));
      });
    });
  });
}