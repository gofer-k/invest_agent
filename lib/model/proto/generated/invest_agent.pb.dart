// This is a generated file - do not edit.
//
// Generated from invest_agent.proto.

// @dart = 3.3

// ignore_for_file: annotate_overrides, camel_case_types, comment_references
// ignore_for_file: constant_identifier_names
// ignore_for_file: curly_braces_in_flow_control_structures
// ignore_for_file: deprecated_member_use_from_same_package, library_prefixes
// ignore_for_file: non_constant_identifier_names, prefer_relative_imports

import 'dart:core' as $core;

import 'package:protobuf/protobuf.dart' as $pb;
import 'package:protobuf/well_known_types/google/protobuf/struct.pb.dart' as $5;
import 'package:protobuf/well_known_types/google/protobuf/timestamp.pb.dart'
    as $4;

import 'indicators.pb.dart' as $3;
import 'invest_agent.pbenum.dart';

export 'package:protobuf/protobuf.dart' show GeneratedMessageGenericExtensions;

export 'invest_agent.pbenum.dart';

/// Constraint 1: TradingRequest class definition
class TradingRequest extends $pb.GeneratedMessage {
  factory TradingRequest({
    $core.Iterable<$3.IndexPriceItem>? prices,
    $core.Iterable<$3.Indicator>? indicators,
  }) {
    final result = create();
    if (prices != null) result.prices.addAll(prices);
    if (indicators != null) result.indicators.addAll(indicators);
    return result;
  }

  TradingRequest._();

  factory TradingRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory TradingRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'TradingRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'trading'),
      createEmptyInstance: create)
    ..pPM<$3.IndexPriceItem>(1, _omitFieldNames ? '' : 'prices',
        subBuilder: $3.IndexPriceItem.create)
    ..pPM<$3.Indicator>(2, _omitFieldNames ? '' : 'indicators',
        subBuilder: $3.Indicator.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  TradingRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  TradingRequest copyWith(void Function(TradingRequest) updates) =>
      super.copyWith((message) => updates(message as TradingRequest))
          as TradingRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static TradingRequest create() => TradingRequest._();
  @$core.override
  TradingRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static TradingRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<TradingRequest>(create);
  static TradingRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $pb.PbList<$3.IndexPriceItem> get prices => $_getList(0);

  @$pb.TagNumber(2)
  $pb.PbList<$3.Indicator> get indicators => $_getList(1);
}

/// Constraint 2: Compliable with IndicatorResultMap
/// (Map<IndicatorType, List<BaseIndicatorResult>>)
class TradingResponse extends $pb.GeneratedMessage {
  factory TradingResponse({
    $core.Iterable<$core.MapEntry<$core.String, $3.IndicatorResultList>>?
        results,
  }) {
    final result = create();
    if (results != null) result.results.addEntries(results);
    return result;
  }

  TradingResponse._();

  factory TradingResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory TradingResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'TradingResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'trading'),
      createEmptyInstance: create)
    ..m<$core.String, $3.IndicatorResultList>(
        1, _omitFieldNames ? '' : 'results',
        entryClassName: 'TradingResponse.ResultsEntry',
        keyFieldType: $pb.PbFieldType.OS,
        valueFieldType: $pb.PbFieldType.OM,
        valueCreator: $3.IndicatorResultList.create,
        valueDefaultOrMaker: $3.IndicatorResultList.getDefault,
        packageName: const $pb.PackageName('trading'))
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  TradingResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  TradingResponse copyWith(void Function(TradingResponse) updates) =>
      super.copyWith((message) => updates(message as TradingResponse))
          as TradingResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static TradingResponse create() => TradingResponse._();
  @$core.override
  TradingResponse createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static TradingResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<TradingResponse>(create);
  static TradingResponse? _defaultInstance;

  /// Key is the IndicatorType (as a string or integer)
  /// We use string key to map easily to IndicatorType.name
  @$pb.TagNumber(1)
  $pb.PbMap<$core.String, $3.IndicatorResultList> get results => $_getMap(0);
}

