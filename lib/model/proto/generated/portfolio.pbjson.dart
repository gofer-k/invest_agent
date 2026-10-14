// This is a generated file - do not edit.
//
// Generated from portfolio.proto.

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
    {'1': 'ARBITRARY', '2': 1},
    {'1': 'ASSETALLOCATION', '2': 2},
    {'1': 'GEM', '2': 3},
    {'1': 'MEANREVERSION', '2': 4},
    {'1': 'INDEXFUNDREBALANCING', '2': 5},
    {'1': 'TRENDfOLLOWING', '2': 6},
  ],
};

/// Descriptor for `StrategyType`. Decode as a `google.protobuf.EnumDescriptorProto`.
final $typed_data.Uint8List strategyTypeDescriptor = $convert.base64Decode(
    'CgxTdHJhdGVneVR5cGUSCQoFRU1QVFkQABINCglBUkJJVFJBUlkQARITCg9BU1NFVEFMTE9DQV'
    'RJT04QAhIHCgNHRU0QAxIRCg1NRUFOUkVWRVJTSU9OEAQSGAoUSU5ERVhGVU5EUkVCQUxBTkNJ'
    'TkcQBRISCg5UUkVORGZPTExPV0lORxAG');

@$core.Deprecated('Use rebalanceFrequencyDescriptor instead')
const RebalanceFrequency$json = {
  '1': 'RebalanceFrequency',
  '2': [
    {'1': 'UNSPECIFIED', '2': 0},
    {'1': 'DAILY', '2': 1},
    {'1': 'WEEKLY', '2': 2},
    {'1': 'MONTHLY', '2': 3},
    {'1': 'QUARTERLY', '2': 4},
    {'1': 'YEARLY', '2': 5},
    {'1': 'TWO_YEARS', '2': 6},
    {'1': 'SPECIFIC_PERIOD', '2': 7},
  ],
};

/// Descriptor for `RebalanceFrequency`. Decode as a `google.protobuf.EnumDescriptorProto`.
final $typed_data.Uint8List rebalanceFrequencyDescriptor = $convert.base64Decode(
    'ChJSZWJhbGFuY2VGcmVxdWVuY3kSDwoLVU5TUEVDSUZJRUQQABIJCgVEQUlMWRABEgoKBldFRU'
    'tMWRACEgsKB01PTlRITFkQAxINCglRVUFSVEVSTFkQBBIKCgZZRUFSTFkQBRINCglUV09fWUVB'
    'UlMQBhITCg9TUEVDSUZJQ19QRVJJT0QQBw==');

@$core.Deprecated('Use portfolioDescriptor instead')
const Portfolio$json = {
  '1': 'Portfolio',
  '2': [
    {'1': 'id', '3': 1, '4': 1, '5': 9, '10': 'id'},
    {'1': 'name', '3': 2, '4': 1, '5': 9, '10': 'name'},
    {'1': 'description', '3': 3, '4': 1, '5': 9, '10': 'description'},
    {
      '1': 'created_at',
      '3': 4,
      '4': 1,
      '5': 11,
      '6': '.google.protobuf.Timestamp',
      '10': 'createdAt'
    },
    {
      '1': 'allocations',
      '3': 5,
      '4': 3,
      '5': 11,
      '6': '.trading.portfolio.analytics.AssetAllocation',
      '10': 'allocations'
    },
    {'1': 'risk_free_rate', '3': 6, '4': 1, '5': 1, '10': 'riskFreeRate'},
  ],
};

/// Descriptor for `Portfolio`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List portfolioDescriptor = $convert.base64Decode(
    'CglQb3J0Zm9saW8SDgoCaWQYASABKAlSAmlkEhIKBG5hbWUYAiABKAlSBG5hbWUSIAoLZGVzY3'
    'JpcHRpb24YAyABKAlSC2Rlc2NyaXB0aW9uEjkKCmNyZWF0ZWRfYXQYBCABKAsyGi5nb29nbGUu'
    'cHJvdG9idWYuVGltZXN0YW1wUgljcmVhdGVkQXQSTgoLYWxsb2NhdGlvbnMYBSADKAsyLC50cm'
    'FkaW5nLnBvcnRmb2xpby5hbmFseXRpY3MuQXNzZXRBbGxvY2F0aW9uUgthbGxvY2F0aW9ucxIk'
    'Cg5yaXNrX2ZyZWVfcmF0ZRgGIAEoAVIMcmlza0ZyZWVSYXRl');

