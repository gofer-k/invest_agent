import 'dart:convert';
import 'dart:developer' as dev;
import 'dart:io';
import 'package:flutter/cupertino.dart';
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

@immutable
class InvestingDataClientState {
  final RemoteRequest endPoint;
  final int? endPointPort;
  final Process? analysisProcess;

  const InvestingDataClientState({
    required this.endPoint, this.endPointPort, this.analysisProcess});

  InvestingDataClientState copyWith({
    RemoteRequest? endPoint,
    int? endPointPort,
    Process? analysisProcess}) {
    return InvestingDataClientState(
      endPoint: endPoint ?? this.endPoint,
      endPointPort: endPointPort ?? this.endPointPort,
      analysisProcess: analysisProcess ?? this.analysisProcess,
    );
  }
}

@riverpod
class InvestingDataClient extends _$InvestingDataClient {
  late http.Client _httpClient;
  static const int invalidPort = -1;
  static const String pythonPath = 'analysis_service.py';

  @override
  Future<InvestingDataClientState> build(RemoteRequest endPoint) async {
    _httpClient = http.Client();

    // The provider will stay alive even if no one is watching it,
    // until we manually let it go or the container is disposed.
    final link = ref.keepAlive();

    ref.onDispose(() {
      state.whenData((s) => s.analysisProcess?.kill());
      // Cancelable an operation
      dev.log('Cancelling HTTP request');
      _httpClient.close();
      link.close();
    });

    if (endPoint.resource == ResourceUri.localHost) {
      int port = await _findFreePort();
      final process = await Process.start(pythonPath, ['--port', '$port']);

      final ready = await _isServiceReady(port);
      if (!ready) {
        process.kill();
        throw RemoteDataException("Analysis service failed to start on port $port");
      }
      return InvestingDataClientState(
          endPoint: endPoint,
          endPointPort: port,
          analysisProcess: process);
    }
    return InvestingDataClientState(endPoint: endPoint);
  }

  Future<int> _findFreePort() async {
    if (endPoint.resource != ResourceUri.localHost) return invalidPort;
    final socket = await ServerSocket.bind(endPoint, 0);
    final port = socket.port;
    await socket.close();
    return port;
  }

  Future<bool> _isServiceReady(int port) async {
    for (int i = 0; i < 10; i++) {
      try {
        final response = await http.get(Uri.parse('$endPoint:$port/health'));
        if (response.statusCode == 200) return true;
      } catch (_) {}
      await Future.delayed(Duration(milliseconds: 500));
    }
    return false;
  }

  Future<Map<String, dynamic>> runAnalysis(AnalysisRequest request) async {
    try {
      final response = await _httpClient.post(
        endPoint.uri,
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
        endPoint.uri,
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
    final httpRequest = http.Request('POST', endPoint.uri)
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
        endPoint.uri,
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
