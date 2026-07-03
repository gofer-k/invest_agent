// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'trading_service.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(tradingClient)
final tradingClientProvider = TradingClientProvider._();

final class TradingClientProvider
    extends
        $FunctionalProvider<
          TradingServiceClient,
          TradingServiceClient,
          TradingServiceClient
        >
    with $Provider<TradingServiceClient> {
  TradingClientProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'tradingClientProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$tradingClientHash();

  @$internal
  @override
  $ProviderElement<TradingServiceClient> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  TradingServiceClient create(Ref ref) {
    return tradingClient(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(TradingServiceClient value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<TradingServiceClient>(value),
    );
  }
}

String _$tradingClientHash() => r'41103985809197eb7400470f6bb6b8f4c81f2e80';

@ProviderFor(TradingService)
final tradingServiceProvider = TradingServiceProvider._();

final class TradingServiceProvider
    extends $NotifierProvider<TradingService, TradingServiceState> {
  TradingServiceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'tradingServiceProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$tradingServiceHash();

  @$internal
  @override
  TradingService create() => TradingService();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(TradingServiceState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<TradingServiceState>(value),
    );
  }
}

String _$tradingServiceHash() => r'c5a6eade22031c0a802453278a5c5a68d3052c5a';

abstract class _$TradingService extends $Notifier<TradingServiceState> {
  TradingServiceState build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<TradingServiceState, TradingServiceState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<TradingServiceState, TradingServiceState>,
              TradingServiceState,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}

@ProviderFor(indicatorResult)
final indicatorResultProvider = IndicatorResultFamily._();

final class IndicatorResultProvider
    extends
        $FunctionalProvider<
          AsyncValue<IndicatorResult?>,
          AsyncValue<IndicatorResult?>,
          AsyncValue<IndicatorResult?>
        >
    with $Provider<AsyncValue<IndicatorResult?>> {
  IndicatorResultProvider._({
    required IndicatorResultFamily super.from,
    required ({
      List<InternalIndexPriceItem> prices,
      InternalIndicator indicator,
    })
    super.argument,
  }) : super(
         retry: null,
         name: r'indicatorResultProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$indicatorResultHash();

  @override
  String toString() {
    return r'indicatorResultProvider'
        ''
        '$argument';
  }

  @$internal
  @override
  $ProviderElement<AsyncValue<IndicatorResult?>> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  AsyncValue<IndicatorResult?> create(Ref ref) {
    final argument =
        this.argument
            as ({
              List<InternalIndexPriceItem> prices,
              InternalIndicator indicator,
            });
    return indicatorResult(
      ref,
      prices: argument.prices,
      indicator: argument.indicator,
    );
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AsyncValue<IndicatorResult?> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AsyncValue<IndicatorResult?>>(value),
    );
  }

  @override
  bool operator ==(Object other) {
    return other is IndicatorResultProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$indicatorResultHash() => r'8ba74104383f3f079122a631adcea8652aee46a2';

final class IndicatorResultFamily extends $Family
    with
        $FunctionalFamilyOverride<
          AsyncValue<IndicatorResult?>,
          ({List<InternalIndexPriceItem> prices, InternalIndicator indicator})
        > {
  IndicatorResultFamily._()
    : super(
        retry: null,
        name: r'indicatorResultProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  IndicatorResultProvider call({
    required List<InternalIndexPriceItem> prices,
    required InternalIndicator indicator,
  }) => IndicatorResultProvider._(
    argument: (prices: prices, indicator: indicator),
    from: this,
  );

  @override
  String toString() => r'indicatorResultProvider';
}