@$core.Deprecated('Use assetAllocationDescriptor instead')
const AssetAllocation$json = {
  '1': 'AssetAllocation',
  '2': [
    {'1': 'asset_id', '3': 1, '4': 1, '5': 5, '10': 'assetId'},
    {'1': 'target_weight', '3': 2, '4': 1, '5': 1, '10': 'targetWeight'},
    {
      '1': 'asset_shares_count',
      '3': 3,
      '4': 1,
      '5': 5,
      '10': 'assetSharesCount'
    },
    {
      '1': 'price',
      '3': 4,
      '4': 3,
      '5': 11,
      '6': '.trading.price.IndexPriceItem',
      '10': 'price'
    },
  ],
};

/// Descriptor for `AssetAllocation`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List assetAllocationDescriptor = $convert.base64Decode(
    'Cg9Bc3NldEFsbG9jYXRpb24SGQoIYXNzZXRfaWQYASABKAVSB2Fzc2V0SWQSIwoNdGFyZ2V0X3'
    'dlaWdodBgCIAEoAVIMdGFyZ2V0V2VpZ2h0EiwKEmFzc2V0X3NoYXJlc19jb3VudBgDIAEoBVIQ'
    'YXNzZXRTaGFyZXNDb3VudBIzCgVwcmljZRgEIAMoCzIdLnRyYWRpbmcucHJpY2UuSW5kZXhQcm'
    'ljZUl0ZW1SBXByaWNl');

@$core.Deprecated('Use strategyConfigDescriptor instead')
const StrategyConfig$json = {
  '1': 'StrategyConfig',
  '2': [
    {
      '1': 'strategy_type',
      '3': 1,
      '4': 1,
      '5': 14,
      '6': '.trading.portfolio.analytics.StrategyType',
      '10': 'strategyType'
    },
    {
      '1': 'rebalance_frequency',
      '3': 2,
      '4': 1,
      '5': 14,
      '6': '.trading.portfolio.analytics.RebalanceFrequency',
      '10': 'rebalanceFrequency'
    },
    {
      '1': 'custom_parameters',
      '3': 3,
      '4': 1,
      '5': 11,
      '6': '.google.protobuf.Struct',
      '10': 'customParameters'
    },
  ],
};

/// Descriptor for `StrategyConfig`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List strategyConfigDescriptor = $convert.base64Decode(
    'Cg5TdHJhdGVneUNvbmZpZxJOCg1zdHJhdGVneV90eXBlGAEgASgOMikudHJhZGluZy5wb3J0Zm'
    '9saW8uYW5hbHl0aWNzLlN0cmF0ZWd5VHlwZVIMc3RyYXRlZ3lUeXBlEmAKE3JlYmFsYW5jZV9m'
    'cmVxdWVuY3kYAiABKA4yLy50cmFkaW5nLnBvcnRmb2xpby5hbmFseXRpY3MuUmViYWxhbmNlRn'
    'JlcXVlbmN5UhJyZWJhbGFuY2VGcmVxdWVuY3kSRAoRY3VzdG9tX3BhcmFtZXRlcnMYAyABKAsy'
    'Fy5nb29nbGUucHJvdG9idWYuU3RydWN0UhBjdXN0b21QYXJhbWV0ZXJz');

@$core.Deprecated('Use performanceMetricsDescriptor instead')
const PerformanceMetrics$json = {
  '1': 'PerformanceMetrics',
  '2': [
    {'1': 'total_return', '3': 1, '4': 1, '5': 1, '10': 'totalReturn'},
    {
      '1': 'annualized_return',
      '3': 2,
      '4': 1,
      '5': 1,
      '10': 'annualizedReturn'
    },
    {'1': 'volatility', '3': 3, '4': 1, '5': 1, '10': 'volatility'},
    {'1': 'sharpe_ratio', '3': 4, '4': 1, '5': 1, '10': 'sharpeRatio'},
    {'1': 'sortino_ratio', '3': 5, '4': 1, '5': 1, '10': 'sortinoRatio'},
    {'1': 'max_drawdown', '3': 6, '4': 1, '5': 1, '10': 'maxDrawdown'},
    {'1': 'alpha', '3': 7, '4': 1, '5': 1, '10': 'alpha'},
    {'1': 'beta', '3': 8, '4': 1, '5': 1, '10': 'beta'},
    {'1': 'cagr', '3': 9, '4': 1, '5': 2, '10': 'cagr'},
    {'1': 'calmar', '3': 10, '4': 1, '5': 2, '10': 'calmar'},
    {'1': 'correlation', '3': 11, '4': 1, '5': 2, '10': 'correlation'},
    {'1': 'tracking_error', '3': 12, '4': 1, '5': 2, '10': 'trackingError'},
    {'1': 'tracking_diff', '3': 13, '4': 1, '5': 2, '10': 'trackingDiff'},
    {'1': 'expense_ratio', '3': 14, '4': 1, '5': 2, '10': 'expenseRatio'},
    {'1': 'bid_ask_spread', '3': 15, '4': 1, '5': 2, '10': 'bidAskSpread'},
    {'1': 'concentration', '3': 16, '4': 1, '5': 2, '10': 'concentration'},
    {'1': 'dividend_yield', '3': 17, '4': 1, '5': 2, '10': 'dividendYield'},
  ],
};

