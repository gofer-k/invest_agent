import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:invest_agent/model/user_account.dart';
import '../model/analysis_request.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

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
  late final http.Client _httpClient;

  @override
  void build(ResourceData resource, {String? apiKey}) {
    _httpClient = http.Client();
    // Automatically close the client and cancel any pending requests when the provider is disposed
    ref.onDispose(() => _httpClient.close());
  }

  Future<Map<String, dynamic>> runAnalysis(AnalysisRequest request) async {
    final url = Uri.parse("${resource.baseUrl}/analytics/run");
    try {
      final response = await _httpClient.post(
        url,
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
    final url = Uri.parse("${ResourceData.localHost.baseUrl}/analytics/bulk");
    try {
      final response = await _httpClient.post(
        url,
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
    final url = Uri.parse("${ResourceData.localHost.baseUrl}/stream");
    final httpRequest = http.Request('POST', url)
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

  Uri _buildUri(String? path, [Map<String, String>? queryParams]) {
    var uri = Uri.parse("${resource.baseUrl}$path");
    var params = {...?queryParams};

    if (apiKey != null) {
      params['access_key'] = apiKey!;
    }

    return uri.replace(queryParameters: params.isEmpty ? null : params);
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
// Future<Map<String, dynamic>> runAnalysis(AnalysisRequest request) async {
  //   final url = Uri.parse("$baseUrl/analytics/run");
  //
  //   final response = await http.post(
  //     url,
  //     headers: {"Content-Type": "application/json"},
  //     body: jsonEncode(request.toJson()),
  //   );
  //
  //   if (response.statusCode != 200) {
  //     throw Exception(
  //       "Analysis failed: ${response.statusCode} ${response.body}",
  //     );
  //   }
  //
  //   return jsonDecode(response.body);
  // }
}
