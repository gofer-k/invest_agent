// This is a generated file - do not edit.
//
// Generated from indicators.proto.

// @dart = 3.3

// ignore_for_file: annotate_overrides, camel_case_types, comment_references
// ignore_for_file: constant_identifier_names
// ignore_for_file: curly_braces_in_flow_control_structures
// ignore_for_file: deprecated_member_use_from_same_package, library_prefixes
// ignore_for_file: non_constant_identifier_names, prefer_relative_imports

import 'dart:core' as $core;

import 'package:protobuf/protobuf.dart' as $pb;
import 'package:protobuf/well_known_types/google/protobuf/struct.pb.dart' as $0;
import 'package:protobuf/well_known_types/google/protobuf/timestamp.pb.dart'
    as $1;

import 'indicators.pbenum.dart';

export 'package:protobuf/protobuf.dart' show GeneratedMessageGenericExtensions;

export 'indicators.pbenum.dart';

/// Maps to lib/model/indicator_schema.dart: Indicator
class Indicator extends $pb.GeneratedMessage {
  factory Indicator({
    $core.int? id,
    $core.String? name,
    IndicatorType? type,
    $0.Struct? parameters,
  }) {
    final result = create();
    if (id != null) result.id = id;
    if (name != null) result.name = name;
    if (type != null) result.type = type;
    if (parameters != null) result.parameters = parameters;
    return result;
  }

  Indicator._();

  factory Indicator.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory Indicator.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'Indicator',
      package:
          const $pb.PackageName(_omitMessageNames ? '' : 'trading.indicators'),
      createEmptyInstance: create)
    ..aI(1, _omitFieldNames ? '' : 'id')
    ..aOS(2, _omitFieldNames ? '' : 'name')
    ..aE<IndicatorType>(3, _omitFieldNames ? '' : 'type',
        enumValues: IndicatorType.values)
    ..aOM<$0.Struct>(4, _omitFieldNames ? '' : 'parameters',
        subBuilder: $0.Struct.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  Indicator clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  Indicator copyWith(void Function(Indicator) updates) =>
      super.copyWith((message) => updates(message as Indicator)) as Indicator;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static Indicator create() => Indicator._();
  @$core.override
  Indicator createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static Indicator getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<Indicator>(create);
  static Indicator? _defaultInstance;

  @$pb.TagNumber(1)
  $core.int get id => $_getIZ(0);
  @$pb.TagNumber(1)
  set id($core.int value) => $_setSignedInt32(0, value);
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
  IndicatorType get type => $_getN(2);
  @$pb.TagNumber(3)
  set type(IndicatorType value) => $_setField(3, value);
  @$pb.TagNumber(3)
  $core.bool hasType() => $_has(2);
  @$pb.TagNumber(3)
  void clearType() => $_clearField(3);

  /// Dynamic parameters (Map<String, dynamic>)
  @$pb.TagNumber(4)
  $0.Struct get parameters => $_getN(3);
  @$pb.TagNumber(4)
  set parameters($0.Struct value) => $_setField(4, value);
  @$pb.TagNumber(4)
  $core.bool hasParameters() => $_has(3);
  @$pb.TagNumber(4)
  void clearParameters() => $_clearField(4);
  @$pb.TagNumber(4)
  $0.Struct ensureParameters() => $_ensure(3);
}

/// Represents List<BaseIndicatorResult>
class IndicatorResultList extends $pb.GeneratedMessage {
  factory IndicatorResultList({
    $core.Iterable<IndicatorSeries>? items,
  }) {
    final result = create();
    if (items != null) result.items.addAll(items);
    return result;
  }

  IndicatorResultList._();

  factory IndicatorResultList.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory IndicatorResultList.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'IndicatorResultList',
      package:
          const $pb.PackageName(_omitMessageNames ? '' : 'trading.indicators'),
      createEmptyInstance: create)
    ..pPM<IndicatorSeries>(1, _omitFieldNames ? '' : 'items',
        subBuilder: IndicatorSeries.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  IndicatorResultList clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  IndicatorResultList copyWith(void Function(IndicatorResultList) updates) =>
      super.copyWith((message) => updates(message as IndicatorResultList))
          as IndicatorResultList;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static IndicatorResultList create() => IndicatorResultList._();
  @$core.override
  IndicatorResultList createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static IndicatorResultList getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<IndicatorResultList>(create);
  static IndicatorResultList? _defaultInstance;

  @$pb.TagNumber(1)
  $pb.PbList<IndicatorSeries> get items => $_getList(0);
}