class StrategyRequest extends $pb.GeneratedMessage {
  factory StrategyRequest({
    $core.int? id,
    StrategyType? type,
    $core.double? capital,
    $4.Timestamp? beginDate,
    $4.Timestamp? endDate,
    $core.int? loopback,
    $core.String? name,
    $core.String? currency,
    $5.Struct? parameters,
  }) {
    final result = create();
    if (id != null) result.id = id;
    if (type != null) result.type = type;
    if (capital != null) result.capital = capital;
    if (beginDate != null) result.beginDate = beginDate;
    if (endDate != null) result.endDate = endDate;
    if (loopback != null) result.loopback = loopback;
    if (name != null) result.name = name;
    if (currency != null) result.currency = currency;
    if (parameters != null) result.parameters = parameters;
    return result;
  }

  StrategyRequest._();

  factory StrategyRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory StrategyRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'StrategyRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'trading'),
      createEmptyInstance: create)
    ..aI(1, _omitFieldNames ? '' : 'id')
    ..aE<StrategyType>(2, _omitFieldNames ? '' : 'type',
        enumValues: StrategyType.values)
    ..aD(3, _omitFieldNames ? '' : 'capital')
    ..aOM<$4.Timestamp>(4, _omitFieldNames ? '' : 'beginDate',
        subBuilder: $4.Timestamp.create)
    ..aOM<$4.Timestamp>(5, _omitFieldNames ? '' : 'endDate',
        subBuilder: $4.Timestamp.create)
    ..aI(6, _omitFieldNames ? '' : 'loopback')
    ..aOS(7, _omitFieldNames ? '' : 'name')
    ..aOS(8, _omitFieldNames ? '' : 'currency')
    ..aOM<$5.Struct>(9, _omitFieldNames ? '' : 'parameters',
        subBuilder: $5.Struct.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  StrategyRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  StrategyRequest copyWith(void Function(StrategyRequest) updates) =>
      super.copyWith((message) => updates(message as StrategyRequest))
          as StrategyRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static StrategyRequest create() => StrategyRequest._();
  @$core.override
  StrategyRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static StrategyRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<StrategyRequest>(create);
  static StrategyRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.int get id => $_getIZ(0);
  @$pb.TagNumber(1)
  set id($core.int value) => $_setSignedInt32(0, value);
  @$pb.TagNumber(1)
  $core.bool hasId() => $_has(0);
  @$pb.TagNumber(1)
  void clearId() => $_clearField(1);

  @$pb.TagNumber(2)
  StrategyType get type => $_getN(1);
  @$pb.TagNumber(2)
  set type(StrategyType value) => $_setField(2, value);
  @$pb.TagNumber(2)
  $core.bool hasType() => $_has(1);
  @$pb.TagNumber(2)
  void clearType() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.double get capital => $_getN(2);
  @$pb.TagNumber(3)
  set capital($core.double value) => $_setDouble(2, value);
  @$pb.TagNumber(3)
  $core.bool hasCapital() => $_has(2);
  @$pb.TagNumber(3)
  void clearCapital() => $_clearField(3);

  @$pb.TagNumber(4)
  $4.Timestamp get beginDate => $_getN(3);
  @$pb.TagNumber(4)
  set beginDate($4.Timestamp value) => $_setField(4, value);
  @$pb.TagNumber(4)
  $core.bool hasBeginDate() => $_has(3);
  @$pb.TagNumber(4)
  void clearBeginDate() => $_clearField(4);
  @$pb.TagNumber(4)
  $4.Timestamp ensureBeginDate() => $_ensure(3);

  @$pb.TagNumber(5)
  $4.Timestamp get endDate => $_getN(4);
  @$pb.TagNumber(5)
  set endDate($4.Timestamp value) => $_setField(5, value);
  @$pb.TagNumber(5)
  $core.bool hasEndDate() => $_has(4);
  @$pb.TagNumber(5)
  void clearEndDate() => $_clearField(5);
  @$pb.TagNumber(5)
  $4.Timestamp ensureEndDate() => $_ensure(4);

  @$pb.TagNumber(6)
  $core.int get loopback => $_getIZ(5);
  @$pb.TagNumber(6)
  set loopback($core.int value) => $_setSignedInt32(5, value);
  @$pb.TagNumber(6)
  $core.bool hasLoopback() => $_has(5);
  @$pb.TagNumber(6)
  void clearLoopback() => $_clearField(6);

  @$pb.TagNumber(7)
  $core.String get name => $_getSZ(6);
  @$pb.TagNumber(7)
  set name($core.String value) => $_setString(6, value);
  @$pb.TagNumber(7)
  $core.bool hasName() => $_has(6);
  @$pb.TagNumber(7)
  void clearName() => $_clearField(7);

  @$pb.TagNumber(8)
  $core.String get currency => $_getSZ(7);
  @$pb.TagNumber(8)
  set currency($core.String value) => $_setString(7, value);
  @$pb.TagNumber(8)
  $core.bool hasCurrency() => $_has(7);
  @$pb.TagNumber(8)
  void clearCurrency() => $_clearField(8);

  @$pb.TagNumber(9)
  $5.Struct get parameters => $_getN(8);
  @$pb.TagNumber(9)
  set parameters($5.Struct value) => $_setField(9, value);
  @$pb.TagNumber(9)
  $core.bool hasParameters() => $_has(8);
  @$pb.TagNumber(9)
  void clearParameters() => $_clearField(9);
  @$pb.TagNumber(9)
  $5.Struct ensureParameters() => $_ensure(8);
}

