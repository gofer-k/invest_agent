// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'price_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(PriceController)
final priceControllerProvider = PriceControllerProvider._();

final class PriceControllerProvider
    extends $NotifierProvider<PriceController, PriceControllerState> {
  PriceControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'priceControllerProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$priceControllerHash();

  @$internal
  @override
  PriceController create() => PriceController();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(PriceControllerState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<PriceControllerState>(value),
    );
  }
}

String _$priceControllerHash() => r'415b31421d4fc2888399ac7edea9796635a63df3';

abstract class _$PriceController extends $Notifier<PriceControllerState> {
  PriceControllerState build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<PriceControllerState, PriceControllerState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<PriceControllerState, PriceControllerState>,
              PriceControllerState,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}

@ProviderFor(assetPriceDetails)
final assetPriceDetailsProvider = AssetPriceDetailsProvider._();

final class AssetPriceDetailsProvider
    extends
        $FunctionalProvider<
          Map<int, String>,
          Map<int, String>,
          Map<int, String>
        >
    with $Provider<Map<int, String>> {
  AssetPriceDetailsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'assetPriceDetailsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$assetPriceDetailsHash();

  @$internal
  @override
  $ProviderElement<Map<int, String>> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  Map<int, String> create(Ref ref) {
    return assetPriceDetails(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(Map<int, String> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<Map<int, String>>(value),
    );
  }
}

String _$assetPriceDetailsHash() => r'd034f0471d39132e97ebe417738117f74b327eff';
