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

@$core.Deprecated('Use strategyTypeDescriptor instead')
const StrategyType$json = {
  '1': 'StrategyType',
  '2': [
    {'1': 'EMPTY', '2': 0},
    {'1': 'ARBITARY', '2': 1},
    {'1': 'ASSETALLOCATION', '2': 2},
    {'1': 'GEM', '2': 3},
    {'1': 'MEANREVESION', '2': 4},
    {'1': 'INDEXFUNDREBALANCING', '2': 5},
    {'1': 'TRENDfOLLOWING', '2': 6},
  ],
};

/// Descriptor for `StrategyType`. Decode as a `google.protobuf.EnumDescriptorProto`.
final $typed_data.Uint8List strategyTypeDescriptor = $convert.base64Decode(
    'CgxTdHJhdGVneVR5cGUSCQoFRU1QVFkQABIMCghBUkJJVEFSWRABEhMKD0FTU0VUQUxMT0NBVE'
    'lPThACEgcKA0dFTRADEhAKDE1FQU5SRVZFU0lPThAEEhgKFElOREVYRlVORFJFQkFMQU5DSU5H'
    'EAUSEgoOVFJFTkRmT0xMT1dJTkcQBg==');

@$core.Deprecated('Use tradingRequestDescriptor instead')
const TradingRequest$json = {
  '1': 'TradingRequest',
  '2': [
    {
      '1': 'prices',
      '3': 1,
      '4': 3,
      '5': 11,
      '6': '.trading.indicators.IndexPriceItem',
      '10': 'prices'
    },
    {
      '1': 'indicators',
      '3': 2,
      '4': 3,
      '5': 11,
      '6': '.trading.indicators.Indicator',
      '10': 'indicators'
    },
  ],
};

/// Descriptor for `TradingRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List tradingRequestDescriptor = $convert.base64Decode(
    'Cg5UcmFkaW5nUmVxdWVzdBI6CgZwcmljZXMYASADKAsyIi50cmFkaW5nLmluZGljYXRvcnMuSW'
    '5kZXhQcmljZUl0ZW1SBnByaWNlcxI9CgppbmRpY2F0b3JzGAIgAygLMh0udHJhZGluZy5pbmRp'
    'Y2F0b3JzLkluZGljYXRvclIKaW5kaWNhdG9ycw==');

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
      '6': '.trading.indicators.IndicatorResultList',
      '10': 'value'
    },
  ],
  '7': {'7': true},
};

/// Descriptor for `TradingResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List tradingResponseDescriptor = $convert.base64Decode(
    'Cg9UcmFkaW5nUmVzcG9uc2USPwoHcmVzdWx0cxgBIAMoCzIlLnRyYWRpbmcuVHJhZGluZ1Jlc3'
    'BvbnNlLlJlc3VsdHNFbnRyeVIHcmVzdWx0cxpjCgxSZXN1bHRzRW50cnkSEAoDa2V5GAEgASgJ'
    'UgNrZXkSPQoFdmFsdWUYAiABKAsyJy50cmFkaW5nLmluZGljYXRvcnMuSW5kaWNhdG9yUmVzdW'
    'x0TGlzdFIFdmFsdWU6AjgB');

@$core.Deprecated('Use strategyRequestDescriptor instead')
const StrategyRequest$json = {
  '1': 'StrategyRequest',
  '2': [
    {'1': 'id', '3': 1, '4': 1, '5': 5, '10': 'id'},
    {
      '1': 'type',
      '3': 2,
      '4': 1,
      '5': 14,
      '6': '.trading.StrategyType',
      '10': 'type'
    },
    {'1': 'capital', '3': 3, '4': 1, '5': 1, '10': 'capital'},
    {
      '1': 'begin_date',
      '3': 4,
      '4': 1,
      '5': 11,
      '6': '.google.protobuf.Timestamp',
      '10': 'beginDate'
    },
    {
      '1': 'end_date',
      '3': 5,
      '4': 1,
      '5': 11,
      '6': '.google.protobuf.Timestamp',
      '10': 'endDate'
    },
    {'1': 'loopback', '3': 6, '4': 1, '5': 5, '10': 'loopback'},
    {'1': 'name', '3': 7, '4': 1, '5': 9, '10': 'name'},
    {'1': 'currency', '3': 8, '4': 1, '5': 9, '10': 'currency'},
    {
      '1': 'parameters',
      '3': 9,
      '4': 1,
      '5': 11,
      '6': '.google.protobuf.Struct',
      '10': 'parameters'
    },
  ],
};

