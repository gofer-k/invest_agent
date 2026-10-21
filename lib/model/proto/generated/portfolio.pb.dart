// This is a generated file - do not edit.
//
// Generated from portfolio.proto.

// @dart = 3.3

// ignore_for_file: annotate_overrides, camel_case_types, comment_references
// ignore_for_file: constant_identifier_names
// ignore_for_file: curly_braces_in_flow_control_structures
// ignore_for_file: deprecated_member_use_from_same_package, library_prefixes
// ignore_for_file: non_constant_identifier_names, prefer_relative_imports

import 'dart:core' as $core;

import 'package:protobuf/protobuf.dart' as $pb;
import 'package:protobuf/well_known_types/google/protobuf/struct.pb.dart' as $2;
import 'package:protobuf/well_known_types/google/protobuf/timestamp.pb.dart'
    as $3;

import 'portfolio.pbenum.dart';
import 'price.pb.dart' as $1;

export 'package:protobuf/protobuf.dart' show GeneratedMessageGenericExtensions;

export 'portfolio.pbenum.dart';

class Portfolio extends $pb.GeneratedMessage {
  factory Portfolio({
    $core.String? id,
    $core.String? name,
    $core.String? description,
    $core.double? initialCapital,
    $core.double? riskFreeRate,
    $core.Iterable<AssetAllocation>? allocations,
  }) {
    final result = create();
    if (id != null) result.id = id;
    if (name != null) result.name = name;
    if (description != null) result.description = description;
    if (initialCapital != null) result.initialCapital = initialCapital;
    if (riskFreeRate != null) result.riskFreeRate = riskFreeRate;
    if (allocations != null) result.allocations.addAll(allocations);
    return result;
  }

  Portfolio._();

