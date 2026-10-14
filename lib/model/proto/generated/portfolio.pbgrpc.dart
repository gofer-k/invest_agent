// This is a generated file - do not edit.
//
// Generated from portfolio.proto.

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

import 'portfolio.pb.dart' as $0;

export 'portfolio.pb.dart';

/// Service handling portfolio analytics calculations
@$pb.GrpcServiceName('trading.portfolio.analytics.AnalyticsService')
class AnalyticsServiceClient extends $grpc.Client {
  /// The hostname for this service.
  static const $core.String defaultHost = '';

  /// OAuth scopes needed for the client.
  static const $core.List<$core.String> oauthScopes = [
    '',
  ];

  AnalyticsServiceClient(super.channel, {super.options, super.interceptors});

  /// Evaluates a specific portfolio strategy based on historical parameters
  $grpc.ResponseFuture<$0.EvaluatePortfolioResponse> evaluatePortofolio(
    $0.EvaluatePortfolioRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$evaluatePortofolio, request, options: options);
  }

  /// Streams real-time or step-by-step historical backtest metrics to the desktop client
  $grpc.ResponseStream<$0.StreamBacktestResponse> streamBacktestMetrics(
    $0.StreamBacktestRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createStreamingCall(
        _$streamBacktestMetrics, $async.Stream.fromIterable([request]),
        options: options);
  }

  // method descriptors

  static final _$evaluatePortofolio = $grpc.ClientMethod<
          $0.EvaluatePortfolioRequest, $0.EvaluatePortfolioResponse>(
      '/trading.portfolio.analytics.AnalyticsService/EvaluatePortofolio',
      ($0.EvaluatePortfolioRequest value) => value.writeToBuffer(),
      $0.EvaluatePortfolioResponse.fromBuffer);
  static final _$streamBacktestMetrics =
      $grpc.ClientMethod<$0.StreamBacktestRequest, $0.StreamBacktestResponse>(
          '/trading.portfolio.analytics.AnalyticsService/StreamBacktestMetrics',
          ($0.StreamBacktestRequest value) => value.writeToBuffer(),
          $0.StreamBacktestResponse.fromBuffer);
}

@$pb.GrpcServiceName('trading.portfolio.analytics.AnalyticsService')
abstract class AnalyticsServiceBase extends $grpc.Service {
  $core.String get $name => 'trading.portfolio.analytics.AnalyticsService';

  AnalyticsServiceBase() {
    $addMethod($grpc.ServiceMethod<$0.EvaluatePortfolioRequest,
            $0.EvaluatePortfolioResponse>(
        'EvaluatePortofolio',
        evaluatePortofolio_Pre,
        false,
        false,
        ($core.List<$core.int> value) =>
            $0.EvaluatePortfolioRequest.fromBuffer(value),
        ($0.EvaluatePortfolioResponse value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.StreamBacktestRequest,
            $0.StreamBacktestResponse>(
        'StreamBacktestMetrics',
        streamBacktestMetrics_Pre,
        false,
        true,
        ($core.List<$core.int> value) =>
            $0.StreamBacktestRequest.fromBuffer(value),
        ($0.StreamBacktestResponse value) => value.writeToBuffer()));
  }

  $async.Future<$0.EvaluatePortfolioResponse> evaluatePortofolio_Pre(
      $grpc.ServiceCall $call,
      $async.Future<$0.EvaluatePortfolioRequest> $request) async {
    return evaluatePortofolio($call, await $request);
  }

  $async.Future<$0.EvaluatePortfolioResponse> evaluatePortofolio(
      $grpc.ServiceCall call, $0.EvaluatePortfolioRequest request);

  $async.Stream<$0.StreamBacktestResponse> streamBacktestMetrics_Pre(
      $grpc.ServiceCall $call,
      $async.Future<$0.StreamBacktestRequest> $request) async* {
    yield* streamBacktestMetrics($call, await $request);
  }

  $async.Stream<$0.StreamBacktestResponse> streamBacktestMetrics(
      $grpc.ServiceCall call, $0.StreamBacktestRequest request);
}
