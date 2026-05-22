import 'package:invest_agent/model/asset_config.dart';
import 'package:invest_agent/model/cache_schema.dart';

import 'indicator_result.dart';
import 'indicator_schema.dart';

class IndexPriceSchema implements CacheSchema {
  static const String cacheName = "price";
  static const String cacheSequenceName = "price_id_sequence";

  @override
  String get create =>
      '''
      CREATE TABLE IF NOT EXISTS $cacheName (
          id INTEGER PRIMARY KEY DEFAULT nextval('$cacheSequenceName'),
          meta_id INTEGER,            
          date TIMESTAMP,
          open FLOAT,
          high FLOAT,
          low FLOAT,
          close FLOAT,
          volume FLOAT,
          UNIQUE(meta_id, date),
          FOREIGN KEY (meta_id) REFERENCES ${AssetConfigSchema.cacheName}(id)
      );      
    ''';

  @override
  String get createKey =>
      "CREATE SEQUENCE IF NOT EXISTS $cacheSequenceName START 1;";

  @override
  String get deleteAll => 'DELETE FROM $cacheName;';

  @override
  String deleteOne(Cache cache) {
    return
      '''
      DELETE FROM $cacheName WHERE id = ${(cache as IndexPriceItem).id} AND
      meta_id = ${cache.assetId};
      ''';
  }

  String deleteAssetAll(Cache cache) {
    return "DELETE FROM $cacheName WHERE meta_id = ${(cache as AssetConfig).id};";
  }

  @override
  String get readAll => 'SELECT * FROM $cacheName ORDER BY date ASC;';

  @override
  String readOne(Cache cache) =>
      'SELECT * FROM $cacheName WHERE id = ${(cache as IndexPriceItem).id};';

  @override
  String saveOne(Cache cache) {
    final price = cache as IndexPriceItem;
    return '''
      INSERT INTO $cacheName
      VALUES (
      nextval('$cacheSequenceName'),
      ${price.assetId},
     '${price.dateTime.toIso8601String()}',
     ${price.openPrice},
     ${price.highPrice},
     ${price.lowPrice},
     ${price.closePrice},
     ${price.volume}
     ) ON CONFLICT(meta_id, date) DO UPDATE SET
          open = excluded.open,
          high = excluded.high,
          low = excluded.low,
          close = excluded.close,
          volume = excluded.volume;
  ''';
  }

  @override
  String updateOne(Cache cache) {
    final price = cache as IndexPriceItem;
    return '''
      UPDATE $cacheName
      SET meta_id = ${price.assetId},
          date = '${price.dateTime.toIso8601String()}',
          open = ${price.openPrice},
          high = ${price.highPrice},
          low = ${price.lowPrice},
          close = ${price.closePrice},
          volume = ${price.volume}
      WHERE id = ${price.id};
    ''';
  }

  String oldestDate(AssetConfig asset) => 'SELECT MIN(date) FROM $cacheName WHERE meta_id = ${asset.id};';

  String newestDate(AssetConfig asset) => 'SELECT MAX(date) FROM $cacheName WHERE meta_id = ${asset.id};';

  String readDateRange(AssetConfig asset, DateTime beginDate, DateTime endDate) {
    if (beginDate.isAfter(endDate)) {
      return
        '''
        SELECT * FROM $cacheName WHERE meta_id = ${asset.id}
        AND date BETWEEN '${endDate.toIso8601String()}'
        AND '${beginDate.toIso8601String()}' ORDER BY date ASC;
        ''';
    }
    return
      '''
      SELECT * FROM $cacheName WHERE meta_id = ${asset.id}
      AND date BETWEEN '${beginDate.toIso8601String()}'
      AND '${endDate.toIso8601String()}' ORDER BY date ASC;
      ''';
  }

  String readUntilDate(AssetConfig asset, DateTime date) =>
      '''
      SELECT * FROM $cacheName WHERE meta_id = ${asset.id} AND date <= '${date.toIso8601String()}' ORDER BY date DESC;
      ''';

  String readAfterDate(AssetConfig asset, DateTime date) =>
    '''
      SELECT * FROM $cacheName WHERE meta_id = ${asset.id} AND date > '${date.toIso8601String()}' ORDER BY date ASC;
    ''';