/// Decision
/// US Equities
class StrategyResponse extends $pb.GeneratedMessage {
  factory StrategyResponse({
    $core.int? strategyId,
    $core.double? cagr,
    $core.double? volatility,
    $core.double? sharpe,
    $core.double? maxDrawdown,
    $core.double? sortino,
    $core.double? calmar,
    $core.double? beta,
    $core.double? correlation,
    $core.double? trackingError,
    $core.double? trackingDiff,
    $core.double? expenseRatio,
    $core.double? bidAskSpread,
    $core.double? concentration,
    $core.double? dividendYield,
    $core.double? totalReturn,
  }) {
    final result = create();
    if (strategyId != null) result.strategyId = strategyId;
    if (cagr != null) result.cagr = cagr;
    if (volatility != null) result.volatility = volatility;
    if (sharpe != null) result.sharpe = sharpe;
    if (maxDrawdown != null) result.maxDrawdown = maxDrawdown;
    if (sortino != null) result.sortino = sortino;
    if (calmar != null) result.calmar = calmar;
    if (beta != null) result.beta = beta;
    if (correlation != null) result.correlation = correlation;
    if (trackingError != null) result.trackingError = trackingError;
    if (trackingDiff != null) result.trackingDiff = trackingDiff;
    if (expenseRatio != null) result.expenseRatio = expenseRatio;
    if (bidAskSpread != null) result.bidAskSpread = bidAskSpread;
    if (concentration != null) result.concentration = concentration;
    if (dividendYield != null) result.dividendYield = dividendYield;
    if (totalReturn != null) result.totalReturn = totalReturn;
    return result;
  }

  StrategyResponse._();