/// Descriptor for `StrategyRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List strategyRequestDescriptor = $convert.base64Decode(
    'Cg9TdHJhdGVneVJlcXVlc3QSDgoCaWQYASABKAVSAmlkEikKBHR5cGUYAiABKA4yFS50cmFkaW'
    '5nLlN0cmF0ZWd5VHlwZVIEdHlwZRIYCgdjYXBpdGFsGAMgASgBUgdjYXBpdGFsEjkKCmJlZ2lu'
    'X2RhdGUYBCABKAsyGi5nb29nbGUucHJvdG9idWYuVGltZXN0YW1wUgliZWdpbkRhdGUSNQoIZW'
    '5kX2RhdGUYBSABKAsyGi5nb29nbGUucHJvdG9idWYuVGltZXN0YW1wUgdlbmREYXRlEhoKCGxv'
    'b3BiYWNrGAYgASgFUghsb29wYmFjaxISCgRuYW1lGAcgASgJUgRuYW1lEhoKCGN1cnJlbmN5GA'
    'ggASgJUghjdXJyZW5jeRI3CgpwYXJhbWV0ZXJzGAkgASgLMhcuZ29vZ2xlLnByb3RvYnVmLlN0'
    'cnVjdFIKcGFyYW1ldGVycw==');

@$core.Deprecated('Use strategyResponseDescriptor instead')
const StrategyResponse$json = {
  '1': 'StrategyResponse',
  '2': [
    {'1': 'Strategy_id', '3': 1, '4': 1, '5': 5, '10': 'StrategyId'},
    {'1': 'cagr', '3': 2, '4': 1, '5': 2, '10': 'cagr'},
    {'1': 'volatility', '3': 3, '4': 1, '5': 2, '10': 'volatility'},
    {'1': 'sharpe', '3': 4, '4': 1, '5': 2, '10': 'sharpe'},
    {'1': 'max_drawdown', '3': 5, '4': 1, '5': 2, '10': 'maxDrawdown'},
    {'1': 'sortino', '3': 6, '4': 1, '5': 2, '10': 'sortino'},
    {'1': 'calmar', '3': 7, '4': 1, '5': 2, '10': 'calmar'},
    {'1': 'beta', '3': 8, '4': 1, '5': 2, '10': 'beta'},
    {'1': 'correlation', '3': 9, '4': 1, '5': 2, '10': 'correlation'},
    {'1': 'tracking_error', '3': 10, '4': 1, '5': 2, '10': 'trackingError'},
    {'1': 'tracking_diff', '3': 11, '4': 1, '5': 2, '10': 'trackingDiff'},
    {'1': 'expense_ratio', '3': 12, '4': 1, '5': 2, '10': 'expenseRatio'},
    {'1': 'bid_ask_spread', '3': 13, '4': 1, '5': 2, '10': 'bidAskSpread'},
    {'1': 'concentration', '3': 14, '4': 1, '5': 2, '10': 'concentration'},
    {'1': 'dividend_yield', '3': 15, '4': 1, '5': 2, '10': 'dividendYield'},
    {'1': 'total_return', '3': 16, '4': 1, '5': 2, '10': 'totalReturn'},
  ],
};

/// Descriptor for `StrategyResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List strategyResponseDescriptor = $convert.base64Decode(
    'ChBTdHJhdGVneVJlc3BvbnNlEh8KC1N0cmF0ZWd5X2lkGAEgASgFUgpTdHJhdGVneUlkEhIKBG'
    'NhZ3IYAiABKAJSBGNhZ3ISHgoKdm9sYXRpbGl0eRgDIAEoAlIKdm9sYXRpbGl0eRIWCgZzaGFy'
    'cGUYBCABKAJSBnNoYXJwZRIhCgxtYXhfZHJhd2Rvd24YBSABKAJSC21heERyYXdkb3duEhgKB3'
    'NvcnRpbm8YBiABKAJSB3NvcnRpbm8SFgoGY2FsbWFyGAcgASgCUgZjYWxtYXISEgoEYmV0YRgI'
    'IAEoAlIEYmV0YRIgCgtjb3JyZWxhdGlvbhgJIAEoAlILY29ycmVsYXRpb24SJQoOdHJhY2tpbm'
    'dfZXJyb3IYCiABKAJSDXRyYWNraW5nRXJyb3ISIwoNdHJhY2tpbmdfZGlmZhgLIAEoAlIMdHJh'
    'Y2tpbmdEaWZmEiMKDWV4cGVuc2VfcmF0aW8YDCABKAJSDGV4cGVuc2VSYXRpbxIkCg5iaWRfYX'
    'NrX3NwcmVhZBgNIAEoAlIMYmlkQXNrU3ByZWFkEiQKDWNvbmNlbnRyYXRpb24YDiABKAJSDWNv'
    'bmNlbnRyYXRpb24SJQoOZGl2aWRlbmRfeWllbGQYDyABKAJSDWRpdmlkZW5kWWllbGQSIQoMdG'
    '90YWxfcmV0dXJuGBAgASgCUgt0b3RhbFJldHVybg==');
