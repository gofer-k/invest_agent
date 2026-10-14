// This is a generated file - do not edit.
//
// Generated from price.proto.

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
