import 'package:invest_agent/model/asset_config.dart';
import 'package:invest_agent/model/cache_schema.dart';

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
      DELETE FROM $cacheName WHERE id = ${(cache as IndexPrice).id} AND
      meta_id = ${(cache as AssetConfig).id};
      ''';
  }

  String deleteAssetAll(Cache cache) {
    return "DELETE FROM $cacheName WHERE meta_id = ${(cache as AssetConfig).id};";
  }

  @override
  String get readAll => 'SELECT * FROM $cacheName ORDER BY id DESC;';

  @override
  String readOne(Cache cache) =>
      'SELECT * FROM $cacheName WHERE id = ${(cache as AssetConfig).id};';

  @override
  String saveOne(Cache cache) {
    final price = cache as IndexPrice;
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
     );
  ''';
  }

  @override
  String updateOne(Cache cache) {
    final price = cache as IndexPrice;
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
        AND '${beginDate.toIso8601String()}';
        ''';
    }
    return
      '''
      SELECT * FROM $cacheName WHERE meta_id = ${asset.id}
      AND date BETWEEN '${beginDate.toIso8601String()}'
      AND '${endDate.toIso8601String()}';
      ''';
  }

  String readUntilDate(AssetConfig asset, DateTime date) =>
      '''
      SELECT * FROM $cacheName WHERE meta_id = ${asset.id} AND date <= '${date.toIso8601String()}';
      ''';

  String readAfterDate(AssetConfig asset, DateTime date) =>
    '''
      SELECT * FROM $cacheName WHERE meta_id = ${asset.id} AND date > '${date.toIso8601String()}';
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
}

class IndexPrice extends Cache {
  final int id;
  final int assetId;
  final DateTime dateTime;
  final double openPrice;
  final double closePrice;
  final double highPrice;
  final double lowPrice;
  final double volume;

  IndexPrice({
    required this.id,
    required this.assetId,
    required this.dateTime,
    required this.openPrice,
    required this.closePrice,
    required this.highPrice,
    required this.lowPrice,
    required this.volume}) : super.from([]);

  @override
  String toString() {
    return '';
  }

  @override
  factory IndexPrice.from(List<Object?> item) {
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
      
      return IndexPrice(
        id: item[0] as int,
        assetId: item[1] as int,
        dateTime: dateTime,
        openPrice: (item[3] as num).toDouble(),
        closePrice: (item[4] as num).toDouble(),
        highPrice: (item[5] as num).toDouble(),
        lowPrice: (item[6] as num).toDouble(),
        volume: (item[7] as num).toDouble(),
      );
    }
    catch (e) {
      throw Exception("Invalidate input data: $e");
    }
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
        other is IndexPrice &&
            runtimeType == other.runtimeType &&
            id == other.id &&
            assetId == other.assetId &&
            dateTime == other.dateTime &&
            openPrice == other.openPrice &&
            closePrice == other.closePrice &&
            highPrice == other.highPrice &&
            lowPrice == other.lowPrice &&
            volume == other.volume;

  @override
  int get hashCode =>
      id.hashCode ^
      assetId.hashCode ^
      dateTime.hashCode ^
      openPrice.hashCode ^
      closePrice.hashCode ^
      highPrice.hashCode ^
      lowPrice.hashCode ^
      volume.hashCode;
}
