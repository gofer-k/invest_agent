// This is a generated file - do not edit.
//
// Generated from invest_agent.proto.

// @dart = 3.3

// ignore_for_file: annotate_overrides, camel_case_types, comment_references
// ignore_for_file: constant_identifier_names
// ignore_for_file: curly_braces_in_flow_control_structures
// ignore_for_file: deprecated_member_use_from_same_package, library_prefixes
// ignore_for_file: non_constant_identifier_names, prefer_relative_imports
// ignore_for_file: unused_import

import 'dart:convert' as $convert;
import 'dart:core' as $core;
import 'dart:typed_data' as $typed_data;

import 'package:protobuf/well_known_types/google/protobuf/struct.pbjson.dart'
    as $1;
import 'package:protobuf/well_known_types/google/protobuf/timestamp.pbjson.dart'
    as $0;

@$core.Deprecated('Use indicatorTypeDescriptor instead')
const IndicatorType$json = {
  '1': 'IndicatorType',
  '2': [
    {'1': 'UNDEFINED', '2': 0},
    {'1': 'PRICE', '2': 1},
    {'1': 'BOLLINGER_BANDS', '2': 2},
    {'1': 'SMA', '2': 3},
    {'1': 'EMA', '2': 4},
    {'1': 'MACD', '2': 5},
    {'1': 'RSI', '2': 6},
    {'1': 'VOLUME', '2': 7},
    {'1': 'KST', '2': 8},
    {'1': 'ROC', '2': 9},
  ],
};

/// Descriptor for `IndicatorType`. Decode as a `google.protobuf.EnumDescriptorProto`.
final $typed_data.Uint8List indicatorTypeDescriptor = $convert.base64Decode(
    'Cg1JbmRpY2F0b3JUeXBlEg0KCVVOREVGSU5FRBAAEgkKBVBSSUNFEAESEwoPQk9MTElOR0VSX0'
    'JBTkRTEAISBwoDU01BEAMSBwoDRU1BEAQSCAoETUFDRBAFEgcKA1JTSRAGEgoKBlZPTFVNRRAH'
    'EgcKA0tTVBAIEgcKA1JPQxAJ');

@$core.Deprecated('Use indexPriceItemDescriptor instead')
const IndexPriceItem$json = {
  '1': 'IndexPriceItem',
  '2': [
    {'1': 'id', '3': 1, '4': 1, '5': 5, '10': 'id'},
    {'1': 'asset_id', '3': 2, '4': 1, '5': 5, '10': 'assetId'},
    {'1': 'open', '3': 3, '4': 1, '5': 1, '10': 'open'},
    {'1': 'high', '3': 4, '4': 1, '5': 1, '10': 'high'},
    {'1': 'low', '3': 5, '4': 1, '5': 1, '10': 'low'},
    {'1': 'close', '3': 6, '4': 1, '5': 1, '10': 'close'},
    {'1': 'volume', '3': 7, '4': 1, '5': 1, '10': 'volume'},
    {
      '1': 'date_time',
      '3': 8,
      '4': 1,
      '5': 11,
      '6': '.google.protobuf.Timestamp',
      '10': 'dateTime'
    },
  ],
};

/// Descriptor for `IndexPriceItem`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List indexPriceItemDescriptor = $convert.base64Decode(
    'Cg5JbmRleFByaWNlSXRlbRIOCgJpZBgBIAEoBVICaWQSGQoIYXNzZXRfaWQYAiABKAVSB2Fzc2'
    'V0SWQSEgoEb3BlbhgDIAEoAVIEb3BlbhISCgRoaWdoGAQgASgBUgRoaWdoEhAKA2xvdxgFIAEo'
    'AVIDbG93EhQKBWNsb3NlGAYgASgBUgVjbG9zZRIWCgZ2b2x1bWUYByABKAFSBnZvbHVtZRI3Cg'
    'lkYXRlX3RpbWUYCCABKAsyGi5nb29nbGUucHJvdG9idWYuVGltZXN0YW1wUghkYXRlVGltZQ==');

@$core.Deprecated('Use indicatorDescriptor instead')
const Indicator$json = {
  '1': 'Indicator',
  '2': [
    {'1': 'id', '3': 1, '4': 1, '5': 5, '10': 'id'},
    {'1': 'name', '3': 2, '4': 1, '5': 9, '10': 'name'},
    {
      '1': 'type',
      '3': 3,
      '4': 1,
      '5': 14,
      '6': '.trading.IndicatorType',
      '10': 'type'
    },
    {
      '1': 'parameters',
      '3': 4,
      '4': 1,
      '5': 11,
      '6': '.google.protobuf.Struct',
      '10': 'parameters'
    },
  ],
};

