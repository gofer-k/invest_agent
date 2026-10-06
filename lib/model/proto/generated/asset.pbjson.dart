// This is a generated file - do not edit.
//
// Generated from asset.proto.

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

@$core.Deprecated('Use assetTypeDescriptor instead')
const AssetType$json = {
  '1': 'AssetType',
  '2': [
    {'1': 'UNSPECIFIED', '2': 0},
    {'1': 'US_EQUITY', '2': 1},
    {'1': 'MSCI', '2': 2},
    {'1': 'MSCI_EX', '2': 3},
    {'1': 'EM_EQUITY', '2': 4},
    {'1': 'POL_EQUIITY', '2': 5},
    {'1': 'US_BOND', '2': 6},
    {'1': 'POL_BONDS', '2': 7},
    {'1': 'COMMODITY', '2': 8},
    {'1': 'CASH', '2': 9},
  ],
};

/// Descriptor for `AssetType`. Decode as a `google.protobuf.EnumDescriptorProto`.
final $typed_data.Uint8List assetTypeDescriptor = $convert.base64Decode(
    'CglBc3NldFR5cGUSDwoLVU5TUEVDSUZJRUQQABINCglVU19FUVVJVFkQARIICgRNU0NJEAISCw'
    'oHTVNDSV9FWBADEg0KCUVNX0VRVUlUWRAEEg8KC1BPTF9FUVVJSVRZEAUSCwoHVVNfQk9ORBAG'
    'Eg0KCVBPTF9CT05EUxAHEg0KCUNPTU1PRElUWRAIEggKBENBU0gQCQ==');

@$core.Deprecated('Use assetDescriptor instead')
const Asset$json = {
  '1': 'Asset',
  '2': [
    {'1': 'id', '3': 1, '4': 1, '5': 5, '10': 'id'},
    {'1': 'symbol', '3': 2, '4': 1, '5': 9, '10': 'symbol'},
    {'1': 'currencyCode', '3': 3, '4': 1, '5': 9, '10': 'currencyCode'},
    {
      '1': 'type',
      '3': 4,
      '4': 1,
      '5': 14,
      '6': '.trading.asset.AssetType',
      '10': 'type'
    },
    {'1': 'assetTypeDetails', '3': 5, '4': 1, '5': 9, '10': 'assetTypeDetails'},
    {
      '1': 'prices',
      '3': 6,
      '4': 3,
      '5': 11,
      '6': '.trading.price.IndexPriceItem',
      '10': 'prices'
    },
  ],
};

/// Descriptor for `Asset`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List assetDescriptor = $convert.base64Decode(
    'CgVBc3NldBIOCgJpZBgBIAEoBVICaWQSFgoGc3ltYm9sGAIgASgJUgZzeW1ib2wSIgoMY3Vycm'
    'VuY3lDb2RlGAMgASgJUgxjdXJyZW5jeUNvZGUSLAoEdHlwZRgEIAEoDjIYLnRyYWRpbmcuYXNz'
    'ZXQuQXNzZXRUeXBlUgR0eXBlEioKEGFzc2V0VHlwZURldGFpbHMYBSABKAlSEGFzc2V0VHlwZU'
    'RldGFpbHMSNQoGcHJpY2VzGAYgAygLMh0udHJhZGluZy5wcmljZS5JbmRleFByaWNlSXRlbVIG'
    'cHJpY2Vz');

@$core.Deprecated('Use assetsRequestDescriptor instead')
const AssetsRequest$json = {
  '1': 'AssetsRequest',
  '2': [
    {
      '1': 'assets',
      '3': 1,
      '4': 3,
      '5': 11,
      '6': '.trading.asset.Asset',
      '10': 'assets'
    },
  ],
};

/// Descriptor for `AssetsRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List assetsRequestDescriptor = $convert.base64Decode(
    'Cg1Bc3NldHNSZXF1ZXN0EiwKBmFzc2V0cxgBIAMoCzIULnRyYWRpbmcuYXNzZXQuQXNzZXRSBm'
    'Fzc2V0cw==');
