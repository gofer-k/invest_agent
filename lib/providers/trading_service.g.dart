// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'trading_service.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

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

String _$tradingServiceHash() => r'e36a48bd06a7f8b0d92f4e690f8f44ab6ab4280e';

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
