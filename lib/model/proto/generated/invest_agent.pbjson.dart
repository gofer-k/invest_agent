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

@$core.Deprecated('Use tradingRequestDescriptor instead')
const TradingRequest$json = {
  '1': 'TradingRequest',
  '2': [
    {
      '1': 'prices',
      '3': 1,
      '4': 3,
      '5': 11,
      '6': '.trading.price.IndexPriceItem',
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
    'Cg5UcmFkaW5nUmVxdWVzdBI1CgZwcmljZXMYASADKAsyHS50cmFkaW5nLnByaWNlLkluZGV4UH'
    'JpY2VJdGVtUgZwcmljZXMSPQoKaW5kaWNhdG9ycxgCIAMoCzIdLnRyYWRpbmcuaW5kaWNhdG9y'
    'cy5JbmRpY2F0b3JSCmluZGljYXRvcnM=');

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
