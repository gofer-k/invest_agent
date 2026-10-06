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

import 'indicators.pb.dart' as $4;
import 'price.pb.dart' as $3;

export 'package:protobuf/protobuf.dart' show GeneratedMessageGenericExtensions;

/// Constraint 1: TradingRequest class definition
class TradingRequest extends $pb.GeneratedMessage {
  factory TradingRequest({
    $core.Iterable<$3.IndexPriceItem>? prices,
    $core.Iterable<$4.Indicator>? indicators,
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
    ..pPM<$4.Indicator>(2, _omitFieldNames ? '' : 'indicators',
        subBuilder: $4.Indicator.create)
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
  $pb.PbList<$4.Indicator> get indicators => $_getList(1);
}

/// Constraint 2: Compliable with IndicatorResultMap
/// (Map<IndicatorType, List<BaseIndicatorResult>>)
class TradingResponse extends $pb.GeneratedMessage {
  factory TradingResponse({
    $core.Iterable<$core.MapEntry<$core.String, $4.IndicatorResultList>>?
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
    ..m<$core.String, $4.IndicatorResultList>(
        1, _omitFieldNames ? '' : 'results',
        entryClassName: 'TradingResponse.ResultsEntry',
        keyFieldType: $pb.PbFieldType.OS,
        valueFieldType: $pb.PbFieldType.OM,
        valueCreator: $4.IndicatorResultList.create,
        valueDefaultOrMaker: $4.IndicatorResultList.getDefault,
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
  $pb.PbMap<$core.String, $4.IndicatorResultList> get results => $_getMap(0);
}

const $core.bool _omitFieldNames =
    $core.bool.fromEnvironment('protobuf.omit_field_names');
const $core.bool _omitMessageNames =
    $core.bool.fromEnvironment('protobuf.omit_message_names');
