import 'dart:convert';
import 'package:http/http.dart' as http;
import 'analysis_request.dart';

class ETFAnalyticsClient {
  final String baseUrl;

  ETFAnalyticsClient({this.baseUrl = "http://localhost:8000"});

  Future<Map<String, dynamic>> runAnalysis(AnalysisRequest request) async {
    final url = Uri.parse("$baseUrl/analytics/run");

    final response = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode(request.toJson()),
    );

    if (response.statusCode != 200) {
      throw Exception(
        "Analysis failed: ${response.statusCode} ${response.body}",
      );
    }

    return jsonDecode(response.body);
  }
}