/// Descriptor for `PerformanceMetrics`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List performanceMetricsDescriptor = $convert.base64Decode(
    'ChJQZXJmb3JtYW5jZU1ldHJpY3MSIQoMdG90YWxfcmV0dXJuGAEgASgBUgt0b3RhbFJldHVybh'
    'IrChFhbm51YWxpemVkX3JldHVybhgCIAEoAVIQYW5udWFsaXplZFJldHVybhIeCgp2b2xhdGls'
    'aXR5GAMgASgBUgp2b2xhdGlsaXR5EiEKDHNoYXJwZV9yYXRpbxgEIAEoAVILc2hhcnBlUmF0aW'
    '8SIwoNc29ydGlub19yYXRpbxgFIAEoAVIMc29ydGlub1JhdGlvEiEKDG1heF9kcmF3ZG93bhgG'
    'IAEoAVILbWF4RHJhd2Rvd24SFAoFYWxwaGEYByABKAFSBWFscGhhEhIKBGJldGEYCCABKAFSBG'
    'JldGESEgoEY2FnchgJIAEoAlIEY2FnchIWCgZjYWxtYXIYCiABKAJSBmNhbG1hchIgCgtjb3Jy'
    'ZWxhdGlvbhgLIAEoAlILY29ycmVsYXRpb24SJQoOdHJhY2tpbmdfZXJyb3IYDCABKAJSDXRyYW'
    'NraW5nRXJyb3ISIwoNdHJhY2tpbmdfZGlmZhgNIAEoAlIMdHJhY2tpbmdEaWZmEiMKDWV4cGVu'
    'c2VfcmF0aW8YDiABKAJSDGV4cGVuc2VSYXRpbxIkCg5iaWRfYXNrX3NwcmVhZBgPIAEoAlIMYm'
    'lkQXNrU3ByZWFkEiQKDWNvbmNlbnRyYXRpb24YECABKAJSDWNvbmNlbnRyYXRpb24SJQoOZGl2'
    'aWRlbmRfeWllbGQYESABKAJSDWRpdmlkZW5kWWllbGQ=');

@$core.Deprecated('Use equityCurvePointDescriptor instead')
const EquityCurvePoint$json = {
  '1': 'EquityCurvePoint',
  '2': [
    {
      '1': 'timestamp',
      '3': 1,
      '4': 1,
      '5': 11,
      '6': '.google.protobuf.Timestamp',
      '10': 'timestamp'
    },
    {'1': 'portfolio_value', '3': 2, '4': 1, '5': 1, '10': 'portfolioValue'},
    {'1': 'drawdown', '3': 3, '4': 1, '5': 1, '10': 'drawdown'},
  ],
};

/// Descriptor for `EquityCurvePoint`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List equityCurvePointDescriptor = $convert.base64Decode(
    'ChBFcXVpdHlDdXJ2ZVBvaW50EjgKCXRpbWVzdGFtcBgBIAEoCzIaLmdvb2dsZS5wcm90b2J1Zi'
    '5UaW1lc3RhbXBSCXRpbWVzdGFtcBInCg9wb3J0Zm9saW9fdmFsdWUYAiABKAFSDnBvcnRmb2xp'
    'b1ZhbHVlEhoKCGRyYXdkb3duGAMgASgBUghkcmF3ZG93bg==');

@$core.Deprecated('Use evaluatePortfolioRequestDescriptor instead')
const EvaluatePortfolioRequest$json = {
  '1': 'EvaluatePortfolioRequest',
  '2': [
    {
      '1': 'portfolio',
      '3': 1,
      '4': 1,
      '5': 11,
      '6': '.trading.portfolio.analytics.Portfolio',
      '10': 'portfolio'
    },
    {
      '1': 'start_date',
      '3': 2,
      '4': 1,
      '5': 11,
      '6': '.google.protobuf.Timestamp',
      '10': 'startDate'
    },
    {
      '1': 'end_date',
      '3': 3,
      '4': 1,
      '5': 11,
      '6': '.google.protobuf.Timestamp',
      '10': 'endDate'
    },
    {
      '1': 'allocations',
      '3': 4,
      '4': 3,
      '5': 11,
      '6': '.trading.portfolio.analytics.AssetAllocation',
      '10': 'allocations'
    },
    {
      '1': 'strategy_config',
      '3': 5,
      '4': 1,
      '5': 11,
      '6': '.trading.portfolio.analytics.StrategyConfig',
      '10': 'strategyConfig'
    },
    {'1': 'initial_capital', '3': 6, '4': 1, '5': 1, '10': 'initialCapital'},
  ],
};

