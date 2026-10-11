import 'package:collection/collection.dart';
import 'package:invest_agent/model/cache_schema.dart';

import 'asset_config.dart';

class PortfolioConfigSchema implements CacheSchema {
  const PortfolioConfigSchema();
  static const String tableName = "portfolio";
  static const String tableSequenceName = "portfolio_sequence";

  @override
  String get create =>
    '''
    CREATE TABLE IF NOT EXISTS $tableName (
      id INTEGER PRIMARY KEY DEFAULT nextval('$tableSequenceName'),
      portfolio_name TEXT NOT NULL,
      portfolio_desc TEXT DEFAULT '',
      created_at TIMESTAMP,
      assets TEXT, -- string array format: [1, 2, 45, ...]
      risk_free_rate FLOAT NOT NULL
    );
    ''';

  @override
  String get createKey => ''' CREATE SEQUENCE IF NOT EXISTS '$tableSequenceName' START 1; ''';

  @override
  String get deleteAll => ''' DELETE FROM $tableName; ''';

  @override
  String deleteOne(Cache cache) {
    final id = (cache as PortfolioConfig).id;
    return ''' DELETE FROM $tableName WHERE id = $id; ''';
  }

  @override
  String get readAll => ''' SELECT * FROM $tableName  ORDER BY portfolio_name; ''';

  @override
  String readOne(Cache cache) => ''' "SELECT * FROM $tableName WHERE id = ${(cache as PortfolioConfig).id}; ''';

  @override
  String saveOne(Cache cache) {
    final portfolioConfig = cache as PortfolioConfig;
    final assetsIds = portfolioConfig.assets.map((e) => e.id).toList();

    final idsArray = "[${assetsIds.join(',')}]";
    return '''
     INSERT INTO $tableName
      VALUES ('
      nextval('$tableSequenceName'),
      '${portfolioConfig.portfolioName}',
      '${portfolioConfig.portfolioDesc}',
      '${portfolioConfig.createdDateTime.toIso8601String()}',
      $idsArray,
      ${portfolioConfig.riskFreeRatePerYear},
      );
     ''';
  }

  @override
  String updateOne(Cache cache) {
    final portfolioConfig = cache as PortfolioConfig;
    final id = portfolioConfig.id;
    final portfolioName = portfolioConfig.portfolioName;
    final portfolioDesc = portfolioConfig.portfolioDesc;
    final createdDateTime = portfolioConfig.createdDateTime;
    final assets = portfolioConfig.assets.map((e) => e.id).toList();

    final idsArray = "[${assets.join(',')}]";

    return '''
      UPDATE $tableName
      SET portfolio_name = '$portfolioName',
          portfolio_desc = '$portfolioDesc',
          created_at = '$createdDateTime',
          assets = $idsArray,
          risk_free_rate = ${portfolioConfig.riskFreeRatePerYear}          
      WHERE id = $id;
      ''';
  }
}

class PortfolioConfig implements Cache{
  final int? id;
  final String portfolioName;
  final String portfolioDesc;
  final double riskFreeRatePerYear;
  final List<AssetConfig> assets;
  final DateTime createdDateTime;

  static const double defaultRiskFreeRate = 0.05;

  PortfolioConfig({
    this.id,
    this.portfolioName = "",
    this.portfolioDesc = "",
    this.riskFreeRatePerYear = defaultRiskFreeRate,
    required this.createdDateTime,
    required this.assets,
  });

  PortfolioConfig copyWith({
    int? newId,
    String? newName,
    String? newDesc,
    double? newRiskFreeRatePerYear,
    List<AssetConfig>? newAssets,
    DateTime? newCreatedDataTime}) {
    return PortfolioConfig(
      id: newId ?? id,
      portfolioName: newName ?? portfolioName,
      portfolioDesc: newDesc ?? portfolioDesc,
      assets: newAssets ?? assets,
      createdDateTime: newCreatedDataTime ?? createdDateTime
    );
  }

  PortfolioConfig fillAssets(List<AssetConfig> assets) {
    if (assets.isEmpty) return this;

    final portfolioAssets = assets.where((a) => this.assets.contains(a)).toList();
    return copyWith(newAssets: portfolioAssets);
  }

  @override
  factory PortfolioConfig.fromMap(List<Object?> item) {
    if (item.isEmpty && item.length < 5) {
      throw Exception("Invalidate input data");
    }
    final assetsIds = (item[4] as List).cast<int>();
    final portfolioAssets = assetsIds.map(
            (assetId) => AssetConfig.of(id: assetId)).toList();
    return PortfolioConfig(
      id: item[0] as int?,
      portfolioName: item[1] as String,
      portfolioDesc: item[2] as String,
      riskFreeRatePerYear: item[3] as double? ?? defaultRiskFreeRate,
      assets: portfolioAssets,
      createdDateTime: item[5] as DateTime);
  }

  @override
  Map<String, dynamic> toMap() => {
    'id': id,
    'portfolio_name': portfolioName,
    'portfolio_desc': portfolioDesc,
    'risk_Free_rate': riskFreeRatePerYear,
    'assets': assets.map((asset) => asset.id).toList(),
    'created_at': createdDateTime,
  };

  @override
  String toString() => portfolioName;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PortfolioConfig &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          portfolioName == other.portfolioName &&
          portfolioDesc == other.portfolioDesc &&
          riskFreeRatePerYear == other.riskFreeRatePerYear &&
          const ListEquality().equals(assets, other.assets) &&
          createdDateTime == other.createdDateTime;

  @override
  int get hashCode => Object.hash(
      id.hashCode,
      portfolioName,
      portfolioDesc,
      riskFreeRatePerYear,
      const ListEquality().hash(assets),
      createdDateTime);

  @override
  List<Object?> get props => [id, portfolioName, portfolioDesc, riskFreeRatePerYear, assets, createdDateTime];

  @override
  bool? get stringify => true;
}