  factory Portfolio.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory Portfolio.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'Portfolio',
      package: const $pb.PackageName(
          _omitMessageNames ? '' : 'trading.portfolio.analytics'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'id')
    ..aOS(2, _omitFieldNames ? '' : 'name')
    ..aOS(3, _omitFieldNames ? '' : 'description')
    ..aD(4, _omitFieldNames ? '' : 'initialCapital')
    ..aD(5, _omitFieldNames ? '' : 'riskFreeRate')
    ..pPM<AssetAllocation>(6, _omitFieldNames ? '' : 'allocations',
        subBuilder: AssetAllocation.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  Portfolio clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  Portfolio copyWith(void Function(Portfolio) updates) =>
      super.copyWith((message) => updates(message as Portfolio)) as Portfolio;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static Portfolio create() => Portfolio._();
  @$core.override
  Portfolio createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static Portfolio getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<Portfolio>(create);
  static Portfolio? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get id => $_getSZ(0);
  @$pb.TagNumber(1)
  set id($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasId() => $_has(0);
  @$pb.TagNumber(1)
  void clearId() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get name => $_getSZ(1);
  @$pb.TagNumber(2)
  set name($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasName() => $_has(1);
  @$pb.TagNumber(2)
  void clearName() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.String get description => $_getSZ(2);
  @$pb.TagNumber(3)
  set description($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasDescription() => $_has(2);
  @$pb.TagNumber(3)
  void clearDescription() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.double get initialCapital => $_getN(3);
  @$pb.TagNumber(4)
  set initialCapital($core.double value) => $_setDouble(3, value);
  @$pb.TagNumber(4)
  $core.bool hasInitialCapital() => $_has(3);
  @$pb.TagNumber(4)
  void clearInitialCapital() => $_clearField(4);

  @$pb.TagNumber(5)
  $core.double get riskFreeRate => $_getN(4);
  @$pb.TagNumber(5)
  set riskFreeRate($core.double value) => $_setDouble(4, value);
  @$pb.TagNumber(5)
  $core.bool hasRiskFreeRate() => $_has(4);
  @$pb.TagNumber(5)
  void clearRiskFreeRate() => $_clearField(5);

  @$pb.TagNumber(6)
  $pb.PbList<AssetAllocation> get allocations => $_getList(5);
}

/// Defines an individual ETF asset weight within a portfolio
class AssetAllocation extends $pb.GeneratedMessage {
  factory AssetAllocation({
    $core.int? assetId,
    $core.double? targetWeight,
    $core.int? assetSharesCount,
    $core.Iterable<$1.IndexPriceItem>? price,
  }) {
    final result = create();
    if (assetId != null) result.assetId = assetId;
    if (targetWeight != null) result.targetWeight = targetWeight;
    if (assetSharesCount != null) result.assetSharesCount = assetSharesCount;
    if (price != null) result.price.addAll(price);
    return result;
  }

  AssetAllocation._();

  factory AssetAllocation.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory AssetAllocation.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'AssetAllocation',
      package: const $pb.PackageName(
          _omitMessageNames ? '' : 'trading.portfolio.analytics'),
      createEmptyInstance: create)
    ..aI(1, _omitFieldNames ? '' : 'assetId')
    ..aD(2, _omitFieldNames ? '' : 'targetWeight')
    ..aI(3, _omitFieldNames ? '' : 'assetSharesCount')
    ..pPM<$1.IndexPriceItem>(4, _omitFieldNames ? '' : 'price',
        subBuilder: $1.IndexPriceItem.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  AssetAllocation clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  AssetAllocation copyWith(void Function(AssetAllocation) updates) =>
      super.copyWith((message) => updates(message as AssetAllocation))
          as AssetAllocation;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static AssetAllocation create() => AssetAllocation._();
  @$core.override
  AssetAllocation createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static AssetAllocation getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<AssetAllocation>(create);
  static AssetAllocation? _defaultInstance;

  @$pb.TagNumber(1)
  $core.int get assetId => $_getIZ(0);
  @$pb.TagNumber(1)
  set assetId($core.int value) => $_setSignedInt32(0, value);
  @$pb.TagNumber(1)
  $core.bool hasAssetId() => $_has(0);
  @$pb.TagNumber(1)
  void clearAssetId() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.double get targetWeight => $_getN(1);
  @$pb.TagNumber(2)
  set targetWeight($core.double value) => $_setDouble(1, value);
  @$pb.TagNumber(2)
  $core.bool hasTargetWeight() => $_has(1);
  @$pb.TagNumber(2)
  void clearTargetWeight() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.int get assetSharesCount => $_getIZ(2);
  @$pb.TagNumber(3)
  set assetSharesCount($core.int value) => $_setSignedInt32(2, value);
  @$pb.TagNumber(3)
  $core.bool hasAssetSharesCount() => $_has(2);
  @$pb.TagNumber(3)
  void clearAssetSharesCount() => $_clearField(3);

  @$pb.TagNumber(4)
  $pb.PbList<$1.IndexPriceItem> get price => $_getList(3);
}

/// Configuration parameters for the algorithmic execution
class StrategyConfig extends $pb.GeneratedMessage {
  factory StrategyConfig({
    StrategyType? strategyType,
    RebalanceFrequency? rebalanceFrequency,
    $2.Struct? customParameters,
  }) {
    final result = create();
    if (strategyType != null) result.strategyType = strategyType;
    if (rebalanceFrequency != null)
      result.rebalanceFrequency = rebalanceFrequency;
    if (customParameters != null) result.customParameters = customParameters;
    return result;
  }

  StrategyConfig._();

  factory StrategyConfig.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory StrategyConfig.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'StrategyConfig',
      package: const $pb.PackageName(
          _omitMessageNames ? '' : 'trading.portfolio.analytics'),
      createEmptyInstance: create)
    ..aE<StrategyType>(1, _omitFieldNames ? '' : 'strategyType',
        enumValues: StrategyType.values)
    ..aE<RebalanceFrequency>(2, _omitFieldNames ? '' : 'rebalanceFrequency',
        enumValues: RebalanceFrequency.values)
    ..aOM<$2.Struct>(3, _omitFieldNames ? '' : 'customParameters',
        subBuilder: $2.Struct.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  StrategyConfig clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  StrategyConfig copyWith(void Function(StrategyConfig) updates) =>
      super.copyWith((message) => updates(message as StrategyConfig))
          as StrategyConfig;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static StrategyConfig create() => StrategyConfig._();
  @$core.override
  StrategyConfig createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static StrategyConfig getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<StrategyConfig>(create);
  static StrategyConfig? _defaultInstance;

  @$pb.TagNumber(1)
  StrategyType get strategyType => $_getN(0);
  @$pb.TagNumber(1)
  set strategyType(StrategyType value) => $_setField(1, value);
  @$pb.TagNumber(1)
  $core.bool hasStrategyType() => $_has(0);
  @$pb.TagNumber(1)
  void clearStrategyType() => $_clearField(1);

  @$pb.TagNumber(2)
  RebalanceFrequency get rebalanceFrequency => $_getN(1);
  @$pb.TagNumber(2)
  set rebalanceFrequency(RebalanceFrequency value) => $_setField(2, value);
  @$pb.TagNumber(2)
  $core.bool hasRebalanceFrequency() => $_has(1);
  @$pb.TagNumber(2)
  void clearRebalanceFrequency() => $_clearField(2);

  @$pb.TagNumber(3)
  $2.Struct get customParameters => $_getN(2);
  @$pb.TagNumber(3)
  set customParameters($2.Struct value) => $_setField(3, value);
  @$pb.TagNumber(3)
  $core.bool hasCustomParameters() => $_has(2);
  @$pb.TagNumber(3)
  void clearCustomParameters() => $_clearField(3);
  @$pb.TagNumber(3)
  $2.Struct ensureCustomParameters() => $_ensure(2);
}

/// Calculated risk and performance indicators
class PerformanceMetrics extends $pb.GeneratedMessage {
  factory PerformanceMetrics({
    $core.double? totalReturn,
    $core.double? annualizedReturn,
    $core.double? volatility,
    $core.double? sharpeRatio,
    $core.double? sortinoRatio,
    $core.double? maxDrawdown,
    $core.double? alpha,
    $core.double? beta,
    $core.double? cagr,
    $core.double? calmar,
    $core.double? correlation,
    $core.double? trackingError,
    $core.double? trackingDiff,
    $core.double? expenseRatio,
    $core.double? bidAskSpread,
    $core.double? concentration,
    $core.double? dividendYield,
  }) {
    final result = create();
    if (totalReturn != null) result.totalReturn = totalReturn;
    if (annualizedReturn != null) result.annualizedReturn = annualizedReturn;
    if (volatility != null) result.volatility = volatility;
    if (sharpeRatio != null) result.sharpeRatio = sharpeRatio;
    if (sortinoRatio != null) result.sortinoRatio = sortinoRatio;
    if (maxDrawdown != null) result.maxDrawdown = maxDrawdown;
    if (alpha != null) result.alpha = alpha;
    if (beta != null) result.beta = beta;
    if (cagr != null) result.cagr = cagr;
    if (calmar != null) result.calmar = calmar;
    if (correlation != null) result.correlation = correlation;
    if (trackingError != null) result.trackingError = trackingError;
    if (trackingDiff != null) result.trackingDiff = trackingDiff;
    if (expenseRatio != null) result.expenseRatio = expenseRatio;
    if (bidAskSpread != null) result.bidAskSpread = bidAskSpread;
    if (concentration != null) result.concentration = concentration;
    if (dividendYield != null) result.dividendYield = dividendYield;
    return result;
  }

  PerformanceMetrics._();

  factory PerformanceMetrics.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory PerformanceMetrics.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'PerformanceMetrics',
      package: const $pb.PackageName(
          _omitMessageNames ? '' : 'trading.portfolio.analytics'),
      createEmptyInstance: create)
    ..aD(1, _omitFieldNames ? '' : 'totalReturn')
    ..aD(2, _omitFieldNames ? '' : 'annualizedReturn')
    ..aD(3, _omitFieldNames ? '' : 'volatility')
    ..aD(4, _omitFieldNames ? '' : 'sharpeRatio')
    ..aD(5, _omitFieldNames ? '' : 'sortinoRatio')
    ..aD(6, _omitFieldNames ? '' : 'maxDrawdown')
    ..aD(7, _omitFieldNames ? '' : 'alpha')
    ..aD(8, _omitFieldNames ? '' : 'beta')
    ..aD(9, _omitFieldNames ? '' : 'cagr', fieldType: $pb.PbFieldType.OF)
    ..aD(10, _omitFieldNames ? '' : 'calmar', fieldType: $pb.PbFieldType.OF)
    ..aD(11, _omitFieldNames ? '' : 'correlation',
        fieldType: $pb.PbFieldType.OF)
    ..aD(12, _omitFieldNames ? '' : 'trackingError',
        fieldType: $pb.PbFieldType.OF)
    ..aD(13, _omitFieldNames ? '' : 'trackingDiff',
        fieldType: $pb.PbFieldType.OF)
    ..aD(14, _omitFieldNames ? '' : 'expenseRatio',
        fieldType: $pb.PbFieldType.OF)
    ..aD(15, _omitFieldNames ? '' : 'bidAskSpread',
        fieldType: $pb.PbFieldType.OF)
    ..aD(16, _omitFieldNames ? '' : 'concentration',
        fieldType: $pb.PbFieldType.OF)
    ..aD(17, _omitFieldNames ? '' : 'dividendYield',
        fieldType: $pb.PbFieldType.OF)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  PerformanceMetrics clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  PerformanceMetrics copyWith(void Function(PerformanceMetrics) updates) =>
      super.copyWith((message) => updates(message as PerformanceMetrics))
          as PerformanceMetrics;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static PerformanceMetrics create() => PerformanceMetrics._();
  @$core.override
  PerformanceMetrics createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static PerformanceMetrics getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<PerformanceMetrics>(create);
  static PerformanceMetrics? _defaultInstance;

  @$pb.TagNumber(1)
  $core.double get totalReturn => $_getN(0);
  @$pb.TagNumber(1)
  set totalReturn($core.double value) => $_setDouble(0, value);
  @$pb.TagNumber(1)
  $core.bool hasTotalReturn() => $_has(0);
  @$pb.TagNumber(1)
  void clearTotalReturn() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.double get annualizedReturn => $_getN(1);
  @$pb.TagNumber(2)
  set annualizedReturn($core.double value) => $_setDouble(1, value);
  @$pb.TagNumber(2)
  $core.bool hasAnnualizedReturn() => $_has(1);
  @$pb.TagNumber(2)
  void clearAnnualizedReturn() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.double get volatility => $_getN(2);
  @$pb.TagNumber(3)
  set volatility($core.double value) => $_setDouble(2, value);
  @$pb.TagNumber(3)
  $core.bool hasVolatility() => $_has(2);
  @$pb.TagNumber(3)
  void clearVolatility() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.double get sharpeRatio => $_getN(3);
  @$pb.TagNumber(4)
  set sharpeRatio($core.double value) => $_setDouble(3, value);
  @$pb.TagNumber(4)
  $core.bool hasSharpeRatio() => $_has(3);
  @$pb.TagNumber(4)
  void clearSharpeRatio() => $_clearField(4);

  @$pb.TagNumber(5)
  $core.double get sortinoRatio => $_getN(4);
  @$pb.TagNumber(5)
  set sortinoRatio($core.double value) => $_setDouble(4, value);
  @$pb.TagNumber(5)
  $core.bool hasSortinoRatio() => $_has(4);
  @$pb.TagNumber(5)
  void clearSortinoRatio() => $_clearField(5);

  @$pb.TagNumber(6)
  $core.double get maxDrawdown => $_getN(5);
  @$pb.TagNumber(6)
  set maxDrawdown($core.double value) => $_setDouble(5, value);
  @$pb.TagNumber(6)
  $core.bool hasMaxDrawdown() => $_has(5);
  @$pb.TagNumber(6)
  void clearMaxDrawdown() => $_clearField(6);

  @$pb.TagNumber(7)
  $core.double get alpha => $_getN(6);
  @$pb.TagNumber(7)
  set alpha($core.double value) => $_setDouble(6, value);
  @$pb.TagNumber(7)
  $core.bool hasAlpha() => $_has(6);
  @$pb.TagNumber(7)
  void clearAlpha() => $_clearField(7);

  @$pb.TagNumber(8)
  $core.double get beta => $_getN(7);
  @$pb.TagNumber(8)
  set beta($core.double value) => $_setDouble(7, value);
  @$pb.TagNumber(8)
  $core.bool hasBeta() => $_has(7);
  @$pb.TagNumber(8)
  void clearBeta() => $_clearField(8);

  @$pb.TagNumber(9)
  $core.double get cagr => $_getN(8);
  @$pb.TagNumber(9)
  set cagr($core.double value) => $_setFloat(8, value);
  @$pb.TagNumber(9)
  $core.bool hasCagr() => $_has(8);
  @$pb.TagNumber(9)
  void clearCagr() => $_clearField(9);

  @$pb.TagNumber(10)
  $core.double get calmar => $_getN(9);
  @$pb.TagNumber(10)
  set calmar($core.double value) => $_setFloat(9, value);
  @$pb.TagNumber(10)
  $core.bool hasCalmar() => $_has(9);
  @$pb.TagNumber(10)
  void clearCalmar() => $_clearField(10);

  @$pb.TagNumber(11)
  $core.double get correlation => $_getN(10);
  @$pb.TagNumber(11)
  set correlation($core.double value) => $_setFloat(10, value);
  @$pb.TagNumber(11)
  $core.bool hasCorrelation() => $_has(10);
  @$pb.TagNumber(11)
  void clearCorrelation() => $_clearField(11);

  @$pb.TagNumber(12)
  $core.double get trackingError => $_getN(11);
  @$pb.TagNumber(12)
  set trackingError($core.double value) => $_setFloat(11, value);
  @$pb.TagNumber(12)
  $core.bool hasTrackingError() => $_has(11);
  @$pb.TagNumber(12)
  void clearTrackingError() => $_clearField(12);

  @$pb.TagNumber(13)
  $core.double get trackingDiff => $_getN(12);
  @$pb.TagNumber(13)
  set trackingDiff($core.double value) => $_setFloat(12, value);
  @$pb.TagNumber(13)
  $core.bool hasTrackingDiff() => $_has(12);
  @$pb.TagNumber(13)
  void clearTrackingDiff() => $_clearField(13);

  @$pb.TagNumber(14)
  $core.double get expenseRatio => $_getN(13);
  @$pb.TagNumber(14)
  set expenseRatio($core.double value) => $_setFloat(13, value);
  @$pb.TagNumber(14)
  $core.bool hasExpenseRatio() => $_has(13);
  @$pb.TagNumber(14)
  void clearExpenseRatio() => $_clearField(14);

  @$pb.TagNumber(15)
  $core.double get bidAskSpread => $_getN(14);
  @$pb.TagNumber(15)
  set bidAskSpread($core.double value) => $_setFloat(14, value);
  @$pb.TagNumber(15)
  $core.bool hasBidAskSpread() => $_has(14);
  @$pb.TagNumber(15)
  void clearBidAskSpread() => $_clearField(15);

  @$pb.TagNumber(16)
  $core.double get concentration => $_getN(15);
  @$pb.TagNumber(16)
  set concentration($core.double value) => $_setFloat(15, value);
  @$pb.TagNumber(16)
  $core.bool hasConcentration() => $_has(15);
  @$pb.TagNumber(16)
  void clearConcentration() => $_clearField(16);

  @$pb.TagNumber(17)
  $core.double get dividendYield => $_getN(16);
  @$pb.TagNumber(17)
  set dividendYield($core.double value) => $_setFloat(16, value);
  @$pb.TagNumber(17)
  $core.bool hasDividendYield() => $_has(16);
  @$pb.TagNumber(17)
  void clearDividendYield() => $_clearField(17);
}

/// Equity curve data point over time
class EquityCurvePoint extends $pb.GeneratedMessage {
  factory EquityCurvePoint({
    $3.Timestamp? timestamp,
    $core.double? portfolioValue,
    $core.double? drawdown,
  }) {
    final result = create();
    if (timestamp != null) result.timestamp = timestamp;
    if (portfolioValue != null) result.portfolioValue = portfolioValue;
    if (drawdown != null) result.drawdown = drawdown;
    return result;
  }

  EquityCurvePoint._();

  factory EquityCurvePoint.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory EquityCurvePoint.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'EquityCurvePoint',
      package: const $pb.PackageName(
          _omitMessageNames ? '' : 'trading.portfolio.analytics'),
      createEmptyInstance: create)
    ..aOM<$3.Timestamp>(1, _omitFieldNames ? '' : 'timestamp',
        subBuilder: $3.Timestamp.create)
    ..aD(2, _omitFieldNames ? '' : 'portfolioValue')
    ..aD(3, _omitFieldNames ? '' : 'drawdown')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  EquityCurvePoint clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  EquityCurvePoint copyWith(void Function(EquityCurvePoint) updates) =>
      super.copyWith((message) => updates(message as EquityCurvePoint))
          as EquityCurvePoint;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static EquityCurvePoint create() => EquityCurvePoint._();
  @$core.override
  EquityCurvePoint createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static EquityCurvePoint getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<EquityCurvePoint>(create);
  static EquityCurvePoint? _defaultInstance;

  @$pb.TagNumber(1)
  $3.Timestamp get timestamp => $_getN(0);
  @$pb.TagNumber(1)
  set timestamp($3.Timestamp value) => $_setField(1, value);
  @$pb.TagNumber(1)
  $core.bool hasTimestamp() => $_has(0);
  @$pb.TagNumber(1)
  void clearTimestamp() => $_clearField(1);
  @$pb.TagNumber(1)
  $3.Timestamp ensureTimestamp() => $_ensure(0);

  @$pb.TagNumber(2)
  $core.double get portfolioValue => $_getN(1);
  @$pb.TagNumber(2)
  set portfolioValue($core.double value) => $_setDouble(1, value);
  @$pb.TagNumber(2)
  $core.bool hasPortfolioValue() => $_has(1);
  @$pb.TagNumber(2)
  void clearPortfolioValue() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.double get drawdown => $_getN(2);
  @$pb.TagNumber(3)
  set drawdown($core.double value) => $_setDouble(2, value);
  @$pb.TagNumber(3)
  $core.bool hasDrawdown() => $_has(2);
  @$pb.TagNumber(3)
  void clearDrawdown() => $_clearField(3);
}

/// Request payload for single evaluation execution
class EvaluatePortfolioRequest extends $pb.GeneratedMessage {
  factory EvaluatePortfolioRequest({
    Portfolio? portfolio,
    $3.Timestamp? startDate,
    $3.Timestamp? endDate,
    $core.Iterable<AssetAllocation>? allocations,
    StrategyConfig? strategyConfig,
  }) {
    final result = create();
    if (portfolio != null) result.portfolio = portfolio;
    if (startDate != null) result.startDate = startDate;
    if (endDate != null) result.endDate = endDate;
    if (allocations != null) result.allocations.addAll(allocations);
    if (strategyConfig != null) result.strategyConfig = strategyConfig;
    return result;
  }

  EvaluatePortfolioRequest._();

  factory EvaluatePortfolioRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory EvaluatePortfolioRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'EvaluatePortfolioRequest',
      package: const $pb.PackageName(
          _omitMessageNames ? '' : 'trading.portfolio.analytics'),
      createEmptyInstance: create)
    ..aOM<Portfolio>(1, _omitFieldNames ? '' : 'portfolio',
        subBuilder: Portfolio.create)
    ..aOM<$3.Timestamp>(2, _omitFieldNames ? '' : 'startDate',
        subBuilder: $3.Timestamp.create)
    ..aOM<$3.Timestamp>(3, _omitFieldNames ? '' : 'endDate',
        subBuilder: $3.Timestamp.create)
    ..pPM<AssetAllocation>(4, _omitFieldNames ? '' : 'allocations',
        subBuilder: AssetAllocation.create)
    ..aOM<StrategyConfig>(5, _omitFieldNames ? '' : 'strategyConfig',
        subBuilder: StrategyConfig.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  EvaluatePortfolioRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  EvaluatePortfolioRequest copyWith(
          void Function(EvaluatePortfolioRequest) updates) =>
      super.copyWith((message) => updates(message as EvaluatePortfolioRequest))
          as EvaluatePortfolioRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static EvaluatePortfolioRequest create() => EvaluatePortfolioRequest._();
  @$core.override
  EvaluatePortfolioRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static EvaluatePortfolioRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<EvaluatePortfolioRequest>(create);
  static EvaluatePortfolioRequest? _defaultInstance;

  @$pb.TagNumber(1)
  Portfolio get portfolio => $_getN(0);
  @$pb.TagNumber(1)
  set portfolio(Portfolio value) => $_setField(1, value);
  @$pb.TagNumber(1)
  $core.bool hasPortfolio() => $_has(0);
  @$pb.TagNumber(1)
  void clearPortfolio() => $_clearField(1);
  @$pb.TagNumber(1)
  Portfolio ensurePortfolio() => $_ensure(0);

  @$pb.TagNumber(2)
  $3.Timestamp get startDate => $_getN(1);
  @$pb.TagNumber(2)
  set startDate($3.Timestamp value) => $_setField(2, value);
  @$pb.TagNumber(2)
  $core.bool hasStartDate() => $_has(1);
  @$pb.TagNumber(2)
  void clearStartDate() => $_clearField(2);
  @$pb.TagNumber(2)
  $3.Timestamp ensureStartDate() => $_ensure(1);

  @$pb.TagNumber(3)
  $3.Timestamp get endDate => $_getN(2);
  @$pb.TagNumber(3)
  set endDate($3.Timestamp value) => $_setField(3, value);
  @$pb.TagNumber(3)
  $core.bool hasEndDate() => $_has(2);
  @$pb.TagNumber(3)
  void clearEndDate() => $_clearField(3);
  @$pb.TagNumber(3)
  $3.Timestamp ensureEndDate() => $_ensure(2);

  @$pb.TagNumber(4)
  $pb.PbList<AssetAllocation> get allocations => $_getList(3);

  @$pb.TagNumber(5)
  StrategyConfig get strategyConfig => $_getN(4);
  @$pb.TagNumber(5)
  set strategyConfig(StrategyConfig value) => $_setField(5, value);
  @$pb.TagNumber(5)
  $core.bool hasStrategyConfig() => $_has(4);
  @$pb.TagNumber(5)
  void clearStrategyConfig() => $_clearField(5);
  @$pb.TagNumber(5)
  StrategyConfig ensureStrategyConfig() => $_ensure(4);
}

/// Response payload containing completed analytics compilation
class EvaluatePortfolioResponse extends $pb.GeneratedMessage {
  factory EvaluatePortfolioResponse({
    $core.String? portfolioId,
    PerformanceMetrics? summaryMetrics,
    $core.Iterable<EquityCurvePoint>? equityCurve,
    $3.Timestamp? calculatedAt,
  }) {
    final result = create();
    if (portfolioId != null) result.portfolioId = portfolioId;
    if (summaryMetrics != null) result.summaryMetrics = summaryMetrics;
    if (equityCurve != null) result.equityCurve.addAll(equityCurve);
    if (calculatedAt != null) result.calculatedAt = calculatedAt;
    return result;
  }

  EvaluatePortfolioResponse._();

  factory EvaluatePortfolioResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory EvaluatePortfolioResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'EvaluatePortfolioResponse',
      package: const $pb.PackageName(
          _omitMessageNames ? '' : 'trading.portfolio.analytics'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'portfolioId')
    ..aOM<PerformanceMetrics>(2, _omitFieldNames ? '' : 'summaryMetrics',
        subBuilder: PerformanceMetrics.create)
    ..pPM<EquityCurvePoint>(3, _omitFieldNames ? '' : 'equityCurve',
        subBuilder: EquityCurvePoint.create)
    ..aOM<$3.Timestamp>(4, _omitFieldNames ? '' : 'calculatedAt',
        subBuilder: $3.Timestamp.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  EvaluatePortfolioResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  EvaluatePortfolioResponse copyWith(
          void Function(EvaluatePortfolioResponse) updates) =>
      super.copyWith((message) => updates(message as EvaluatePortfolioResponse))
          as EvaluatePortfolioResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static EvaluatePortfolioResponse create() => EvaluatePortfolioResponse._();
  @$core.override
  EvaluatePortfolioResponse createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static EvaluatePortfolioResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<EvaluatePortfolioResponse>(create);
  static EvaluatePortfolioResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get portfolioId => $_getSZ(0);
  @$pb.TagNumber(1)
  set portfolioId($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasPortfolioId() => $_has(0);
  @$pb.TagNumber(1)
  void clearPortfolioId() => $_clearField(1);

  @$pb.TagNumber(2)
  PerformanceMetrics get summaryMetrics => $_getN(1);
  @$pb.TagNumber(2)
  set summaryMetrics(PerformanceMetrics value) => $_setField(2, value);
  @$pb.TagNumber(2)
  $core.bool hasSummaryMetrics() => $_has(1);
  @$pb.TagNumber(2)
  void clearSummaryMetrics() => $_clearField(2);
  @$pb.TagNumber(2)
  PerformanceMetrics ensureSummaryMetrics() => $_ensure(1);

  @$pb.TagNumber(3)
  $pb.PbList<EquityCurvePoint> get equityCurve => $_getList(2);

  @$pb.TagNumber(4)
  $3.Timestamp get calculatedAt => $_getN(3);
  @$pb.TagNumber(4)
  set calculatedAt($3.Timestamp value) => $_setField(4, value);
  @$pb.TagNumber(4)
  $core.bool hasCalculatedAt() => $_has(3);
  @$pb.TagNumber(4)
  void clearCalculatedAt() => $_clearField(4);
  @$pb.TagNumber(4)
  $3.Timestamp ensureCalculatedAt() => $_ensure(3);
}

/// Request payload for progressive streaming backtest execution
class StreamBacktestRequest extends $pb.GeneratedMessage {
  factory StreamBacktestRequest({
    Portfolio? portfolio,
    $3.Timestamp? startDate,
    $3.Timestamp? endDate,
    $core.Iterable<AssetAllocation>? allocations,
    StrategyConfig? strategyConfig,
    $core.double? initialCapital,
  }) {
    final result = create();
    if (portfolio != null) result.portfolio = portfolio;
    if (startDate != null) result.startDate = startDate;
    if (endDate != null) result.endDate = endDate;
    if (allocations != null) result.allocations.addAll(allocations);
    if (strategyConfig != null) result.strategyConfig = strategyConfig;
    if (initialCapital != null) result.initialCapital = initialCapital;
    return result;
  }

  StreamBacktestRequest._();

  factory StreamBacktestRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory StreamBacktestRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'StreamBacktestRequest',
      package: const $pb.PackageName(
          _omitMessageNames ? '' : 'trading.portfolio.analytics'),
      createEmptyInstance: create)
    ..aOM<Portfolio>(1, _omitFieldNames ? '' : 'portfolio',
        subBuilder: Portfolio.create)
    ..aOM<$3.Timestamp>(2, _omitFieldNames ? '' : 'startDate',
        subBuilder: $3.Timestamp.create)
    ..aOM<$3.Timestamp>(3, _omitFieldNames ? '' : 'endDate',
        subBuilder: $3.Timestamp.create)
    ..pPM<AssetAllocation>(4, _omitFieldNames ? '' : 'allocations',
        subBuilder: AssetAllocation.create)
    ..aOM<StrategyConfig>(5, _omitFieldNames ? '' : 'strategyConfig',
        subBuilder: StrategyConfig.create)
    ..aD(7, _omitFieldNames ? '' : 'initialCapital')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  StreamBacktestRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  StreamBacktestRequest copyWith(
          void Function(StreamBacktestRequest) updates) =>
      super.copyWith((message) => updates(message as StreamBacktestRequest))
          as StreamBacktestRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static StreamBacktestRequest create() => StreamBacktestRequest._();
  @$core.override
  StreamBacktestRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static StreamBacktestRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<StreamBacktestRequest>(create);
  static StreamBacktestRequest? _defaultInstance;

  @$pb.TagNumber(1)
  Portfolio get portfolio => $_getN(0);
  @$pb.TagNumber(1)
  set portfolio(Portfolio value) => $_setField(1, value);
  @$pb.TagNumber(1)
  $core.bool hasPortfolio() => $_has(0);
  @$pb.TagNumber(1)
  void clearPortfolio() => $_clearField(1);
  @$pb.TagNumber(1)
  Portfolio ensurePortfolio() => $_ensure(0);

  @$pb.TagNumber(2)
  $3.Timestamp get startDate => $_getN(1);
  @$pb.TagNumber(2)
  set startDate($3.Timestamp value) => $_setField(2, value);
  @$pb.TagNumber(2)
  $core.bool hasStartDate() => $_has(1);
  @$pb.TagNumber(2)
  void clearStartDate() => $_clearField(2);
  @$pb.TagNumber(2)
  $3.Timestamp ensureStartDate() => $_ensure(1);

  @$pb.TagNumber(3)
  $3.Timestamp get endDate => $_getN(2);
  @$pb.TagNumber(3)
  set endDate($3.Timestamp value) => $_setField(3, value);
  @$pb.TagNumber(3)
  $core.bool hasEndDate() => $_has(2);
  @$pb.TagNumber(3)
  void clearEndDate() => $_clearField(3);
  @$pb.TagNumber(3)
  $3.Timestamp ensureEndDate() => $_ensure(2);

  @$pb.TagNumber(4)
  $pb.PbList<AssetAllocation> get allocations => $_getList(3);

  @$pb.TagNumber(5)
  StrategyConfig get strategyConfig => $_getN(4);
  @$pb.TagNumber(5)
  set strategyConfig(StrategyConfig value) => $_setField(5, value);
  @$pb.TagNumber(5)
  $core.bool hasStrategyConfig() => $_has(4);
  @$pb.TagNumber(5)
  void clearStrategyConfig() => $_clearField(5);
  @$pb.TagNumber(5)
  StrategyConfig ensureStrategyConfig() => $_ensure(4);

  @$pb.TagNumber(7)
  $core.double get initialCapital => $_getN(5);
  @$pb.TagNumber(7)
  set initialCapital($core.double value) => $_setDouble(5, value);
  @$pb.TagNumber(7)
  $core.bool hasInitialCapital() => $_has(5);
  @$pb.TagNumber(7)
  void clearInitialCapital() => $_clearField(7);
}

/// Incremental update message emitted during streaming backtests
class StreamBacktestResponse extends $pb.GeneratedMessage {
  factory StreamBacktestResponse({
    $core.String? portfolioId,
    $3.Timestamp? currentSimulatedDate,
    $core.double? currentPortfolioValue,
    PerformanceMetrics? runningMetrics,
    $core.bool? isCompleted,
  }) {
    final result = create();
    if (portfolioId != null) result.portfolioId = portfolioId;
    if (currentSimulatedDate != null)
      result.currentSimulatedDate = currentSimulatedDate;
    if (currentPortfolioValue != null)
      result.currentPortfolioValue = currentPortfolioValue;
    if (runningMetrics != null) result.runningMetrics = runningMetrics;
    if (isCompleted != null) result.isCompleted = isCompleted;
    return result;
  }

  StreamBacktestResponse._();

  factory StreamBacktestResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory StreamBacktestResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'StreamBacktestResponse',
      package: const $pb.PackageName(
          _omitMessageNames ? '' : 'trading.portfolio.analytics'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'portfolioId')
    ..aOM<$3.Timestamp>(2, _omitFieldNames ? '' : 'currentSimulatedDate',
        subBuilder: $3.Timestamp.create)
    ..aD(3, _omitFieldNames ? '' : 'currentPortfolioValue')
    ..aOM<PerformanceMetrics>(4, _omitFieldNames ? '' : 'runningMetrics',
        subBuilder: PerformanceMetrics.create)
    ..aOB(5, _omitFieldNames ? '' : 'isCompleted')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  StreamBacktestResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  StreamBacktestResponse copyWith(
          void Function(StreamBacktestResponse) updates) =>
      super.copyWith((message) => updates(message as StreamBacktestResponse))
          as StreamBacktestResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static StreamBacktestResponse create() => StreamBacktestResponse._();
  @$core.override
  StreamBacktestResponse createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static StreamBacktestResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<StreamBacktestResponse>(create);
  static StreamBacktestResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get portfolioId => $_getSZ(0);
  @$pb.TagNumber(1)
  set portfolioId($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasPortfolioId() => $_has(0);
  @$pb.TagNumber(1)
  void clearPortfolioId() => $_clearField(1);

  @$pb.TagNumber(2)
  $3.Timestamp get currentSimulatedDate => $_getN(1);
  @$pb.TagNumber(2)
  set currentSimulatedDate($3.Timestamp value) => $_setField(2, value);
  @$pb.TagNumber(2)
  $core.bool hasCurrentSimulatedDate() => $_has(1);
  @$pb.TagNumber(2)
  void clearCurrentSimulatedDate() => $_clearField(2);
  @$pb.TagNumber(2)
  $3.Timestamp ensureCurrentSimulatedDate() => $_ensure(1);

  @$pb.TagNumber(3)
  $core.double get currentPortfolioValue => $_getN(2);
  @$pb.TagNumber(3)
  set currentPortfolioValue($core.double value) => $_setDouble(2, value);
  @$pb.TagNumber(3)
  $core.bool hasCurrentPortfolioValue() => $_has(2);
  @$pb.TagNumber(3)
  void clearCurrentPortfolioValue() => $_clearField(3);

  @$pb.TagNumber(4)
  PerformanceMetrics get runningMetrics => $_getN(3);
  @$pb.TagNumber(4)
  set runningMetrics(PerformanceMetrics value) => $_setField(4, value);
  @$pb.TagNumber(4)
  $core.bool hasRunningMetrics() => $_has(3);
  @$pb.TagNumber(4)
  void clearRunningMetrics() => $_clearField(4);
  @$pb.TagNumber(4)
  PerformanceMetrics ensureRunningMetrics() => $_ensure(3);

  @$pb.TagNumber(5)
  $core.bool get isCompleted => $_getBF(4);
  @$pb.TagNumber(5)
  set isCompleted($core.bool value) => $_setBool(4, value);
  @$pb.TagNumber(5)
  $core.bool hasIsCompleted() => $_has(4);
  @$pb.TagNumber(5)
  void clearIsCompleted() => $_clearField(5);
}

const $core.bool _omitFieldNames =
    $core.bool.fromEnvironment('protobuf.omit_field_names');
const $core.bool _omitMessageNames =
    $core.bool.fromEnvironment('protobuf.omit_message_names');
