// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'trading_analytics_service.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(tradingAnalyticsClient)
final tradingAnalyticsClientProvider = TradingAnalyticsClientFamily._();

final class TradingAnalyticsClientProvider
    extends
        $FunctionalProvider<
          TradingAnalyticsServiceClient,
          TradingAnalyticsServiceClient,
          TradingAnalyticsServiceClient
        >
    with $Provider<TradingAnalyticsServiceClient> {
  TradingAnalyticsClientProvider._({
    required TradingAnalyticsClientFamily super.from,
    required (String?, int?) super.argument,
  }) : super(
         retry: null,
         name: r'tradingAnalyticsClientProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$tradingAnalyticsClientHash();

  @override
  String toString() {
    return r'tradingAnalyticsClientProvider'
        ''
        '$argument';
  }

  @$internal
  @override
  $ProviderElement<TradingAnalyticsServiceClient> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  TradingAnalyticsServiceClient create(Ref ref) {
    final argument = this.argument as (String?, int?);
    return tradingAnalyticsClient(ref, argument.$1, argument.$2);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(TradingAnalyticsServiceClient value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<TradingAnalyticsServiceClient>(
        value,
      ),
    );
  }

  @override
  bool operator ==(Object other) {
    return other is TradingAnalyticsClientProvider &&
        other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$tradingAnalyticsClientHash() =>
    r'db1999bf0add264c448accbb506e064149350bd7';

final class TradingAnalyticsClientFamily extends $Family
    with
        $FunctionalFamilyOverride<
          TradingAnalyticsServiceClient,
          (String?, int?)
        > {
  TradingAnalyticsClientFamily._()
    : super(
        retry: null,
        name: r'tradingAnalyticsClientProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  TradingAnalyticsClientProvider call([String? customHost, int? customPort]) =>
      TradingAnalyticsClientProvider._(
        argument: (customHost, customPort),
        from: this,
      );

  @override
  String toString() => r'tradingAnalyticsClientProvider';
}

@ProviderFor(ActiveRiskPortfolioId)
final activeRiskPortfolioIdProvider = ActiveRiskPortfolioIdProvider._();

final class ActiveRiskPortfolioIdProvider
    extends $NotifierProvider<ActiveRiskPortfolioId, int?> {
  ActiveRiskPortfolioIdProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'activeRiskPortfolioIdProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$activeRiskPortfolioIdHash();

  @$internal
  @override
  ActiveRiskPortfolioId create() => ActiveRiskPortfolioId();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(int? value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<int?>(value),
    );
  }
}

String _$activeRiskPortfolioIdHash() =>
    r'87a389dbc0db576107b626899f494da4e4a8b66d';

abstract class _$ActiveRiskPortfolioId extends $Notifier<int?> {
  int? build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<int?, int?>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<int?, int?>,
              int?,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}

@ProviderFor(TradingAnalyticsService)
final tradingAnalyticsServiceProvider = TradingAnalyticsServiceProvider._();

final class TradingAnalyticsServiceProvider
    extends
        $NotifierProvider<
          TradingAnalyticsService,
          TradingAnalyticsServiceState
        > {
  TradingAnalyticsServiceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'tradingAnalyticsServiceProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$tradingAnalyticsServiceHash();

  @$internal
  @override
  TradingAnalyticsService create() => TradingAnalyticsService();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(TradingAnalyticsServiceState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<TradingAnalyticsServiceState>(value),
    );
  }
}

String _$tradingAnalyticsServiceHash() =>
    r'ae3b961125983e8498b9ecfc614630078dcb1c34';

abstract class _$TradingAnalyticsService
    extends $Notifier<TradingAnalyticsServiceState> {
  TradingAnalyticsServiceState build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref =
        this.ref
            as $Ref<TradingAnalyticsServiceState, TradingAnalyticsServiceState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<
                TradingAnalyticsServiceState,
                TradingAnalyticsServiceState
              >,
              TradingAnalyticsServiceState,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}

/// Provider to watch the result of a specific portfolio evaluation

@ProviderFor(portfolioResult)
final portfolioResultProvider = PortfolioResultFamily._();

/// Provider to watch the result of a specific portfolio evaluation

final class PortfolioResultProvider
    extends
        $FunctionalProvider<
          AsyncValue<model_result.PortfolioResult?>,
          AsyncValue<model_result.PortfolioResult?>,
          AsyncValue<model_result.PortfolioResult?>
        >
    with $Provider<AsyncValue<model_result.PortfolioResult?>> {
  /// Provider to watch the result of a specific portfolio evaluation
  PortfolioResultProvider._({
    required PortfolioResultFamily super.from,
    required int super.argument,
  }) : super(
         retry: null,
         name: r'portfolioResultProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$portfolioResultHash();

  @override
  String toString() {
    return r'portfolioResultProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $ProviderElement<AsyncValue<model_result.PortfolioResult?>> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  AsyncValue<model_result.PortfolioResult?> create(Ref ref) {
    final argument = this.argument as int;
    return portfolioResult(ref, portfolioId: argument);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AsyncValue<model_result.PortfolioResult?> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride:
          $SyncValueProvider<AsyncValue<model_result.PortfolioResult?>>(value),
    );
  }

  @override
  bool operator ==(Object other) {
    return other is PortfolioResultProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$portfolioResultHash() => r'6b66bb971b7d93621a54525c1c2c10fc7b1068a0';

/// Provider to watch the result of a specific portfolio evaluation

final class PortfolioResultFamily extends $Family
    with
        $FunctionalFamilyOverride<
          AsyncValue<model_result.PortfolioResult?>,
          int
        > {
  PortfolioResultFamily._()
    : super(
        retry: null,
        name: r'portfolioResultProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// Provider to watch the result of a specific portfolio evaluation

  PortfolioResultProvider call({required int portfolioId}) =>
      PortfolioResultProvider._(argument: portfolioId, from: this);

  @override
  String toString() => r'portfolioResultProvider';
}