/// Descriptor for `Indicator`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List indicatorDescriptor = $convert.base64Decode(
    'CglJbmRpY2F0b3ISDgoCaWQYASABKAVSAmlkEhIKBG5hbWUYAiABKAlSBG5hbWUSKgoEdHlwZR'
    'gDIAEoDjIWLnRyYWRpbmcuSW5kaWNhdG9yVHlwZVIEdHlwZRI3CgpwYXJhbWV0ZXJzGAQgASgL'
    'MhcuZ29vZ2xlLnByb3RvYnVmLlN0cnVjdFIKcGFyYW1ldGVycw==');

@$core.Deprecated('Use tradingRequestDescriptor instead')
const TradingRequest$json = {
  '1': 'TradingRequest',
  '2': [
    {
      '1': 'prices',
      '3': 1,
      '4': 3,
      '5': 11,
      '6': '.trading.IndexPriceItem',
      '10': 'prices'
    },
    {
      '1': 'indicators',
      '3': 2,
      '4': 3,
      '5': 11,
      '6': '.trading.Indicator',
      '10': 'indicators'
    },
  ],
};

/// Descriptor for `TradingRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List tradingRequestDescriptor = $convert.base64Decode(
    'Cg5UcmFkaW5nUmVxdWVzdBIvCgZwcmljZXMYASADKAsyFy50cmFkaW5nLkluZGV4UHJpY2VJdG'
    'VtUgZwcmljZXMSMgoKaW5kaWNhdG9ycxgCIAMoCzISLnRyYWRpbmcuSW5kaWNhdG9yUgppbmRp'
    'Y2F0b3Jz');

@$core.Deprecated('Use tradingResponseDescriptor instead')
const TradingResponse$json = {
  '1': 'TradingResponse',
  '2': [
    {
      '1': 'results',
      '3': 1,
      '4': 3,
      '5': 11,
      '6': '.trading.TradingResponse.ResultsEntry',
      '10': 'results'
    },
  ],
  '3': [TradingResponse_ResultsEntry$json],
};

@$core.Deprecated('Use tradingResponseDescriptor instead')
const TradingResponse_ResultsEntry$json = {
  '1': 'ResultsEntry',
  '2': [
    {'1': 'key', '3': 1, '4': 1, '5': 9, '10': 'key'},
    {
      '1': 'value',
      '3': 2,
      '4': 1,
      '5': 11,
      '6': '.trading.IndicatorResultList',
      '10': 'value'
    },
  ],
  '7': {'7': true},
};

/// Descriptor for `TradingResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List tradingResponseDescriptor = $convert.base64Decode(
    'Cg9UcmFkaW5nUmVzcG9uc2USPwoHcmVzdWx0cxgBIAMoCzIlLnRyYWRpbmcuVHJhZGluZ1Jlc3'
    'BvbnNlLlJlc3VsdHNFbnRyeVIHcmVzdWx0cxpYCgxSZXN1bHRzRW50cnkSEAoDa2V5GAEgASgJ'
    'UgNrZXkSMgoFdmFsdWUYAiABKAsyHC50cmFkaW5nLkluZGljYXRvclJlc3VsdExpc3RSBXZhbH'
    'VlOgI4AQ==');

@$core.Deprecated('Use indicatorResultListDescriptor instead')
const IndicatorResultList$json = {
  '1': 'IndicatorResultList',
  '2': [
    {
      '1': 'items',
      '3': 1,
      '4': 3,
      '5': 11,
      '6': '.trading.IndicatorSeries',
      '10': 'items'
    },
  ],
};

/// Descriptor for `IndicatorResultList`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List indicatorResultListDescriptor = $convert.base64Decode(
    'ChNJbmRpY2F0b3JSZXN1bHRMaXN0Ei4KBWl0ZW1zGAEgAygLMhgudHJhZGluZy5JbmRpY2F0b3'
    'JTZXJpZXNSBWl0ZW1z');

@$core.Deprecated('Use indicatorSeriesDescriptor instead')
const IndicatorSeries$json = {
  '1': 'IndicatorSeries',
  '2': [
    {'1': 'chart_style', '3': 1, '4': 1, '5': 9, '10': 'chartStyle'},
    {
      '1': 'config',
      '3': 2,
      '4': 1,
      '5': 11,
      '6': '.trading.Indicator',
      '10': 'config'
    },
    {
      '1': 'points',
      '3': 3,
      '4': 3,
      '5': 11,
      '6': '.trading.IndicatorPoint',
      '10': 'points'
    },
  ],
};

