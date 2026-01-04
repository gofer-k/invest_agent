import 'dart:convert';
import 'dart:io';
import 'package:archive/archive.dart';
import '../model/invest_data.dart';
import 'package:path/path.dart' as p;

Future<Directory> getLocalDataDirectory() async {
  // Use the current working directory or define a custom path
  final baseDir = Directory.current.path;
  final dataDir = Directory(p.join(baseDir, 'data'));

  if (!await dataDir.exists()) {
    await dataDir.create(recursive: true);
  }
  return dataDir;
}

Future<List<FinancialEntry>> loadFinancialDataFromGzip(String filePath) async {
  final file = File(filePath);
  final compressedBytes = await file.readAsBytes();

  // Decompress using archive package
  final decompressedBytes = GZipDecoder().decodeBytes(compressedBytes);
  final jsonString = utf8.decode(decompressedBytes);
  // Replace NaN with null before parsing.
  // You could also replace it with '0' if that makes more sense for your data.
  final sanitizedJsonString = jsonString.replaceAll('NaN', 'null');
  // Parse the sanitized JSON string into a dynamic object
  final dynamic decodedJson = jsonDecode(sanitizedJsonString);

  // Check if the decoded JSON is a Map and extract the list from it.
  if (decodedJson is Map<String, dynamic>) {
    // The JSON is a Map where keys are dates and values are the entries.
    // We need to iterate through the map and create a FinancialEntry for each.
    return decodedJson.entries.map((mapEntry) {
      // The key is the date string, and the value is the map of financial data.
      final String date = mapEntry.key;
      final Map<String, dynamic> financialData = mapEntry.value;

      // Add the date to the financial data map before creating the object.
      // This assumes your FinancialEntry.fromJson expects a 'date' field.
      return FinancialEntry.fromJson(date, financialData);
    }).toList();
  }
  else {
    // Throw a more informative error if the structure is unexpected
    throw FormatException('Unexpected JSON structure in $filePath');
  }
}
