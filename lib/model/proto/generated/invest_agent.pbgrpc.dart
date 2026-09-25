// This is a generated file - do not edit.
//
// Generated from invest_agent.proto.

// @dart = 3.3

// ignore_for_file: annotate_overrides, camel_case_types, comment_references
// ignore_for_file: constant_identifier_names
// ignore_for_file: curly_braces_in_flow_control_structures
// ignore_for_file: deprecated_member_use_from_same_package, library_prefixes
// ignore_for_file: non_constant_identifier_names, prefer_relative_imports

import 'dart:async' as $async;
import 'dart:core' as $core;

import 'package:grpc/service_api.dart' as $grpc;
import 'package:protobuf/protobuf.dart' as $pb;
import 'package:protobuf/well_known_types/google/protobuf/empty.pb.dart' as $2;

import 'asset.pb.dart' as $1;
import 'invest_agent.pb.dart' as $0;

export 'invest_agent.pb.dart';

@$pb.GrpcServiceName('trading.InvestAgentService')
class InvestAgentServiceClient extends $grpc.Client {
  /// The hostname for this service.
  static const $core.String defaultHost = '';

  /// OAuth scopes needed for the client.
  static const $core.List<$core.String> oauthScopes = [
    '',
  ];

  InvestAgentServiceClient(super.channel, {super.options, super.interceptors});

  /// Two-side communication: stream of requests to stream of results
  $grpc.ResponseStream<$0.TradingResponse> calculateIndicators(
    $async.Stream<$0.TradingRequest> request, {
    $grpc.CallOptions? options,
  }) {
    return $createStreamingCall(_$calculateIndicators, request,
        options: options);
  }

  $grpc.ResponseStream<$0.StrategyResponse> calculateStrategy(
    $async.Stream<$0.StrategyRequest> request, {
    $grpc.CallOptions? options,
  }) {
    return $createStreamingCall(_$calculateStrategy, request, options: options);
  }

  $grpc.ResponseFuture<$2.Empty> requestAssets(
    $async.Stream<$1.AssetsRequest> request, {
    $grpc.CallOptions? options,
  }) {
    return $createStreamingCall(_$requestAssets, request, options: options)
        .single;
  }

  // method descriptors

  static final _$calculateIndicators =
      $grpc.ClientMethod<$0.TradingRequest, $0.TradingResponse>(
          '/trading.InvestAgentService/CalculateIndicators',
          ($0.TradingRequest value) => value.writeToBuffer(),
          $0.TradingResponse.fromBuffer);
  static final _$calculateStrategy =
      $grpc.ClientMethod<$0.StrategyRequest, $0.StrategyResponse>(
          '/trading.InvestAgentService/CalculateStrategy',
          ($0.StrategyRequest value) => value.writeToBuffer(),
          $0.StrategyResponse.fromBuffer);
  static final _$requestAssets = $grpc.ClientMethod<$1.AssetsRequest, $2.Empty>(
      '/trading.InvestAgentService/requestAssets',
      ($1.AssetsRequest value) => value.writeToBuffer(),
      $2.Empty.fromBuffer);
}

@$pb.GrpcServiceName('trading.InvestAgentService')
abstract class InvestAgentServiceBase extends $grpc.Service {
  $core.String get $name => 'trading.InvestAgentService';

  InvestAgentServiceBase() {
    $addMethod($grpc.ServiceMethod<$0.TradingRequest, $0.TradingResponse>(
        'CalculateIndicators',
        calculateIndicators,
        true,
        true,
        ($core.List<$core.int> value) => $0.TradingRequest.fromBuffer(value),
        ($0.TradingResponse value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.StrategyRequest, $0.StrategyResponse>(
        'CalculateStrategy',
        calculateStrategy,
        true,
        true,
        ($core.List<$core.int> value) => $0.StrategyRequest.fromBuffer(value),
        ($0.StrategyResponse value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$1.AssetsRequest, $2.Empty>(
        'requestAssets',
        requestAssets,
        true,
        false,
        ($core.List<$core.int> value) => $1.AssetsRequest.fromBuffer(value),
        ($2.Empty value) => value.writeToBuffer()));
  }

  $async.Stream<$0.TradingResponse> calculateIndicators(
      $grpc.ServiceCall call, $async.Stream<$0.TradingRequest> request);

  $async.Stream<$0.StrategyResponse> calculateStrategy(
      $grpc.ServiceCall call, $async.Stream<$0.StrategyRequest> request);

  $async.Future<$2.Empty> requestAssets(
      $grpc.ServiceCall call, $async.Stream<$1.AssetsRequest> request);
}
