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

/// Maps to lib/model/indicator_schema.dart: IndicatorType
class IndicatorType extends $pb.ProtobufEnum {
  static const IndicatorType UNDEFINED =
      IndicatorType._(0, _omitEnumNames ? '' : 'UNDEFINED');
  static const IndicatorType PRICE =
      IndicatorType._(1, _omitEnumNames ? '' : 'PRICE');
  static const IndicatorType BOLLINGER_BANDS =
      IndicatorType._(2, _omitEnumNames ? '' : 'BOLLINGER_BANDS');
  static const IndicatorType SMA =
      IndicatorType._(3, _omitEnumNames ? '' : 'SMA');
  static const IndicatorType EMA =
      IndicatorType._(4, _omitEnumNames ? '' : 'EMA');
  static const IndicatorType MACD =
      IndicatorType._(5, _omitEnumNames ? '' : 'MACD');
  static const IndicatorType RSI =
      IndicatorType._(6, _omitEnumNames ? '' : 'RSI');
  static const IndicatorType VOLUME =
      IndicatorType._(7, _omitEnumNames ? '' : 'VOLUME');
  static const IndicatorType KST =
      IndicatorType._(8, _omitEnumNames ? '' : 'KST');
  static const IndicatorType ROC =
      IndicatorType._(9, _omitEnumNames ? '' : 'ROC');

  static const $core.List<IndicatorType> values = <IndicatorType>[
    UNDEFINED,
    PRICE,
    BOLLINGER_BANDS,
    SMA,
    EMA,
    MACD,
    RSI,
    VOLUME,
    KST,
    ROC,
  ];

  static final $core.List<IndicatorType?> _byValue =
      $pb.ProtobufEnum.$_initByValueList(values, 9);
  static IndicatorType? valueOf($core.int value) =>
      value < 0 || value >= _byValue.length ? null : _byValue[value];

  const IndicatorType._(super.value, super.name);
}

const $core.bool _omitEnumNames =
    $core.bool.fromEnvironment('protobuf.omit_enum_names');