/// Descriptor for `EvaluatePortfolioRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List evaluatePortfolioRequestDescriptor = $convert.base64Decode(
    'ChhFdmFsdWF0ZVBvcnRmb2xpb1JlcXVlc3QSRAoJcG9ydGZvbGlvGAEgASgLMiYudHJhZGluZy'
    '5wb3J0Zm9saW8uYW5hbHl0aWNzLlBvcnRmb2xpb1IJcG9ydGZvbGlvEjkKCnN0YXJ0X2RhdGUY'
    'AiABKAsyGi5nb29nbGUucHJvdG9idWYuVGltZXN0YW1wUglzdGFydERhdGUSNQoIZW5kX2RhdG'
    'UYAyABKAsyGi5nb29nbGUucHJvdG9idWYuVGltZXN0YW1wUgdlbmREYXRlEk4KC2FsbG9jYXRp'
    'b25zGAQgAygLMiwudHJhZGluZy5wb3J0Zm9saW8uYW5hbHl0aWNzLkFzc2V0QWxsb2NhdGlvbl'
    'ILYWxsb2NhdGlvbnMSVAoPc3RyYXRlZ3lfY29uZmlnGAUgASgLMisudHJhZGluZy5wb3J0Zm9s'
    'aW8uYW5hbHl0aWNzLlN0cmF0ZWd5Q29uZmlnUg5zdHJhdGVneUNvbmZpZxInCg9pbml0aWFsX2'
    'NhcGl0YWwYBiABKAFSDmluaXRpYWxDYXBpdGFs');

@$core.Deprecated('Use evaluatePortfolioResponseDescriptor instead')
const EvaluatePortfolioResponse$json = {
  '1': 'EvaluatePortfolioResponse',
  '2': [
    {'1': 'portfolio_id', '3': 1, '4': 1, '5': 9, '10': 'portfolioId'},
    {
      '1': 'summary_metrics',
      '3': 2,
      '4': 1,
      '5': 11,
      '6': '.trading.portfolio.analytics.PerformanceMetrics',
      '10': 'summaryMetrics'
    },
    {
      '1': 'equity_curve',
      '3': 3,
      '4': 3,
      '5': 11,
      '6': '.trading.portfolio.analytics.EquityCurvePoint',
      '10': 'equityCurve'
    },
    {
      '1': 'calculated_at',
      '3': 4,
      '4': 1,
      '5': 11,
      '6': '.google.protobuf.Timestamp',
      '10': 'calculatedAt'
    },
  ],
};

/// Descriptor for `EvaluatePortfolioResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List evaluatePortfolioResponseDescriptor = $convert.base64Decode(
    'ChlFdmFsdWF0ZVBvcnRmb2xpb1Jlc3BvbnNlEiEKDHBvcnRmb2xpb19pZBgBIAEoCVILcG9ydG'
    'ZvbGlvSWQSWAoPc3VtbWFyeV9tZXRyaWNzGAIgASgLMi8udHJhZGluZy5wb3J0Zm9saW8uYW5h'
    'bHl0aWNzLlBlcmZvcm1hbmNlTWV0cmljc1IOc3VtbWFyeU1ldHJpY3MSUAoMZXF1aXR5X2N1cn'
    'ZlGAMgAygLMi0udHJhZGluZy5wb3J0Zm9saW8uYW5hbHl0aWNzLkVxdWl0eUN1cnZlUG9pbnRS'
    'C2VxdWl0eUN1cnZlEj8KDWNhbGN1bGF0ZWRfYXQYBCABKAsyGi5nb29nbGUucHJvdG9idWYuVG'
    'ltZXN0YW1wUgxjYWxjdWxhdGVkQXQ=');

