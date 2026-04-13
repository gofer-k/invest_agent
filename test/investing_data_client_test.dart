import 'dart:convert';
import 'dart:developer';
import 'dart:ffi';
import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:invest_agent/model/trading_request.dart';
import 'package:invest_agent/providers/investing_data_client.dart';

void main() {
  setUpAll(() {
    try {
      // DUCKDB_PATH="/home/chris/.pub-cache/hosted/pub.dev/dart_duckdb-1.4.4/linux/Libraries/release";
      final ldPath = Platform.environment['DUCKDB_PATH'];
      bool loaded = false;
      if (ldPath != null) {
        // Split by ':' on Linux/macOS
        for (final path in ldPath.split(':')) {
          final file = File('$path/libduckdb.so');
          if (file.existsSync()) {
            DynamicLibrary.open(file.path);
            loaded = true;
            break;
          }
        }
      }
      if (!loaded) {
        // Fallback: Try to let the system find it in standard paths.
        // Even if Platform.environment['LD_LIBRARY_PATH'] is null,
        // the OS loader might still have access to it if it was inherited.
        final homePath = Platform.environment['HOME'];
        DynamicLibrary.open('$homePath/.pub-cache/hosted/pub.dev/dart_duckdb-1.4.4/linux/Libraries/release/libduckdb.so');
      }
    } catch (e) {
      log('Library load info: $e');
      exit(-1);
    }
  });

  group('InvestingDataClient Test', () {
    test('simulate fetch MarketStack data using InvestingDataClient', () async {
      final mockJsonResponse = {
        "pagination": {
          "limit": 100,
          "offset": 0,
          "count": 1,
          "total": 1
        },
        "data": [
          {
            "open": 150.0,
            "high": 155.0,
            "low": 149.0,
            "close": 152.0,
            "volume": 1000000.0,
            "symbol": "AAPL.XNAS",
            "exchange": "XNAS",
            "price_currency": "USD",
            "date": "2023-10-27T00:00:00+0000",
            "dividend": 0.5
          }
        ],
        "count": 1,
        "offset": 0,
        "limit": 100,
        "total": 1
      };

      MockClient((request) async {
        return http.Response(jsonEncode(mockJsonResponse), 200);
      });

      final request = MarketStackRequest.fromEod(
        apiKey: 'test_key',
        fromDate: DateTime(2023, 10, 27),
        symbols: ['AAPL'],
        exchange: 'XNAS',
      );

      final container = ProviderContainer(
        overrides: [
        ],
      );
      addTearDown(container.dispose);

      container.read(investingDataClientProvider(request).notifier);

      final List<Map<String, dynamic>> dataList = [mockJsonResponse]; // Simulating response body

      final marketStackResponse = MarketStackManagerRespond.fromEod(dataList.first);

      expect(marketStackResponse.data.length, 1);
      final item = marketStackResponse.data.first;
      expect(item.symbol, "AAPL");
      expect(item.symbolSuffix, "XNAS");
      expect(item.close, 152.0);
    });
  });
}
