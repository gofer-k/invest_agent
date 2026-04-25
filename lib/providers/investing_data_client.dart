import 'dart:convert';
import 'dart:developer' as dev;
import 'package:http/http.dart' as http;
import '../model/analysis_request.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../model/trading_request.dart';

part 'investing_data_client.g.dart';

class RemoteDataException implements Exception {
  final String message;
  final int? statusCode;
  final String? body;

  RemoteDataException(this.message, {this.statusCode, this.body});

  @override
  String toString() => 'RemoteDataException: $message (Status: $statusCode)';
}

@riverpod
class InvestingDataClient extends _$InvestingDataClient {
  late http.Client _httpClient;

  @override
  void build(RemoteRequest endpoint) {
    _httpClient = http.Client();

    // The provider will stay alive even if no one is watching it,
    // until we manually let it go or the container is disposed.
    final link = ref.keepAlive();
    ref.onDispose(() {
      // Cancelable an operation
      dev.log('Cancelling HTTP request');
      _httpClient.close();
      link.close();
    });
  }

  Future<Map<String, dynamic>> runAnalysis(AnalysisRequest request) async {
    try {
      final response = await _httpClient.post(
        endpoint.uri,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(request.toJson()),
      );
      return _handleResponse(response);
    } catch (e) {
      if (e is RemoteDataException) rethrow;
      throw RemoteDataException("Request failed: $e");
    }
  }

  Future<List<Map<String, dynamic>>> runBulkAnalysis(List<AnalysisRequest> requests) async {
    try {
      final response = await _httpClient.post(
        endpoint.uri,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(requests.map((r) => r.toJson()).toList()),
      );

      final decoded = _handleResponse(response);
      if (decoded is List) {
        return List<Map<String, dynamic>>.from(decoded);
      }
      throw RemoteDataException("Expected list response for bulk request");
    } catch (e) {
      if (e is RemoteDataException) rethrow;
      throw RemoteDataException("Bulk request failed: $e");
    }
  }

  Stream<Map<String, dynamic>> getAnalysisStream(AnalysisRequest request) async* {
    final httpRequest = http.Request('POST', endpoint.uri)
      ..headers['Content-Type'] = 'application/json'
      ..body = jsonEncode(request.toJson());

    try {
      final response = await _httpClient.send(httpRequest);
      if (response.statusCode != 200) {
        throw RemoteDataException(
          "Streaming failed",
          statusCode: response.statusCode,
        );
      }

      // 3. Process the stream line by line (NDJSON)
      yield* response.stream
          .transform(utf8.decoder)
          .transform(const LineSplitter())
          .where((line) => line.isNotEmpty)
          .map((line) => jsonDecode(line) as Map<String, dynamic>);
    } catch (e) {
      if (e is RemoteDataException) rethrow;
      throw RemoteDataException("Stream failed: $e");
    }
  }

  /// Fetches data for the current endpoint and returns the decoded JSON.
  Future<dynamic> getRequest() async {
    try {
      final response = await _httpClient.get(
        endpoint.uri,
        headers: {"Accept": "application/json"},
      );
      return _handleResponse(response);
      
      // Added await to make the delay effective
      // await Future.delayed(const Duration(seconds: 5));
      // return _handleResponse(http.Response('''
      // {
      // "pagination": {
      // "limit": 100,
      // "offset": 0,
      // "count": 1,
      // "total": 1
      // },
      //     "data": [
      //     {
      //     "open": 150.0,
      //     "high": 155.0,
      //     "low": 149.0,
      //     "close": 152.0,
      //     "volume": 1000000.0,
      //     "symbol": "AAPL.XNAS",
      //     "exchange": "XNAS",
      //     "price_currency": "USD",
      //     "date": "2023-10-27T00:00:00+0000",
      //     "dividend": 0.5
      //     }
      //     ],
      //     "count": 1,
      //     "offset": 0,
      //     "limit": 100,
      //     "total": 1
      // }''',
      //     200));
    } catch (e) {
      if (e is RemoteDataException) throw RemoteDataException("Request failed: $e");
      rethrow;
    }
  }

  dynamic _handleResponse(http.Response? response) {
    if (response == null) return null;

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return jsonDecode(response.body);
    } else {
      throw RemoteDataException(
        "API Request failed",
        statusCode: response.statusCode,
        body: response.body,
      );
    }
  }
}