/// Represents a single BaseIndicatorResult (e.g., a specific SMA series)
class IndicatorSeries extends $pb.GeneratedMessage {
  factory IndicatorSeries({
    $core.String? chartStyle,
    Indicator? config,
    $core.Iterable<IndicatorPoint>? points,
  }) {
    final result = create();
    if (chartStyle != null) result.chartStyle = chartStyle;
    if (config != null) result.config = config;
    if (points != null) result.points.addAll(points);
    return result;
  }

  IndicatorSeries._();

  factory IndicatorSeries.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory IndicatorSeries.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'IndicatorSeries',
      package:
          const $pb.PackageName(_omitMessageNames ? '' : 'trading.indicators'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'chartStyle')
    ..aOM<Indicator>(2, _omitFieldNames ? '' : 'config',
        subBuilder: Indicator.create)
    ..pPM<IndicatorPoint>(3, _omitFieldNames ? '' : 'points',
        subBuilder: IndicatorPoint.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  IndicatorSeries clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  IndicatorSeries copyWith(void Function(IndicatorSeries) updates) =>
      super.copyWith((message) => updates(message as IndicatorSeries))
          as IndicatorSeries;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static IndicatorSeries create() => IndicatorSeries._();
  @$core.override
  IndicatorSeries createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static IndicatorSeries getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<IndicatorSeries>(create);
  static IndicatorSeries? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get chartStyle => $_getSZ(0);
  @$pb.TagNumber(1)
  set chartStyle($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasChartStyle() => $_has(0);
  @$pb.TagNumber(1)
  void clearChartStyle() => $_clearField(1);

  @$pb.TagNumber(2)
  Indicator get config => $_getN(1);
  @$pb.TagNumber(2)
  set config(Indicator value) => $_setField(2, value);
  @$pb.TagNumber(2)
  $core.bool hasConfig() => $_has(1);
  @$pb.TagNumber(2)
  void clearConfig() => $_clearField(2);
  @$pb.TagNumber(2)
  Indicator ensureConfig() => $_ensure(1);

  @$pb.TagNumber(3)
  $pb.PbList<IndicatorPoint> get points => $_getList(2);
}

/// Represents a single point in the series (BaseIndicatorValue)
class IndicatorPoint extends $pb.GeneratedMessage {
  factory IndicatorPoint({
    $1.Timestamp? dateTime,
    $core.Iterable<$core.MapEntry<$core.String, $core.double>>? values,
  }) {
    final result = create();
    if (dateTime != null) result.dateTime = dateTime;
    if (values != null) result.values.addEntries(values);
    return result;
  }

  IndicatorPoint._();

  factory IndicatorPoint.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory IndicatorPoint.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'IndicatorPoint',
      package:
          const $pb.PackageName(_omitMessageNames ? '' : 'trading.indicators'),
      createEmptyInstance: create)
    ..aOM<$1.Timestamp>(1, _omitFieldNames ? '' : 'dateTime',
        subBuilder: $1.Timestamp.create)
    ..m<$core.String, $core.double>(2, _omitFieldNames ? '' : 'values',
        entryClassName: 'IndicatorPoint.ValuesEntry',
        keyFieldType: $pb.PbFieldType.OS,
        valueFieldType: $pb.PbFieldType.OD,
        packageName: const $pb.PackageName('trading.indicators'))
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  IndicatorPoint clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  IndicatorPoint copyWith(void Function(IndicatorPoint) updates) =>
      super.copyWith((message) => updates(message as IndicatorPoint))
          as IndicatorPoint;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static IndicatorPoint create() => IndicatorPoint._();
  @$core.override
  IndicatorPoint createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static IndicatorPoint getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<IndicatorPoint>(create);
  static IndicatorPoint? _defaultInstance;

  @$pb.TagNumber(1)
  $1.Timestamp get dateTime => $_getN(0);
  @$pb.TagNumber(1)
  set dateTime($1.Timestamp value) => $_setField(1, value);
  @$pb.TagNumber(1)
  $core.bool hasDateTime() => $_has(0);
  @$pb.TagNumber(1)
  void clearDateTime() => $_clearField(1);
  @$pb.TagNumber(1)
  $1.Timestamp ensureDateTime() => $_ensure(0);

  /// Flexible map for varied results:
  /// e.g., {"mean": 150.0, "std": 2.5} for SMA, or {"value": 70.0} for RSI
  @$pb.TagNumber(2)
  $pb.PbMap<$core.String, $core.double> get values => $_getMap(1);
}

const $core.bool _omitFieldNames =
    $core.bool.fromEnvironment('protobuf.omit_field_names');
const $core.bool _omitMessageNames =
    $core.bool.fromEnvironment('protobuf.omit_message_names');