@$core.Deprecated('Use streamBacktestRequestDescriptor instead')
const StreamBacktestRequest$json = {
  '1': 'StreamBacktestRequest',
  '2': [
    {
      '1': 'portfolio',
      '3': 1,
      '4': 1,
      '5': 11,
      '6': '.trading.portfolio.analytics.Portfolio',
      '10': 'portfolio'
    },
    {
      '1': 'start_date',
      '3': 2,
      '4': 1,
      '5': 11,
      '6': '.google.protobuf.Timestamp',
      '10': 'startDate'
    },
    {
      '1': 'end_date',
      '3': 3,
      '4': 1,
      '5': 11,
      '6': '.google.protobuf.Timestamp',
      '10': 'endDate'
    },
    {
      '1': 'allocations',
      '3': 4,
      '4': 3,
      '5': 11,
      '6': '.trading.portfolio.analytics.AssetAllocation',
      '10': 'allocations'
    },
    {
      '1': 'strategy_config',
      '3': 5,
      '4': 1,
      '5': 11,
      '6': '.trading.portfolio.analytics.StrategyConfig',
      '10': 'strategyConfig'
    },
    {'1': 'initial_capital', '3': 7, '4': 1, '5': 1, '10': 'initialCapital'},
  ],
};

/// Descriptor for `StreamBacktestRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List streamBacktestRequestDescriptor = $convert.base64Decode(
    'ChVTdHJlYW1CYWNrdGVzdFJlcXVlc3QSRAoJcG9ydGZvbGlvGAEgASgLMiYudHJhZGluZy5wb3'
    'J0Zm9saW8uYW5hbHl0aWNzLlBvcnRmb2xpb1IJcG9ydGZvbGlvEjkKCnN0YXJ0X2RhdGUYAiAB'
    'KAsyGi5nb29nbGUucHJvdG9idWYuVGltZXN0YW1wUglzdGFydERhdGUSNQoIZW5kX2RhdGUYAy'
    'ABKAsyGi5nb29nbGUucHJvdG9idWYuVGltZXN0YW1wUgdlbmREYXRlEk4KC2FsbG9jYXRpb25z'
    'GAQgAygLMiwudHJhZGluZy5wb3J0Zm9saW8uYW5hbHl0aWNzLkFzc2V0QWxsb2NhdGlvblILYW'
    'xsb2NhdGlvbnMSVAoPc3RyYXRlZ3lfY29uZmlnGAUgASgLMisudHJhZGluZy5wb3J0Zm9saW8u'
    'YW5hbHl0aWNzLlN0cmF0ZWd5Q29uZmlnUg5zdHJhdGVneUNvbmZpZxInCg9pbml0aWFsX2NhcG'
    'l0YWwYByABKAFSDmluaXRpYWxDYXBpdGFs');

@$core.Deprecated('Use streamBacktestResponseDescriptor instead')
const StreamBacktestResponse$json = {
  '1': 'StreamBacktestResponse',
  '2': [
    {'1': 'portfolio_id', '3': 1, '4': 1, '5': 9, '10': 'portfolioId'},
    {
      '1': 'current_simulated_date',
      '3': 2,
      '4': 1,
      '5': 11,
      '6': '.google.protobuf.Timestamp',
      '10': 'currentSimulatedDate'
    },
    {
      '1': 'current_portfolio_value',
      '3': 3,
      '4': 1,
      '5': 1,
      '10': 'currentPortfolioValue'
    },
    {
      '1': 'running_metrics',
      '3': 4,
      '4': 1,
      '5': 11,
      '6': '.trading.portfolio.analytics.PerformanceMetrics',
      '10': 'runningMetrics'
    },
    {'1': 'is_completed', '3': 5, '4': 1, '5': 8, '10': 'isCompleted'},
  ],
};

/// Descriptor for `StreamBacktestResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List streamBacktestResponseDescriptor = $convert.base64Decode(
    'ChZTdHJlYW1CYWNrdGVzdFJlc3BvbnNlEiEKDHBvcnRmb2xpb19pZBgBIAEoCVILcG9ydGZvbG'
    'lvSWQSUAoWY3VycmVudF9zaW11bGF0ZWRfZGF0ZRgCIAEoCzIaLmdvb2dsZS5wcm90b2J1Zi5U'
    'aW1lc3RhbXBSFGN1cnJlbnRTaW11bGF0ZWREYXRlEjYKF2N1cnJlbnRfcG9ydGZvbGlvX3ZhbH'
    'VlGAMgASgBUhVjdXJyZW50UG9ydGZvbGlvVmFsdWUSWAoPcnVubmluZ19tZXRyaWNzGAQgASgL'
    'Mi8udHJhZGluZy5wb3J0Zm9saW8uYW5hbHl0aWNzLlBlcmZvcm1hbmNlTWV0cmljc1IOcnVubm'
    'luZ01ldHJpY3MSIQoMaXNfY29tcGxldGVkGAUgASgIUgtpc0NvbXBsZXRlZA==');
