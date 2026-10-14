// This is a generated file - do not edit.
//
// Generated from price.proto.

// @dart = 3.3

// ignore_for_file: annotate_overrides, camel_case_types, comment_references
// ignore_for_file: constant_identifier_names
// ignore_for_file: curly_braces_in_flow_control_structures
// ignore_for_file: deprecated_member_use_from_same_package, library_prefixes
// ignore_for_file: non_constant_identifier_names, prefer_relative_imports

import 'dart:core' as $core;

import 'package:protobuf/protobuf.dart' as $pb;
import 'package:protobuf/well_known_types/google/protobuf/timestamp.pb.dart'
    as $0;

export 'package:protobuf/protobuf.dart' show GeneratedMessageGenericExtensions;

/// Maps to lib/model/price_result.dart: IndexPriceItem
class IndexPriceItem extends $pb.GeneratedMessage {
  factory IndexPriceItem({
    $core.int? id,
    $core.int? assetId,
    $core.double? open,
    $core.double? high,
    $core.double? low,
    $core.double? close,
    $core.double? volume,
    $0.Timestamp? dateTime,
  }) {
    final result = create();
    if (id != null) result.id = id;
    if (assetId != null) result.assetId = assetId;
    if (open != null) result.open = open;
    if (high != null) result.high = high;
    if (low != null) result.low = low;
    if (close != null) result.close = close;
    if (volume != null) result.volume = volume;
    if (dateTime != null) result.dateTime = dateTime;
    return result;
  }

  IndexPriceItem._();

  factory IndexPriceItem.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory IndexPriceItem.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'IndexPriceItem',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'trading.price'),
      createEmptyInstance: create)
    ..aI(1, _omitFieldNames ? '' : 'id')
    ..aI(2, _omitFieldNames ? '' : 'assetId')
    ..aD(3, _omitFieldNames ? '' : 'open')
    ..aD(4, _omitFieldNames ? '' : 'high')
    ..aD(5, _omitFieldNames ? '' : 'low')
    ..aD(6, _omitFieldNames ? '' : 'close')
    ..aD(7, _omitFieldNames ? '' : 'volume')
    ..aOM<$0.Timestamp>(8, _omitFieldNames ? '' : 'dateTime',
        subBuilder: $0.Timestamp.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  IndexPriceItem clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  IndexPriceItem copyWith(void Function(IndexPriceItem) updates) =>
      super.copyWith((message) => updates(message as IndexPriceItem))
          as IndexPriceItem;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static IndexPriceItem create() => IndexPriceItem._();
  @$core.override
  IndexPriceItem createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static IndexPriceItem getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<IndexPriceItem>(create);
  static IndexPriceItem? _defaultInstance;

  @$pb.TagNumber(1)
  $core.int get id => $_getIZ(0);
  @$pb.TagNumber(1)
  set id($core.int value) => $_setSignedInt32(0, value);
  @$pb.TagNumber(1)
  $core.bool hasId() => $_has(0);
  @$pb.TagNumber(1)
  void clearId() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.int get assetId => $_getIZ(1);
  @$pb.TagNumber(2)
  set assetId($core.int value) => $_setSignedInt32(1, value);
  @$pb.TagNumber(2)
  $core.bool hasAssetId() => $_has(1);
  @$pb.TagNumber(2)
  void clearAssetId() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.double get open => $_getN(2);
  @$pb.TagNumber(3)
  set open($core.double value) => $_setDouble(2, value);
  @$pb.TagNumber(3)
  $core.bool hasOpen() => $_has(2);
  @$pb.TagNumber(3)
  void clearOpen() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.double get high => $_getN(3);
  @$pb.TagNumber(4)
  set high($core.double value) => $_setDouble(3, value);
  @$pb.TagNumber(4)
  $core.bool hasHigh() => $_has(3);
  @$pb.TagNumber(4)
  void clearHigh() => $_clearField(4);

  @$pb.TagNumber(5)
  $core.double get low => $_getN(4);
  @$pb.TagNumber(5)
  set low($core.double value) => $_setDouble(4, value);
  @$pb.TagNumber(5)
  $core.bool hasLow() => $_has(4);
  @$pb.TagNumber(5)
  void clearLow() => $_clearField(5);

  @$pb.TagNumber(6)
  $core.double get close => $_getN(5);
  @$pb.TagNumber(6)
  set close($core.double value) => $_setDouble(5, value);
  @$pb.TagNumber(6)
  $core.bool hasClose() => $_has(5);
  @$pb.TagNumber(6)
  void clearClose() => $_clearField(6);

  @$pb.TagNumber(7)
  $core.double get volume => $_getN(6);
  @$pb.TagNumber(7)
  set volume($core.double value) => $_setDouble(6, value);
  @$pb.TagNumber(7)
  $core.bool hasVolume() => $_has(6);
  @$pb.TagNumber(7)
  void clearVolume() => $_clearField(7);

  @$pb.TagNumber(8)
  $0.Timestamp get dateTime => $_getN(7);
  @$pb.TagNumber(8)
  set dateTime($0.Timestamp value) => $_setField(8, value);
  @$pb.TagNumber(8)
  $core.bool hasDateTime() => $_has(7);
  @$pb.TagNumber(8)
  void clearDateTime() => $_clearField(8);
  @$pb.TagNumber(8)
  $0.Timestamp ensureDateTime() => $_ensure(7);
}

const $core.bool _omitFieldNames =
    $core.bool.fromEnvironment('protobuf.omit_field_names');
const $core.bool _omitMessageNames =
    $core.bool.fromEnvironment('protobuf.omit_message_names');