  String readCount(AssetConfig asset, DateTime beginDate, DateTime endDate) {
    if (beginDate.isAfter(endDate)) {
      return
      '''
        SELECT COUNT(*) FROM $cacheName WHERE meta_id = ${asset.id}
        AND date BETWEEN '${endDate.toIso8601String()}'
        AND '${beginDate.toIso8601String()}';
      ''';
    }
    return
      '''
      SELECT COUNT(*) FROM $cacheName WHERE meta_id = ${asset.id}
      AND date BETWEEN '${beginDate.toIso8601String()}'
      AND '${endDate.toIso8601String()}';
      ''';
  }

  String get allAssetDetails => 'SELECT meta_id, MIN(date), MAX(date), COUNT(*) FROM $cacheName GROUP BY meta_id;';
}

class IndexPriceItem implements Cache, BaseIndicatorValue {
  final int id;
  final int assetId;
  final double openPrice;
  final double closePrice;
  final double highPrice;
  final double lowPrice;
  final double volume;

  final DateTime _dateTime;
  @override
  DateTime get dateTime => _dateTime;

  IndexPriceItem({
    required this.id,
    required this.assetId,
    required this.openPrice,
    required this.closePrice,
    required this.highPrice,
    required this.lowPrice,
    required this.volume, required DateTime dateTime}) : _dateTime = dateTime;

  static double toDouble(Object? val) {
    if (val == null) return 0.0;
    if (val is double) return val;
    if (val is int) return val.toDouble();
    // Fallback for string-based returns which can happen with certain DB configurations
    return double.tryParse(val.toString()) ?? 0.0;
  }

  @override
  String toString() {
    return 'IndexPrice(id: $id, assetId: $assetId, date: $dateTime, close: $closePrice)';
  }

  @override
  factory IndexPriceItem.from(List<Object?> item) {
    if (item.length < 8) {
      throw Exception("Invalidate input data");
    }

    try {
      DateTime dateTime;
      if (item[2] is DateTime) {
        dateTime = item[2] as DateTime;
      } else {
        dateTime = DateTime.parse(item[2].toString());
      }

      final jsonVolume = item[7] == null ? 0.0 : IndexPriceItem.toDouble(item[7]);

      return IndexPriceItem(
        id: (item[0] as num).toInt(),
        assetId: (item[1] as num).toInt(),
        dateTime: dateTime,
        openPrice: IndexPriceItem.toDouble(item[3]),
        highPrice: IndexPriceItem.toDouble(item[4]),
        lowPrice: IndexPriceItem.toDouble(item[5]),
        closePrice: IndexPriceItem.toDouble(item[6]),
        volume: jsonVolume,
      );
    }
    catch (e) {
      throw Exception("Invalidate input data: $e");
    }
  }

  factory IndexPriceItem.of({int? assetId, DateTime? dateTime}) {
    return IndexPriceItem(
      id: 0,
      assetId: assetId ?? 0,
      dateTime: dateTime ?? DateTime.now(),
      openPrice: 0.0,
      closePrice: 0.0,
      highPrice: 0.0,
      lowPrice: 0.0,
      volume: 0.0);
  }

  @override
  Map<String, dynamic> toMap() => {
    'id': id,
    'meta_id': assetId,
    'date': dateTime,
    'open': openPrice,
    'high': highPrice,
    'low': lowPrice,
    'close': closePrice,
    'volume': volume,
  };

  @override
  bool operator ==(Object other) =>
    identical(this, other) ||
        other is IndexPriceItem &&
            runtimeType == other.runtimeType &&
            id == other.id &&
            assetId == other.assetId &&
            dateTime == other.dateTime &&
            openPrice == other.openPrice && // TODO: Consider not use thore below
            closePrice == other.closePrice &&
            highPrice == other.highPrice &&
            lowPrice == other.lowPrice &&
            volume == other.volume;

  @override
  int get hashCode =>
      id.hashCode ^
      assetId.hashCode ^
      dateTime.hashCode ^
      openPrice.hashCode ^  // TODO: Consider not use thore below
      closePrice.hashCode ^
      highPrice.hashCode ^
      lowPrice.hashCode ^
      volume.hashCode;
}

