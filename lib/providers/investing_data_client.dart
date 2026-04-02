import 'dart:convert';
import 'package:http/http.dart' as http;
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
  // final baseUri = "http://127.0.0.1:8000";

  @override
  void build(String baseUrl) {
    _httpClient = http.Client();
    // Automatically close the client and cancel any pending requests when the provider is disposed
    ref.onDispose(() => _httpClient.close());
  }

  Future<Map<String, dynamic>> runAnalysis(AnalysisRequest request) async {
    final url = Uri.parse("$baseUrl/analytics/run");
    return _handleResponse(await _httpClient.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode(request.toJson()),
    ));
  }

  Future<List<Map<String, dynamic>>> runBulkAnalysis(List<AnalysisRequest> requests) async {
    // TODO:
    final url = Uri.parse("$baseUrl/analytics/bulk");
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
  }

  Stream<Map<String, dynamic>> getAnalysisStream(AnalysisRequest request) async* {
    final url = Uri.parse("$baseUrl/analytics/stream");
    final httpRequest = http.Request('POST', url)
      ..headers['Content-Type'] = 'application/json'
      ..body = jsonEncode(request.toJson());

    final response = await _httpClient.send(httpRequest);

    if (response.statusCode != 200) {
      throw RemoteDataException(
        "Streaming failed",
        statusCode: response.statusCode,
      );
    }

    // Process the stream line by line (assuming NDJSON or similar)
    yield* response.stream
        .transform(utf8.decoder)
        .transform(const LineSplitter())
        .where((line) => line.isNotEmpty)
        .map((line) => jsonDecode(line) as Map<String, dynamic>);
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
