import 'package:invest_agent/model/cache.dart';

class PortfolioConfig implements Cache{
  final int? id;
  final String portfolioName;
  final int metaId;
  final double targetWeight;
  final double rebalanceThreshold;

  PortfolioConfig({
  this.id,
  this.portfolioName = "",
  required this.metaId,
  this.targetWeight = 0.25,
  this.rebalanceThreshold = 0.05,
  });

  @override
  factory PortfolioConfig.from(List<Object?> row) {
    if (row.isEmpty && row.length < 5) {
      throw Exception("Invalidate input data");
    }
    return PortfolioConfig(
      id: row[0] as int?,
      portfolioName: row[1] as String,
      metaId: row[2] as int,
      targetWeight: (row[3] as num).toDouble(),
      rebalanceThreshold: (row[4] as num).toDouble(),
    );
  }

  @override
  Map<String, dynamic> toMap() => {
  'portfolio_name': portfolioName,
  'meta_id': metaId,
  'target_weight': targetWeight,
  'rebalance_threshold': rebalanceThreshold,
  };

  @override
  String createKey() {
    return "CREATE SEQUENCE IF NOT EXISTS portfolio_config_sequence START 1;";
  }

  @override
  String create() {
    return '''CREATE TABLE IF NOT EXISTS portfolio_config (
        id INTEGER PRIMARY KEY DEFAULT nextval('config_sequence'),
        portfolio_name TEXT NOT NULL,
        meta_id INTEGER NOT NULL,
        target_weight FLOAT NOT NULL,
        rebalance_threshold FLOAT DEFAULT 0.05,
        UNIQUE(portfolio_name, meta_id)
      );
    ''';
  }

  @override
  String deleteOne() {
    return "DELETE FROM portfolio_config WHERE id = $id;";
  }

  @override
  String saveOne() {
    return '''
      INSERT INTO portfolio_config 
      VALUES (
     '$portfolioName',
      $metaId,
      $targetWeight,
      $rebalanceThreshold);
      ''';
  }

  @override
  String readOne() {
    return "SELECT * FROM portfolio_config WHERE id = $id;";
  }

  @override
  String? updateOne() {
    if (id == null) return null;
    return '''
      UPDATE portfolio_config
      SET portfolio_name = '$portfolioName',
          meta_id = $metaId,
          target_weight = $targetWeight,
          rebalance_threshold = $rebalanceThreshold
      WHERE id = $id;
      ''';
  }

  @override
  String readAll() {
    return "SELECT * FROM portfolio_config ORDER BY id DESC;";
  }

  @override
  String deleteAll() {
    return "DELETE FROM portfolio_config;";
  }
}