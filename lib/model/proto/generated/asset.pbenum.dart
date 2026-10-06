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

class AssetType extends $pb.ProtobufEnum {
  static const AssetType UNSPECIFIED =
      AssetType._(0, _omitEnumNames ? '' : 'UNSPECIFIED');
  static const AssetType US_EQUITY =
      AssetType._(1, _omitEnumNames ? '' : 'US_EQUITY');
  static const AssetType MSCI = AssetType._(2, _omitEnumNames ? '' : 'MSCI');
  static const AssetType MSCI_EX =
      AssetType._(3, _omitEnumNames ? '' : 'MSCI_EX');
  static const AssetType EM_EQUITY =
      AssetType._(4, _omitEnumNames ? '' : 'EM_EQUITY');
  static const AssetType POL_EQUIITY =
      AssetType._(5, _omitEnumNames ? '' : 'POL_EQUIITY');
  static const AssetType US_BOND =
      AssetType._(6, _omitEnumNames ? '' : 'US_BOND');
  static const AssetType POL_BONDS =
      AssetType._(7, _omitEnumNames ? '' : 'POL_BONDS');
  static const AssetType COMMODITY =
      AssetType._(8, _omitEnumNames ? '' : 'COMMODITY');
  static const AssetType CASH = AssetType._(9, _omitEnumNames ? '' : 'CASH');

  static const $core.List<AssetType> values = <AssetType>[
    UNSPECIFIED,
    US_EQUITY,
    MSCI,
    MSCI_EX,
    EM_EQUITY,
    POL_EQUIITY,
    US_BOND,
    POL_BONDS,
    COMMODITY,
    CASH,
  ];

  static final $core.List<AssetType?> _byValue =
      $pb.ProtobufEnum.$_initByValueList(values, 9);
  static AssetType? valueOf($core.int value) =>
      value < 0 || value >= _byValue.length ? null : _byValue[value];

  const AssetType._(super.value, super.name);
}

const $core.bool _omitEnumNames =
    $core.bool.fromEnvironment('protobuf.omit_enum_names');