  factory StrategyResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory StrategyResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'StrategyResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'trading'),
      createEmptyInstance: create)
    ..aI(1, _omitFieldNames ? '' : 'StrategyId', protoName: 'Strategy_id')
    ..aD(2, _omitFieldNames ? '' : 'cagr', fieldType: $pb.PbFieldType.OF)
    ..aD(3, _omitFieldNames ? '' : 'volatility', fieldType: $pb.PbFieldType.OF)
    ..aD(4, _omitFieldNames ? '' : 'sharpe', fieldType: $pb.PbFieldType.OF)
    ..aD(5, _omitFieldNames ? '' : 'maxDrawdown', fieldType: $pb.PbFieldType.OF)
    ..aD(6, _omitFieldNames ? '' : 'sortino', fieldType: $pb.PbFieldType.OF)
    ..aD(7, _omitFieldNames ? '' : 'calmar', fieldType: $pb.PbFieldType.OF)
    ..aD(8, _omitFieldNames ? '' : 'beta', fieldType: $pb.PbFieldType.OF)
    ..aD(9, _omitFieldNames ? '' : 'correlation', fieldType: $pb.PbFieldType.OF)
    ..aD(10, _omitFieldNames ? '' : 'trackingError',
        fieldType: $pb.PbFieldType.OF)
    ..aD(11, _omitFieldNames ? '' : 'trackingDiff',
        fieldType: $pb.PbFieldType.OF)
    ..aD(12, _omitFieldNames ? '' : 'expenseRatio',
        fieldType: $pb.PbFieldType.OF)
    ..aD(13, _omitFieldNames ? '' : 'bidAskSpread',
        fieldType: $pb.PbFieldType.OF)
    ..aD(14, _omitFieldNames ? '' : 'concentration',
        fieldType: $pb.PbFieldType.OF)
    ..aD(15, _omitFieldNames ? '' : 'dividendYield',
        fieldType: $pb.PbFieldType.OF)
    ..aD(16, _omitFieldNames ? '' : 'totalReturn',
        fieldType: $pb.PbFieldType.OF)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  StrategyResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  StrategyResponse copyWith(void Function(StrategyResponse) updates) =>
      super.copyWith((message) => updates(message as StrategyResponse))
          as StrategyResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static StrategyResponse create() => StrategyResponse._();
  @$core.override
  StrategyResponse createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static StrategyResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<StrategyResponse>(create);
  static StrategyResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $core.int get strategyId => $_getIZ(0);
  @$pb.TagNumber(1)
  set strategyId($core.int value) => $_setSignedInt32(0, value);
  @$pb.TagNumber(1)
  $core.bool hasStrategyId() => $_has(0);
  @$pb.TagNumber(1)
  void clearStrategyId() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.double get cagr => $_getN(1);
  @$pb.TagNumber(2)
  set cagr($core.double value) => $_setFloat(1, value);
  @$pb.TagNumber(2)
  $core.bool hasCagr() => $_has(1);
  @$pb.TagNumber(2)
  void clearCagr() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.double get volatility => $_getN(2);
  @$pb.TagNumber(3)
  set volatility($core.double value) => $_setFloat(2, value);
  @$pb.TagNumber(3)
  $core.bool hasVolatility() => $_has(2);
  @$pb.TagNumber(3)
  void clearVolatility() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.double get sharpe => $_getN(3);
  @$pb.TagNumber(4)
  set sharpe($core.double value) => $_setFloat(3, value);
  @$pb.TagNumber(4)
  $core.bool hasSharpe() => $_has(3);
  @$pb.TagNumber(4)
  void clearSharpe() => $_clearField(4);

  @$pb.TagNumber(5)
  $core.double get maxDrawdown => $_getN(4);
  @$pb.TagNumber(5)
  set maxDrawdown($core.double value) => $_setFloat(4, value);
  @$pb.TagNumber(5)
  $core.bool hasMaxDrawdown() => $_has(4);
  @$pb.TagNumber(5)
  void clearMaxDrawdown() => $_clearField(5);

  @$pb.TagNumber(6)
  $core.double get sortino => $_getN(5);
  @$pb.TagNumber(6)
  set sortino($core.double value) => $_setFloat(5, value);
  @$pb.TagNumber(6)
  $core.bool hasSortino() => $_has(5);
  @$pb.TagNumber(6)
  void clearSortino() => $_clearField(6);

  @$pb.TagNumber(7)
  $core.double get calmar => $_getN(6);
  @$pb.TagNumber(7)
  set calmar($core.double value) => $_setFloat(6, value);
  @$pb.TagNumber(7)
  $core.bool hasCalmar() => $_has(6);
  @$pb.TagNumber(7)
  void clearCalmar() => $_clearField(7);

  @$pb.TagNumber(8)
  $core.double get beta => $_getN(7);
  @$pb.TagNumber(8)
  set beta($core.double value) => $_setFloat(7, value);
  @$pb.TagNumber(8)
  $core.bool hasBeta() => $_has(7);
  @$pb.TagNumber(8)
  void clearBeta() => $_clearField(8);

  @$pb.TagNumber(9)
  $core.double get correlation => $_getN(8);
  @$pb.TagNumber(9)
  set correlation($core.double value) => $_setFloat(8, value);
  @$pb.TagNumber(9)
  $core.bool hasCorrelation() => $_has(8);
  @$pb.TagNumber(9)
  void clearCorrelation() => $_clearField(9);

  @$pb.TagNumber(10)
  $core.double get trackingError => $_getN(9);
  @$pb.TagNumber(10)
  set trackingError($core.double value) => $_setFloat(9, value);
  @$pb.TagNumber(10)
  $core.bool hasTrackingError() => $_has(9);
  @$pb.TagNumber(10)
  void clearTrackingError() => $_clearField(10);

  @$pb.TagNumber(11)
  $core.double get trackingDiff => $_getN(10);
  @$pb.TagNumber(11)
  set trackingDiff($core.double value) => $_setFloat(10, value);
  @$pb.TagNumber(11)
  $core.bool hasTrackingDiff() => $_has(10);
  @$pb.TagNumber(11)
  void clearTrackingDiff() => $_clearField(11);

  @$pb.TagNumber(12)
  $core.double get expenseRatio => $_getN(11);
  @$pb.TagNumber(12)
  set expenseRatio($core.double value) => $_setFloat(11, value);
  @$pb.TagNumber(12)
  $core.bool hasExpenseRatio() => $_has(11);
  @$pb.TagNumber(12)
  void clearExpenseRatio() => $_clearField(12);

  @$pb.TagNumber(13)
  $core.double get bidAskSpread => $_getN(12);
  @$pb.TagNumber(13)
  set bidAskSpread($core.double value) => $_setFloat(12, value);
  @$pb.TagNumber(13)
  $core.bool hasBidAskSpread() => $_has(12);
  @$pb.TagNumber(13)
  void clearBidAskSpread() => $_clearField(13);

  @$pb.TagNumber(14)
  $core.double get concentration => $_getN(13);
  @$pb.TagNumber(14)
  set concentration($core.double value) => $_setFloat(13, value);
  @$pb.TagNumber(14)
  $core.bool hasConcentration() => $_has(13);
  @$pb.TagNumber(14)
  void clearConcentration() => $_clearField(14);

  @$pb.TagNumber(15)
  $core.double get dividendYield => $_getN(14);
  @$pb.TagNumber(15)
  set dividendYield($core.double value) => $_setFloat(14, value);
  @$pb.TagNumber(15)
  $core.bool hasDividendYield() => $_has(14);
  @$pb.TagNumber(15)
  void clearDividendYield() => $_clearField(15);

  @$pb.TagNumber(16)
  $core.double get totalReturn => $_getN(15);
  @$pb.TagNumber(16)
  set totalReturn($core.double value) => $_setFloat(15, value);
  @$pb.TagNumber(16)
  $core.bool hasTotalReturn() => $_has(15);
  @$pb.TagNumber(16)
  void clearTotalReturn() => $_clearField(16);
}

const $core.bool _omitFieldNames =
    $core.bool.fromEnvironment('protobuf.omit_field_names');
const $core.bool _omitMessageNames =
    $core.bool.fromEnvironment('protobuf.omit_message_names');
