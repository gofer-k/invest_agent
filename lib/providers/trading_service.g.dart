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
    extends $NotifierProvider<TradingService, IndicatorResultMap> {
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
  Override overrideWithValue(IndicatorResultMap value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<IndicatorResultMap>(value),
    );
  }
}

String _$tradingServiceHash() => r'd6945d7220a7441120be90649879d0de454dc5a7';

abstract class _$TradingService extends $Notifier<IndicatorResultMap> {
  IndicatorResultMap build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<IndicatorResultMap, IndicatorResultMap>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<IndicatorResultMap, IndicatorResultMap>,
              IndicatorResultMap,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
