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

class StrategyType extends $pb.ProtobufEnum {
  static const StrategyType EMPTY =
      StrategyType._(0, _omitEnumNames ? '' : 'EMPTY');
  static const StrategyType ARBITARY =
      StrategyType._(1, _omitEnumNames ? '' : 'ARBITARY');
  static const StrategyType ASSETALLOCATION =
      StrategyType._(2, _omitEnumNames ? '' : 'ASSETALLOCATION');
  static const StrategyType GEM =
      StrategyType._(3, _omitEnumNames ? '' : 'GEM');
  static const StrategyType MEANREVESION =
      StrategyType._(4, _omitEnumNames ? '' : 'MEANREVESION');
  static const StrategyType INDEXFUNDREBALANCING =
      StrategyType._(5, _omitEnumNames ? '' : 'INDEXFUNDREBALANCING');
  static const StrategyType TRENDfOLLOWING =
      StrategyType._(6, _omitEnumNames ? '' : 'TRENDfOLLOWING');

  static const $core.List<StrategyType> values = <StrategyType>[
    EMPTY,
    ARBITARY,
    ASSETALLOCATION,
    GEM,
    MEANREVESION,
    INDEXFUNDREBALANCING,
    TRENDfOLLOWING,
  ];

  static final $core.List<StrategyType?> _byValue =
      $pb.ProtobufEnum.$_initByValueList(values, 6);
  static StrategyType? valueOf($core.int value) =>
      value < 0 || value >= _byValue.length ? null : _byValue[value];

  const StrategyType._(super.value, super.name);
}

const $core.bool _omitEnumNames =
    $core.bool.fromEnvironment('protobuf.omit_enum_names');
