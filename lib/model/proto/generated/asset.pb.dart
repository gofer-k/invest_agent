// This is a generated file - do not edit.
//
// Generated from asset.proto.

// @dart = 3.3

// ignore_for_file: annotate_overrides, camel_case_types, comment_references
// ignore_for_file: constant_identifier_names
// ignore_for_file: curly_braces_in_flow_control_structures
// ignore_for_file: deprecated_member_use_from_same_package, library_prefixes
// ignore_for_file: non_constant_identifier_names, prefer_relative_imports

import 'dart:core' as $core;

import 'package:protobuf/protobuf.dart' as $pb;

export 'package:protobuf/protobuf.dart' show GeneratedMessageGenericExtensions;

class Asset extends $pb.GeneratedMessage {
  factory Asset({
    $core.int? id,
    $core.String? symbol,
    $core.String? currencyCode,
    $core.String? rype,
    $core.String? assetTypeDetails,
  }) {
    final result = create();
    if (id != null) result.id = id;
    if (symbol != null) result.symbol = symbol;
    if (currencyCode != null) result.currencyCode = currencyCode;
    if (rype != null) result.rype = rype;
    if (assetTypeDetails != null) result.assetTypeDetails = assetTypeDetails;
    return result;
  }

  Asset._();

  factory Asset.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory Asset.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'Asset',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'trading.asset'),
      createEmptyInstance: create)
    ..aI(1, _omitFieldNames ? '' : 'id')
    ..aOS(2, _omitFieldNames ? '' : 'symbol')
    ..aOS(3, _omitFieldNames ? '' : 'currencyCode', protoName: 'currencyCode')
    ..aOS(4, _omitFieldNames ? '' : 'rype')
    ..aOS(5, _omitFieldNames ? '' : 'assetTypeDetails',
        protoName: 'assetTypeDetails')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  Asset clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  Asset copyWith(void Function(Asset) updates) =>
      super.copyWith((message) => updates(message as Asset)) as Asset;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static Asset create() => Asset._();
  @$core.override
  Asset createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static Asset getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<Asset>(create);
  static Asset? _defaultInstance;

  @$pb.TagNumber(1)
  $core.int get id => $_getIZ(0);
  @$pb.TagNumber(1)
  set id($core.int value) => $_setSignedInt32(0, value);
  @$pb.TagNumber(1)
  $core.bool hasId() => $_has(0);
  @$pb.TagNumber(1)
  void clearId() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get symbol => $_getSZ(1);
  @$pb.TagNumber(2)
  set symbol($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasSymbol() => $_has(1);
  @$pb.TagNumber(2)
  void clearSymbol() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.String get currencyCode => $_getSZ(2);
  @$pb.TagNumber(3)
  set currencyCode($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasCurrencyCode() => $_has(2);
  @$pb.TagNumber(3)
  void clearCurrencyCode() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.String get rype => $_getSZ(3);
  @$pb.TagNumber(4)
  set rype($core.String value) => $_setString(3, value);
  @$pb.TagNumber(4)
  $core.bool hasRype() => $_has(3);
  @$pb.TagNumber(4)
  void clearRype() => $_clearField(4);

  @$pb.TagNumber(5)
  $core.String get assetTypeDetails => $_getSZ(4);
  @$pb.TagNumber(5)
  set assetTypeDetails($core.String value) => $_setString(4, value);
  @$pb.TagNumber(5)
  $core.bool hasAssetTypeDetails() => $_has(4);
  @$pb.TagNumber(5)
  void clearAssetTypeDetails() => $_clearField(5);
}

class AssetsRequest extends $pb.GeneratedMessage {
  factory AssetsRequest({
    $core.Iterable<Asset>? assets,
  }) {
    final result = create();
    if (assets != null) result.assets.addAll(assets);
    return result;
  }

  AssetsRequest._();

  factory AssetsRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory AssetsRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'AssetsRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'trading.asset'),
      createEmptyInstance: create)
    ..pPM<Asset>(1, _omitFieldNames ? '' : 'assets', subBuilder: Asset.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  AssetsRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  AssetsRequest copyWith(void Function(AssetsRequest) updates) =>
      super.copyWith((message) => updates(message as AssetsRequest))
          as AssetsRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static AssetsRequest create() => AssetsRequest._();
  @$core.override
  AssetsRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static AssetsRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<AssetsRequest>(create);
  static AssetsRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $pb.PbList<Asset> get assets => $_getList(0);
}

const $core.bool _omitFieldNames =
    $core.bool.fromEnvironment('protobuf.omit_field_names');
const $core.bool _omitMessageNames =
    $core.bool.fromEnvironment('protobuf.omit_message_names');
