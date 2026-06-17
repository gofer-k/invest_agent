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

String _$tradingClientHash() => r'0be4fd9771eec28bdd728f278a4ce6b5043a2ff0';

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

String _$tradingServiceHash() => r'48e706c8613e0a7c575111f968b4f04696b17957';

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