/// Descriptor for `IndicatorSeries`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List indicatorSeriesDescriptor = $convert.base64Decode(
    'Cg9JbmRpY2F0b3JTZXJpZXMSHwoLY2hhcnRfc3R5bGUYASABKAlSCmNoYXJ0U3R5bGUSKgoGY2'
    '9uZmlnGAIgASgLMhIudHJhZGluZy5JbmRpY2F0b3JSBmNvbmZpZxIvCgZwb2ludHMYAyADKAsy'
    'Fy50cmFkaW5nLkluZGljYXRvclBvaW50UgZwb2ludHM=');

@$core.Deprecated('Use indicatorPointDescriptor instead')
const IndicatorPoint$json = {
  '1': 'IndicatorPoint',
  '2': [
    {
      '1': 'date_time',
      '3': 1,
      '4': 1,
      '5': 11,
      '6': '.google.protobuf.Timestamp',
      '10': 'dateTime'
    },
    {
      '1': 'values',
      '3': 2,
      '4': 3,
      '5': 11,
      '6': '.trading.IndicatorPoint.ValuesEntry',
      '10': 'values'
    },
  ],
  '3': [IndicatorPoint_ValuesEntry$json],
};

@$core.Deprecated('Use indicatorPointDescriptor instead')
const IndicatorPoint_ValuesEntry$json = {
  '1': 'ValuesEntry',
  '2': [
    {'1': 'key', '3': 1, '4': 1, '5': 9, '10': 'key'},
    {'1': 'value', '3': 2, '4': 1, '5': 1, '10': 'value'},
  ],
  '7': {'7': true},
};

/// Descriptor for `IndicatorPoint`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List indicatorPointDescriptor = $convert.base64Decode(
    'Cg5JbmRpY2F0b3JQb2ludBI3CglkYXRlX3RpbWUYASABKAsyGi5nb29nbGUucHJvdG9idWYuVG'
    'ltZXN0YW1wUghkYXRlVGltZRI7CgZ2YWx1ZXMYAiADKAsyIy50cmFkaW5nLkluZGljYXRvclBv'
    'aW50LlZhbHVlc0VudHJ5UgZ2YWx1ZXMaOQoLVmFsdWVzRW50cnkSEAoDa2V5GAEgASgJUgNrZX'
    'kSFAoFdmFsdWUYAiABKAFSBXZhbHVlOgI4AQ==');

const $core.Map<$core.String, $core.dynamic> InvestAgentServiceBase$json = {
  '1': 'InvestAgentService',
  '2': [
    {
      '1': 'CalculateIndicators',
      '2': '.trading.TradingRequest',
      '3': '.trading.TradingResponse',
      '5': true,
      '6': true
    },
  ],
};

@$core.Deprecated('Use investAgentServiceDescriptor instead')
const $core.Map<$core.String, $core.Map<$core.String, $core.dynamic>>
    InvestAgentServiceBase$messageJson = {
  '.trading.TradingRequest': TradingRequest$json,
  '.trading.IndexPriceItem': IndexPriceItem$json,
  '.google.protobuf.Timestamp': $0.Timestamp$json,
  '.trading.Indicator': Indicator$json,
  '.google.protobuf.Struct': $1.Struct$json,
  '.google.protobuf.Struct.FieldsEntry': $1.Struct_FieldsEntry$json,
  '.google.protobuf.Value': $1.Value$json,
  '.google.protobuf.ListValue': $1.ListValue$json,
  '.trading.TradingResponse': TradingResponse$json,
  '.trading.TradingResponse.ResultsEntry': TradingResponse_ResultsEntry$json,
  '.trading.IndicatorResultList': IndicatorResultList$json,
  '.trading.IndicatorSeries': IndicatorSeries$json,
  '.trading.IndicatorPoint': IndicatorPoint$json,
  '.trading.IndicatorPoint.ValuesEntry': IndicatorPoint_ValuesEntry$json,
};

/// Descriptor for `InvestAgentService`. Decode as a `google.protobuf.ServiceDescriptorProto`.
final $typed_data.Uint8List investAgentServiceDescriptor = $convert.base64Decode(
    'ChJJbnZlc3RBZ2VudFNlcnZpY2USTAoTQ2FsY3VsYXRlSW5kaWNhdG9ycxIXLnRyYWRpbmcuVH'
    'JhZGluZ1JlcXVlc3QaGC50cmFkaW5nLlRyYWRpbmdSZXNwb25zZSgBMAE=');