class IndexPrice extends BaseIndicatorResult {
  final List<IndexPriceItem> priceData;

  double _maxValue = 0.0;
  @override
  double get maxValue => _maxValue;

  double _minValue = 0.0;
  @override
  double get minValue => _minValue;

  IndexPrice({
    super.style = ChartStyle.line,
    required this.priceData,
    required super.config});

  void resetMinMax() {
    _minValue = 0.0;
    _maxValue = 0.0;
  }

  IndexPrice copyWith({
    List<IndexPriceItem>? newPriceData,
    ChartStyle? newStyle,
    Indicator? newConfig}) {
    return IndexPrice(
      priceData: newPriceData ?? priceData,
      style: newStyle ?? style,
      config: newConfig ?? config,
    );
  }

  List<IndexPriceItem> _filteredBy(int prefixWindow, DateTime startDate, DateTime endDate) {
    final priceDataFiltered =
    priceData.where(
            (element) => element.dateTime.isAfter(startDate)
            && element.dateTime.isBefore(endDate)).toList();
    if (priceDataFiltered.length <= prefixWindow) {
      throw Exception("IndexPrice._filteredBy: Invalid input data, prefixWindow: $prefixWindow, startDate: $startDate, endDate: $endDate");
    }
    return priceDataFiltered.sublist(prefixWindow);
  }

  List<DateTime> dateTimeDomain(int prefixWindow) {
    if (priceData.length <= prefixWindow) {
      throw Exception("IndexPrice.dateTimeDomain: Invalid input data, prefixWindow: $prefixWindow");
    }
    return priceData.sublist(prefixWindow).map((element) => element.dateTime).toList();
  }

  List<IndexPriceItem> getData(int prefixWindow, DateTime? startDate, DateTime? endDate) {
    if (prefixWindow > 0) {
      return priceData.sublist(prefixWindow);
    }
    return _filteredBy(prefixWindow, startDate ?? DateTime.now(), endDate ?? DateTime.now());
  }

  @override
  double getMin(DateTime? startDate, DateTime? endDate) {
    if (priceData.isEmpty) {
      return 0.0;
    }

    final priceDataFiltered = (startDate != null && endDate != null) ? _filteredBy(0, startDate, endDate) : priceData;
    if (priceDataFiltered.isEmpty) {
      return 0.0;
    }

    final minPriceItem = priceDataFiltered.reduce(
            (currentItem, nextItem) =>
        currentItem.closePrice <= nextItem.closePrice ? currentItem : nextItem);

   _minValue = minPriceItem.closePrice;
   return _minValue;
  }

  @override
  double getMax(DateTime? startDate, DateTime? endDate) {
    if (priceData.isEmpty) {
      return 0.0;
    }

    final priceDataFiltered = (startDate != null && endDate != null) ? _filteredBy(0, startDate, endDate) : priceData;
    if (priceDataFiltered.isEmpty) {
      return 0.0;
    }

    final maxPriceItem = priceDataFiltered.reduce(
          (currentItem, nextItem) =>
          currentItem.closePrice > nextItem.closePrice ? currentItem : nextItem,
    );
    _maxValue = maxPriceItem.closePrice;
   return _maxValue;
  }
}

class VolumeResult extends IndexPrice {
  VolumeResult({
    required super.priceData,
    required super.config,
    super.style = ChartStyle.bars,
  });

  @override
  double getMin(DateTime? startDate, DateTime? endDate) {
    if (priceData.isEmpty) return 0.0;
    final priceDataFiltered = (startDate != null && endDate != null) ? _filteredBy(0, startDate, endDate) : priceData;
    if (priceDataFiltered.isEmpty) return 0.0;

    _minValue = priceDataFiltered.reduce((value, element) => value.volume <= element.volume ? value : element).volume;
    return _minValue;
  }

  @override
  double getMax(DateTime? startDate, DateTime? endDate) {
    if (priceData.isEmpty) return 0.0;
    final priceDataFiltered = (startDate != null && endDate != null) ? _filteredBy(0, startDate, endDate) : priceData;
    if (priceDataFiltered.isEmpty) return 0.0;

    _maxValue =  priceDataFiltered.reduce((value, element) => value.volume > element.volume ? value : element).volume;
    return _maxValue;
  }
}
