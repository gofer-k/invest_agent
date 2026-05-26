import 'dart:developer';
import 'dart:io';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../model/asset_config.dart';
import '../model/price_result.dart';
import 'load_database_provider.dart';
import 'price_controller.dart';

part 'price_importer_csv.g.dart';

@riverpod
class PriceImporter extends _$PriceImporter {
  String csvPath = "";

  @override
  Future<void> build(CacheKeyType cacheTYpe) async {
    if (cacheTYpe == CacheKeyType.memoryCache) {
      csvPath = cacheTYpe.key;
      return;
    }

    final directory = await getApplicationSupportDirectory();
    final dbDir = Directory('${directory.path}/data');
    if (!await dbDir.exists()) {
      await dbDir.create(recursive: true);
    }
    csvPath = dbDir.path;
  }

  /// Imports CSV data from the given [filePath] for a specific [assetId].
  /// Expects schema similar to: "Date","Price","Open","High","Low","Vol.","Change %"
  Future<void> importFromCsv(AssetConfig asset) async {
    final file = await _downloadedFile(asset);
    if (file == null) {
      log("No CSV file found for asset: ${asset.symbol}");
      return;
    }

    final lines = await file.readAsLines();
    if (lines.isEmpty) return;

    final headerRow = lines[0].trim();
    final headerColumns = _headerIndexes(headerRow.split(','));
    
    final dateFormat = DateFormat('MM/dd/yyyy');
    
    final closeIdx = headerColumns["close"] ?? -1;
    final openIdx = headerColumns["open"] ?? -1;
    final highIdx = headerColumns["high"] ?? -1;
    final lowIdx = headerColumns["low"] ?? -1;
    final volumeIdx = headerColumns["volume"] ?? -1;
    final dateIdx = headerColumns['date'] ?? -1;

    if (closeIdx == -1 || openIdx == -1 || highIdx == -1 || 
        lowIdx == -1 || volumeIdx == -1 || dateIdx == -1) {
      log("Invalid header columns: $headerColumns. Could not find all required fields.");
      return;
    }

    final List<IndexPriceItem> items = [];
    final maxIdx = [closeIdx, openIdx, highIdx, lowIdx, volumeIdx, dateIdx]
        .reduce((a, b) => a > b ? a : b);

    // Skip header row
    for (var i = 1; i < lines.length; i++) {
      final line = lines[i].trim();
      if (line.isEmpty) continue;

      // Basic CSV split for quoted values: "val1","val2"
      final columns = line
          .split('","')
          .map((e) => e.replaceAll('"', ''))
          .toList();

      if (columns.length <= maxIdx) continue;

      try {
        final date = dateFormat.parse(columns[dateIdx]);
        final close = double.parse(columns[closeIdx].replaceAll(',', ''));
        final open = double.parse(columns[openIdx].replaceAll(',', ''));
        final high = double.parse(columns[highIdx].replaceAll(',', ''));
        final low = double.parse(columns[lowIdx].replaceAll(',', ''));
        final volume = _parseVolume(columns[volumeIdx]);

        items.add(IndexPriceItem(
          id: 0,
          assetId: asset.id,
          dateTime: date,
          openPrice: open,
          closePrice: close,
          highPrice: high,
          lowPrice: low,
          volume: volume,
        ));
      } catch (e) {
        log("Error parsing CSV row $i: $e");
        continue;
      }
    }

    if (items.isNotEmpty) {
      final controller = ref.read(priceControllerProvider().notifier);
      final schema = IndexPriceSchema();

      // Batch save using the controller's logic
      for (final item in items) {
        await controller.save(schema, item);
      }

      await controller.refreshAllDetails();
    }
  }

  Future<File?> _downloadedFile(AssetConfig asset) async {
    final dbDir = Directory(csvPath);
    if (!await dbDir.exists()) return null;

    final List<FileSystemEntity> entities = await dbDir.list().toList();
    final matches = entities
        .whereType<File>()
        .where((file) => file.path.contains(asset.symbol));

    return matches.isEmpty ? null : matches.first;
  }
  
  double _parseVolume(String vol) {
    if (vol == '-' || vol.isEmpty) return 0.0;
    vol = vol.toUpperCase().replaceAll(',', '');
    double multiplier = 1.0;

    if (vol.endsWith('K')) {
      multiplier = 1000.0;
      vol = vol.substring(0, vol.length - 1);
    } else if (vol.endsWith('M')) {
      multiplier = 1000000.0;
      vol = vol.substring(0, vol.length - 1);
    } else if (vol.endsWith('B')) {
      multiplier = 1000000000.0;
      vol = vol.substring(0, vol.length - 1);
    }

    return (double.tryParse(vol) ?? 0.0) * multiplier;
  }

  Map<String, int> _headerIndexes(List<String> headerColumns) {
    final Map<String, int> indexes = {};
    final normalized = headerColumns.map((c) => c.toLowerCase().replaceAll('"', '').trim()).toList();
    
    indexes["date"] = normalized.indexWhere((c) => c == "date" || c == "data");
    indexes["open"] = normalized.indexWhere((c) => c == "otwarcie" || c == "open");
    indexes["high"] = normalized.indexWhere((c) => c == "high" || c == "max");
    indexes["low"] = normalized.indexWhere((c) => c == "low" || c == "min");
    indexes["close"] = normalized.indexWhere((c) => c == "close" || c == "zamkniecie" || c == "last" || c == "price");
    indexes["volume"] = normalized.indexWhere((c) => c == "volume" || c == "vol." || c == "wolumen");
    
    return indexes;
  }
}
