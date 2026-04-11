import 'dart:convert';
import 'package:http/http.dart' as http;
import '../model/analysis_request.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../model/trading_request.dart';

part 'investing_data_client.g.dart';

@riverpod
http.Client httpClient(Ref ref) {
  final client = http.Client();
  ref.onDispose(() => client.close());
  return client;
}

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
  @override
  void build(RemoteRequest endpoint) {
    // No initialization needed here if we use ref.watch(httpClientProvider)
  }

  http.Client get _httpClient => ref.read(httpClientProvider);

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
    } catch (e) {
      if (e is RemoteDataException) rethrow;
      throw RemoteDataException("Request failed: $e");
    }
  }

  dynamic _handleResponse(http.Response response) {
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
