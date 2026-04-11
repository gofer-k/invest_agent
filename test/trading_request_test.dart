import 'package:test/test.dart';
import 'package:invest_agent/model/trading_request.dart';

void main() {
  group('MarketStackManagerRespond', () {
    test('fromEod should correctly parse JSON', () {
      final json = {
        "pagination": {
          "limit": 100,
          "offset": 0,
          "count": 1,
          "total": 1
        },
        "data": [
          {
            "open": 129.8,
            "high": 130.41,
            "low": 128.26,
            "close": 128.37,
            "volume": 42680200.0,
            "adj_high": 130.41,
            "adj_low": 128.26,
            "adj_close": 128.37,
            "adj_open": 129.8,
            "adj_volume": 42680200.0,
            "split_factor": 1.0,
            "dividend": 0.0,
            "symbol": "AAPL",
            "exchange": "IEXG",
            "price_currency":"USD",
            "name":"PlaceHold",
            "date": "2021-04-12T00:00:00+0000"
          },
          {
            "open":0.0,
            "high":0.0,
            "low":0.0,
            "close":0.0,
            "volume":12.0,
            "adj_high":null,
            "adj_low":null,
            "adj_close":0.0,
            "adj_open":null,
            "adj_volume":null,
            "split_factor":1.0,
            "dividend":0.0,
            "name":"Vanguard FTSE All-World UCITS ETF",
            "exchange_code":"LSE",
            "asset_type":null,
            "price_currency":"GBP",
            "symbol":"VWRA.L",
            "exchange":"XLON",
            "date":"2026-04-09T00:00:00+0000"
          }
        ],
        // Based on the implementation, it expects these at the top level
        "count": 1,
        "offset": 0,
        "limit": 100,
        "total": 1
      };

      final respond = MarketStackManagerRespond.fromEod(json);

      expect(respond.data.length, 2);
      expect(respond.count, 1);
      expect(respond.offset, 0);
      expect(respond.limit, 100);
      expect(respond.total, 1);
      {
        final item = respond.data.first;
        expect(item.type, MarketStackType.eod);
        expect(item.symbol, "AAPL");
        expect(item.open, 129.8);
        expect(item.high, 130.41);
        expect(item.low, 128.26);
        expect(item.close, 128.37);
        expect(item.volume, 42680200.0);
        expect(item.exchange, "IEXG");
        expect(item.currency, "USD");
        expect(item.dividend, 0.0);
        expect(item.timestamp, DateTime.parse("2021-04-12T00:00:00+0000"));
      }
      {
        final item = respond.data.last;
        expect(item.type, MarketStackType.eod);
        expect(item.symbol, "VWRA");
        expect(item.symbol_suffix, "L");
      }
    });

    test('fromEod should handle null dividend', () {
      final json = {
        "data": [
          {
            "open": 100.0,
            "high": 110.0,
            "low": 90.0,
            "close": 105.0,
            "volume": 1000.0,
            "symbol": "TSLA",
            "exchange": "XNAS",
            "date": "2023-10-27T00:00:00+0000",
            "price_currency": "USD",
            "dividend": null
          }
        ],
        "count": 1,
        "offset": 0,
        "limit": 10,
        "total": 1
      };

      final respond = MarketStackManagerRespond.fromEod(json);
      expect(respond.data.first.dividend, isNull);
    });
  });
}
